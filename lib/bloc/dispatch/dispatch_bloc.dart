/*
 * @Author: LeeZB
 * @Date: 2025-07-27 13:09:35
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-27 16:59:52
 * @copyright: Copyright © 2025 高新供水.
 */
/*
 * @Author: LeeZB
 * @Date: 2025-07-27 13:09:35
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-27 13:50:55
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/models/project/project_simple_vo.dart';
import 'package:pipe_code_flutter/models/common/warehouse_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/dispatch_detail_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_apply_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_sign_in_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/dispatch_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/common_query_api_service.dart';

import '../../models/material/material_info_for_business.dart';

part 'dispatch_event.dart';
part 'dispatch_state.dart';

class DispatchBloc extends Bloc<DispatchEvent, DispatchState> {
  final DispatchRepository _dispatchRepository;
  final CommonQueryApiService _commonQueryApiService;
  final MaterialHandleRepository _materialHandleRepository;

  DispatchBloc({
    DispatchRepository? dispatchRepository,
    CommonQueryApiService? commonQueryApiService,
    MaterialHandleRepository? materialHandleRepository,
  }) : _dispatchRepository = dispatchRepository ?? getIt<DispatchRepository>(),
       _commonQueryApiService =
           commonQueryApiService ?? getIt<CommonQueryApiService>(),
       _materialHandleRepository =
           materialHandleRepository ?? getIt<MaterialHandleRepository>(),
       super(const DispatchState()) {
    on<LoadDispatchDetail>(_onLoadDispatchDetail);
    on<InitializeMaterialsFromCodes>(_onInitializeMaterialsFromCodes);
    on<LoadApplicationData>(_onLoadApplicationData);
    on<SubmitDispatchApplication>(_onSubmitDispatchApplication);
    on<AuditDispatch>(_onAuditDispatch);
    on<SubmitDispatchSignIn>(_onSubmitDispatchSignIn);
    on<UpdateScannedMaterials>(_onUpdateScannedMaterials);
    on<UpdateWarehouseUsersList>(_onUpdateWarehouseUsersList);
    on<MatchScannedMaterial>(_onMatchScannedMaterial);
    on<UpdateApplicationMaterialWithAppendCodes>(
      _onUpdateApplicationMaterialListWithAppendingCodes,
    );
    on<UpdateApplicationMaterialWithRemoveCodes>(
      _onUpdateApplicationMaterialListWithRemovingCodes,
    );
  }

  // 处理加载调拨详情事件
  Future<void> _onLoadDispatchDetail(
    LoadDispatchDetail event,
    Emitter<DispatchState> emit,
  ) async {
    emit(state.copyWith(status: DispatchStatus.loading));
    final result = await _dispatchRepository.getDispatchDetail(
      event.dispatchId,
    );
    if (result.isSuccess && result.data != null) {
      emit(
        state.copyWith(
          status: DispatchStatus.success,
          dispatchDetail: result.data,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: DispatchStatus.failure,
          errorMessage: result.msg,
        ),
      );
    }
  }

  void _onUpdateApplicationMaterialListWithAppendingCodes(
    UpdateApplicationMaterialWithAppendCodes event,
    Emitter<DispatchState> emit,
  ) async {
    final codes = event.appendingCodes;
    if (codes.isEmpty) return;
    try {
      final rsp = await _materialHandleRepository.scanBatchToQueryAll(codes);
      if (rsp.isSuccess && rsp.data != null) {
        final MaterialInfoForBusiness bundle = rsp.data!;
        final appendingMaterials = bundle.normals
            .map(
              (m) => MaterialVO(
                materialId: m.baseInfo.materialId,
                materialName: m.baseInfo.prodNm ?? '',
                num: 1,
              ),
            )
            .toList();
        final ids = appendingMaterials.map((m) => m.materialId).toSet();
        // 先与state中的materials或者materialIds进行比对，如果发现新的物料与原state中的物料materialId一致，则不添加并toast提示有重复xx个，并从新物料中剔除，再把去重后的_materialVos添加到state
        final existingIds = state.materialIds ?? <int>{};
        final duplicateIds = ids.intersection(existingIds);
        if (duplicateIds.isNotEmpty) {
          appendingMaterials.removeWhere(
            (m) => duplicateIds.contains(m.materialId),
          );
        }
        emit(
          state.copyWith(
            status: DispatchStatus.failure,
            errorMessage: duplicateIds.isNotEmpty
                ? '已存在重复物料ID: ${duplicateIds.join(", ")}'
                : null,
          ),
        );
        final materialVos = [...?state.materialList, ...appendingMaterials];
        final totalIds = materialVos.map((m) => m.materialId).toSet();

        // 延迟2s后发送
        await Future.delayed(const Duration(seconds: 2));
        emit(
          state.copyWith(
            status: DispatchStatus.success,
            materialIds: totalIds,
            materialList: materialVos,
            matchMessage: totalIds.isNotEmpty
                ? '已添加 ${appendingMaterials.length} 个物料'
                : null,
          ),
        );
      } else {
        emit(
          state.copyWith(status: DispatchStatus.failure, errorMessage: rsp.msg),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DispatchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateApplicationMaterialListWithRemovingCodes(
    UpdateApplicationMaterialWithRemoveCodes event,
    Emitter<DispatchState> emit,
  ) async {
    final codes = event.removingCodes;
    if (codes.isEmpty) return;
    try {
      final rsp = await _materialHandleRepository.scanBatchToQueryAll(codes);
      if (rsp.isSuccess && rsp.data != null) {
        final MaterialInfoForBusiness bundle = rsp.data!;
        final removingMaterials = bundle.normals
            .map(
              (m) => MaterialVO(
                materialId: m.baseInfo.materialId,
                materialName: m.baseInfo.prodNm ?? '',
                num: 1,
              ),
            )
            .toList();
        final ids = removingMaterials.map((m) => m.materialId).toSet();
        // 先与state中的materialIds或物料列表进行比对，如果发现新扫码的物料中存在原state中没有的id，则认为是错误扫码，不作处理，并弹出toast提示，然后将其他新扫码并匹配到原state中的物料从原state中进行移除，并弹出移除了xx个物料的toast
        final existingIds = state.materialIds ?? <int>{};
        final invalidIds = ids.difference(existingIds);
        if (invalidIds.isNotEmpty) {
          emit(
            state.copyWith(
              status: DispatchStatus.failure,
              errorMessage: '扫码的物料中存在未登记的ID: ${invalidIds.join(", ")},请检查后重新扫码',
            ),
          );
          return;
        }
        final materialVos = [...?state.materialList];
        materialVos.removeWhere((m) => ids.contains(m.materialId));
        emit(
          state.copyWith(
            status: DispatchStatus.success,
            materialIds: materialVos.map((m) => m.materialId).toSet(),
            materialList: materialVos,
            matchMessage: '已移除 ${ids.length} 个物料',
          ),
        );
      } else {
        emit(
          state.copyWith(status: DispatchStatus.failure, errorMessage: rsp.msg),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DispatchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onInitializeMaterialsFromCodes(
    InitializeMaterialsFromCodes event,
    Emitter<DispatchState> emit,
  ) async {
    try {
      if (event.codes.isEmpty) return;
      final rsp = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );
      if (rsp.isSuccess && rsp.data != null) {
        final MaterialInfoForBusiness bundle = rsp.data!;
        final ids = bundle.normals.map((m) => m.baseInfo.materialId).toSet();
        final materialVos = bundle.normals
            .map(
              (m) => MaterialVO(
                materialId: m.baseInfo.materialId,
                materialName: m.baseInfo.prodNm ?? '',
                num: 1,
              ),
            )
            .toList();

        emit(
          state.copyWith(
            status: DispatchStatus.success,
            materialIds: ids,
            materialList: materialVos,
          ),
        );
        add(LoadApplicationData(materialVos));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DispatchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // 处理加载申请页数据事件
  Future<void> _onLoadApplicationData(
    LoadApplicationData event,
    Emitter<DispatchState> emit,
  ) async {
    // 立即更新物料列表，让UI先行渲染
    emit(
      state.copyWith(
        status: DispatchStatus.loadingSourceInfo,
        materialList: event.materials,
      ),
    );

    try {
      if (event.materials.isEmpty) {
        throw Exception("缺少有效的物料ID");
      }
      final materialId = event.materials.first.materialId;

      // 并行获取可选项目和仓库列表
      final futures = [
        _commonQueryApiService.getCurrentLegalProjectList(),
        _commonQueryApiService.getWarehouseList(),
        _commonQueryApiService.getProjectByMaterial(materialId),
        _commonQueryApiService.getWarehouseByMaterial(materialId),
      ];

      final results = await Future.wait(futures);

      final projectsResult = results[0] as dynamic;
      final warehousesResult = results[1] as dynamic;
      final sourceProjectResult = results[2] as dynamic;
      final sourceWarehouseResult = results[3] as dynamic;

      // 检查并行获取的结果
      if (!projectsResult.isSuccess ||
          !warehousesResult.isSuccess ||
          !sourceProjectResult.isSuccess ||
          !sourceWarehouseResult.isSuccess) {
        throw Exception("获取基础数据失败");
      }

      final sourceWarehouse = sourceWarehouseResult.data as WarehouseVO;
      List<CommonUserVO> users = [];
      final usersResult = await _commonQueryApiService.getWarehouseUsers(
        warehousesResult.data.first.id,
      );
      if (usersResult.isSuccess && usersResult.data != null) {
        users = usersResult.data!.warehouseUsers;
      }

      emit(
        state.copyWith(
          status: DispatchStatus.success,
          availableProjects: projectsResult.data,
          availableWarehouses: warehousesResult.data,
          sourceProject: sourceProjectResult.data,
          sourceWarehouse: sourceWarehouse,
          availableWarehouseUsers: users,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DispatchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateWarehouseUsersList(
    UpdateWarehouseUsersList event,
    Emitter<DispatchState> emit,
  ) async {
    emit(state.copyWith(status: DispatchStatus.loading));
    final result = await _commonQueryApiService.getWarehouseUsers(
      event.warehouseId,
    );
    if (result.isSuccess && result.data != null) {
      emit(
        state.copyWith(
          status: DispatchStatus.success,
          availableWarehouseUsers: result.data!.warehouseUsers,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: DispatchStatus.failure,
          errorMessage: result.msg,
        ),
      );
    }
  }

  // 处理提交调拨申请事件
  Future<void> _onSubmitDispatchApplication(
    SubmitDispatchApplication event,
    Emitter<DispatchState> emit,
  ) async {
    emit(state.copyWith(status: DispatchStatus.loading));
    final result = await _dispatchRepository.doDispatch(event.request);
    if (result.isSuccess) {
      emit(state.copyWith(status: DispatchStatus.applySuccess));
    } else {
      emit(
        state.copyWith(
          status: DispatchStatus.failure,
          errorMessage: result.msg,
        ),
      );
    }
  }

  // 处理审核调拨事件
  Future<void> _onAuditDispatch(
    AuditDispatch event,
    Emitter<DispatchState> emit,
  ) async {
    emit(state.copyWith(status: DispatchStatus.loading));
    final result = await _dispatchRepository.auditDispatch(event.request);
    if (result.isSuccess) {
      emit(state.copyWith(status: DispatchStatus.auditSuccess));
    } else {
      emit(
        state.copyWith(
          status: DispatchStatus.failure,
          errorMessage: result.msg,
        ),
      );
    }
  }

  // 处理调拨入库事件
  Future<void> _onSubmitDispatchSignIn(
    SubmitDispatchSignIn event,
    Emitter<DispatchState> emit,
  ) async {
    emit(state.copyWith(status: DispatchStatus.loading));
    final result = await _dispatchRepository.doDispatchSignin(event.request);
    if (result.isSuccess) {
      emit(state.copyWith(status: DispatchStatus.signInSuccess));
    } else {
      emit(
        state.copyWith(
          status: DispatchStatus.failure,
          errorMessage: result.msg,
        ),
      );
    }
  }

  // 处理更新扫描物料列表事件
  void _onUpdateScannedMaterials(
    UpdateScannedMaterials event,
    Emitter<DispatchState> emit,
  ) {
    emit(state.copyWith(scannedMaterials: event.scannedMaterials));
  }

  // 处理匹配扫码物料事件
  void _onMatchScannedMaterial(
    MatchScannedMaterial event,
    Emitter<DispatchState> emit,
  ) {
    // 检查是否有调拨详情
    if (state.dispatchDetail == null) {
      emit(
        state.copyWith(status: DispatchStatus.failure, errorMessage: '调拨详情未加载'),
      );
      return;
    }

    final dispatchDetail = state.dispatchDetail!;
    final scannedMaterial = event.scannedMaterial;

    // 检查是否有错误信息
    if (scannedMaterial.errors.isNotEmpty) {
      emit(
        state.copyWith(
          matchMessage: '扫码物料存在错误: ${scannedMaterial.errors.first}',
        ),
      );
      return;
    }

    // 检查是否有正常物料信息
    if (scannedMaterial.normals.isEmpty) {
      emit(state.copyWith(matchMessage: '未找到有效的物料信息'));
      return;
    }

    final scannedBaseInfo = scannedMaterial.normals.first;
    final matchedMaterials = Set<MaterialVO>.from(state.matchedMaterials);

    // 查找匹配的物料
    MaterialVO? matchedMaterial;
    for (final material in dispatchDetail.materialList) {
      // 通过materialId进行匹配
      if (material.materialId == scannedBaseInfo.baseInfo.materialId) {
        matchedMaterial = material;
        break;
      }
    }

    // 如果找到了匹配的物料
    if (matchedMaterial != null) {
      // 检查是否已经匹配过该物料
      if (matchedMaterials.contains(matchedMaterial)) {
        emit(
          state.copyWith(
            matchMessage: '物料 ${matchedMaterial.materialName} 已经扫描过了',
          ),
        );
      } else {
        // 添加到已匹配物料集合中
        matchedMaterials.add(matchedMaterial);
        emit(
          state.copyWith(
            matchedMaterials: matchedMaterials,
            matchMessage: '成功匹配物料: ${matchedMaterial.materialName}',
          ),
        );
      }
    } else {
      // 没有找到匹配的物料
      emit(
        state.copyWith(
          matchMessage:
              '未找到匹配的物料，扫码的物料ID为: ${scannedBaseInfo.baseInfo.materialId}',
        ),
      );
    }
  }
}
