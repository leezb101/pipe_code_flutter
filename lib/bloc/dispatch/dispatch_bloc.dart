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
import 'package:pipe_code_flutter/services/tracing/tracing_context.dart';
import 'package:pipe_code_flutter/services/tracing/tracing_manager.dart';

import '../../models/material/material_info_for_business.dart';

part 'dispatch_event.dart';
part 'dispatch_state.dart';

class DispatchBloc extends Bloc<DispatchEvent, DispatchState> {
  final DispatchRepository _dispatchRepository;
  final CommonQueryApiService _commonQueryApiService;
  final MaterialHandleRepository _materialHandleRepository;
  final TracingManager _tracingManager = TracingManager();

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
    on<AppendSigninMatchedByCodes>(_onAppendSigninMatchedByCodes);
    on<RemoveSigninMatchedByCodes>(_onRemoveSigninMatchedByCodes);
  }

  // 处理加载调拨详情事件
  Future<void> _onLoadDispatchDetail(
    LoadDispatchDetail event,
    Emitter<DispatchState> emit,
  ) async {
    await _tracingManager.scopeAction(event.tracingContext, () async {
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
    });
  }

  // 扫码辅助：批量codes -> materialId集合
  Future<Set<int>> _scanCodesToMaterialIds(List<String> codes) async {
    final rsp = await _materialHandleRepository.scanBatchToQueryAll(codes);
    if (rsp.isSuccess && rsp.data != null) {
      final MaterialInfoForBusiness bundle = rsp.data!;
      return bundle.normals.map((m) => m.baseInfo.materialId).toSet();
    }
    throw Exception(rsp.msg);
  }

  // 映射: ids -> 当前调拨单中的物料列表
  List<MaterialVO> _mapIdsToDispatchMaterials(Set<int> ids) {
    if (state.dispatchDetail == null) return const [];
    final byId = {
      for (final m in state.dispatchDetail!.materialList) m.materialId: m,
    };
    return ids.map((id) => byId[id]).whereType<MaterialVO>().toList();
  }

  // 入库页：继续扫码（追加匹配）
  Future<void> _onAppendSigninMatchedByCodes(
    AppendSigninMatchedByCodes event,
    Emitter<DispatchState> emit,
  ) async {
    await _tracingManager.scopeAction(event.tracingContext, () async {
      if (event.codes.isEmpty) return;
      if (state.dispatchDetail == null) {
        emit(
          state.copyWith(
            status: DispatchStatus.failure,
            errorMessage: '调拨详情未加载',
          ),
        );
        return;
      }
      try {
        final ids = await _scanCodesToMaterialIds(event.codes);
        // 非本单物料
        final dispatchIds = state.dispatchDetail!.materialList
            .map((m) => m.materialId)
            .toSet();
        final invalid = ids.difference(dispatchIds);
        // 能映射到本单的物料
        final validIds = ids.intersection(dispatchIds);
        final toAdd = _mapIdsToDispatchMaterials(validIds);

        // 过滤重复（已匹配过）
        final current = Set<MaterialVO>.from(state.matchedMaterials);
        final beforeLen = current.length;
        for (final m in toAdd) {
          if (!current.contains(m)) {
            current.add(m);
          }
        }
        final addedCount = current.length - beforeLen;

        String message = '';
        if (addedCount > 0) message += '已新增 $addedCount 个物料';
        if (invalid.isNotEmpty) {
          if (message.isNotEmpty) message += '，';
          message += '非本单物料ID: ${invalid.join(', ')}';
        }

        emit(
          state.copyWith(
            status: DispatchStatus.success,
            matchedMaterials: current,
            matchMessage: message.isNotEmpty ? message : '没有新增可匹配的物料',
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
    });
  }

  // 入库页：扫码剔除（移除已匹配）
  Future<void> _onRemoveSigninMatchedByCodes(
    RemoveSigninMatchedByCodes event,
    Emitter<DispatchState> emit,
  ) async {
    await _tracingManager.scopeAction(event.tracingContext, () async {
      if (event.codes.isEmpty) return;
      if (state.dispatchDetail == null) {
        emit(
          state.copyWith(
            status: DispatchStatus.failure,
            errorMessage: '调拨详情未加载',
          ),
        );
        return;
      }
      try {
        final ids = await _scanCodesToMaterialIds(event.codes);
        final mapped = _mapIdsToDispatchMaterials(ids);
        final current = Set<MaterialVO>.from(state.matchedMaterials);

        // 统计未匹配过但尝试移除的id
        final matchedIds = current.map((m) => m.materialId).toSet();
        final tryingIds = mapped.map((m) => m.materialId).toSet();
        final notScanned = tryingIds.difference(matchedIds);

        // 真正要移除的
        final removeIds = tryingIds.intersection(matchedIds);
        current.removeWhere((m) => removeIds.contains(m.materialId));

        String message = '';
        if (removeIds.isNotEmpty) message += '已移除 ${removeIds.length} 个物料';
        if (notScanned.isNotEmpty) {
          if (message.isNotEmpty) message += '，';
          message += '未扫描过的物料ID: ${notScanned.join(', ')}';
        }

        emit(
          state.copyWith(
            status: DispatchStatus.success,
            matchedMaterials: current,
            matchMessage: message.isNotEmpty ? message : '没有可移除的物料',
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
    });
  }

  void _onUpdateApplicationMaterialListWithAppendingCodes(
    UpdateApplicationMaterialWithAppendCodes event,
    Emitter<DispatchState> emit,
  ) async {
    await _tracingManager.scopeAction(event.tracingContext, () async {
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

          // 处理正常材料重复检查
          final existingIds = state.materialIds ?? <int>{};
          final duplicateIds = ids.intersection(existingIds);
          if (duplicateIds.isNotEmpty) {
            appendingMaterials.removeWhere(
              (m) => duplicateIds.contains(m.materialId),
            );
          }

          // 处理错误材料追加
          final currentErrorMaterials = List<dynamic>.from(
            state.errorMaterials,
          );
          int errorAddedCount = 0;
          for (final error in bundle.errors) {
            // 简单的重复检查，基于qrCode
            final qrCode = _getErrorQrCode(error);
            final isDuplicate = currentErrorMaterials.any(
              (existingError) => _getErrorQrCode(existingError) == qrCode,
            );

            if (!isDuplicate) {
              currentErrorMaterials.add(error);
              errorAddedCount++;
            }
          }

          if (duplicateIds.isNotEmpty) {
            emit(
              state.copyWith(
                status: DispatchStatus.failure,
                errorMessage: duplicateIds.isNotEmpty
                    ? '已存在重复物料ID: ${duplicateIds.join(", ")}'
                    : null,
              ),
            );
          }

          final materialVos = [...?state.materialList, ...appendingMaterials];
          final totalIds = materialVos.map((m) => m.materialId).toSet();

          // 构建消息
          final messages = <String>[];
          if (appendingMaterials.isNotEmpty) {
            messages.add('已添加 ${appendingMaterials.length} 个正常材料');
          }
          if (errorAddedCount > 0) {
            messages.add('已添加 $errorAddedCount 个异常材料');
          }

          final message = messages.isNotEmpty
              ? messages.join('，')
              : totalIds.isNotEmpty
              ? '已添加材料'
              : null;

          // 延迟2s后发送
          await Future.delayed(const Duration(seconds: 2));
          emit(
            state.copyWith(
              status: DispatchStatus.success,
              materialIds: totalIds,
              materialList: materialVos,
              errorMaterials: currentErrorMaterials,
              matchMessage: message,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: DispatchStatus.failure,
              errorMessage: rsp.msg,
            ),
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
    });
  }

  Future<void> _onUpdateApplicationMaterialListWithRemovingCodes(
    UpdateApplicationMaterialWithRemoveCodes event,
    Emitter<DispatchState> emit,
  ) async {
    await _tracingManager.scopeAction(event.tracingContext, () async {
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

          // 检查正常材料是否在当前列表中
          final existingIds = state.materialIds ?? <int>{};
          final invalidIds = ids.difference(existingIds);
          if (invalidIds.isNotEmpty) {
            emit(
              state.copyWith(
                status: DispatchStatus.failure,
                errorMessage:
                    '扫码的物料中存在未登记的ID: ${invalidIds.join(", ")},请检查后重新扫码',
              ),
            );
            return;
          }

          // 处理正常材料剔除
          final materialVos = [...?state.materialList];
          materialVos.removeWhere((m) => ids.contains(m.materialId));
          final removedNormalCount = ids.length;

          // 处理错误材料剔除
          final currentErrorMaterials = List<dynamic>.from(
            state.errorMaterials,
          );
          int removedErrorCount = 0;

          for (final errorToRemove in bundle.errors) {
            final qrCodeToRemove = _getErrorQrCode(errorToRemove);

            for (int i = currentErrorMaterials.length - 1; i >= 0; i--) {
              final existingQrCode = _getErrorQrCode(currentErrorMaterials[i]);
              if (existingQrCode == qrCodeToRemove &&
                  qrCodeToRemove.isNotEmpty) {
                currentErrorMaterials.removeAt(i);
                removedErrorCount++;
                break;
              }
            }
          }

          // 构建消息
          final messages = <String>[];
          if (removedNormalCount > 0) {
            messages.add('已移除 $removedNormalCount 个正常材料');
          }
          if (removedErrorCount > 0) {
            messages.add('已移除 $removedErrorCount 个异常材料');
          }

          final message = messages.isNotEmpty ? messages.join('，') : '已移除材料';

          emit(
            state.copyWith(
              status: DispatchStatus.success,
              materialIds: materialVos.map((m) => m.materialId).toSet(),
              materialList: materialVos,
              errorMaterials: currentErrorMaterials,
              matchMessage: message,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: DispatchStatus.failure,
              errorMessage: rsp.msg,
            ),
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
    });
  }

  Future<void> _onInitializeMaterialsFromCodes(
    InitializeMaterialsFromCodes event,
    Emitter<DispatchState> emit,
  ) async {
    await _tracingManager.scopeAction(event.tracingContext, () async {
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
              errorMaterials: bundle.errors, // 设置错误材料
            ),
          );

          // 不再自动触发 LoadApplicationData，而是由页面控制
        }
      } catch (e) {
        emit(
          state.copyWith(
            status: DispatchStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }

  // 处理加载申请页数据事件
  Future<void> _onLoadApplicationData(
    LoadApplicationData event,
    Emitter<DispatchState> emit,
  ) async {
    await _tracingManager.scopeAction(event.tracingContext, () async {
      // 立即更新物料列表，让UI先行渲染
      emit(
        state.copyWith(
          status: DispatchStatus.loadingSourceInfo,
          materialList: event.materials,
          // 清空之前的错误信息
          sourceProjectError: null,
          sourceWarehouseError: null,
          availableProjectsError: null,
          availableWarehousesError: null,
        ),
      );

      try {
        if (event.materials.isEmpty) {
          throw Exception("缺少有效的物料ID");
        }
        final materialId = event.materials.first.materialId;

        // 单独处理每个请求，能够捕获具体错误
        ProjectSimpleVo? sourceProject;
        WarehouseVO? sourceWarehouse;
        List<ProjectSimpleVo> availableProjects = [];
        List<WarehouseVO> availableWarehouses = [];
        List<CommonUserVO> users = [];

        String? sourceProjectError;
        String? sourceWarehouseError;
        String? availableProjectsError;
        String? availableWarehousesError;

        // 获取可选项目列表
        try {
          final projectsResult = await _commonQueryApiService
              .getCurrentLegalProjectList();
          if (projectsResult.isSuccess) {
            availableProjects = projectsResult.data ?? [];
          } else {
            availableProjectsError = projectsResult.msg.isEmpty
                ? '获取项目列表失败'
                : projectsResult.msg;
          }
        } catch (e) {
          availableProjectsError = '获取项目列表异常: ${e.toString()}';
        }

        // 获取可选仓库列表
        try {
          final warehousesResult = await _commonQueryApiService
              .getWarehouseList();
          if (warehousesResult.isSuccess) {
            availableWarehouses = warehousesResult.data ?? [];
            // 如果仓库列表获取成功，尝试获取第一个仓库的用户列表
            if (availableWarehouses.isNotEmpty) {
              try {
                final usersResult = await _commonQueryApiService
                    .getWarehouseUsers(availableWarehouses.first.id);
                if (usersResult.isSuccess && usersResult.data != null) {
                  users = usersResult.data!.warehouseUsers;
                }
              } catch (e) {
                // 用户列表获取失败不影响主流程
              }
            }
          } else {
            availableWarehousesError = warehousesResult.msg.isEmpty
                ? '获取仓库列表失败'
                : warehousesResult.msg;
          }
        } catch (e) {
          availableWarehousesError = '获取仓库列表异常: ${e.toString()}';
        }

        // 获取出库方项目信息
        try {
          final sourceProjectResult = await _commonQueryApiService
              .getProjectByMaterial(materialId);
          if (sourceProjectResult.isSuccess) {
            sourceProject = sourceProjectResult.data;
          } else {
            sourceProjectError = sourceProjectResult.msg.isEmpty
                ? '获取出库方项目失败'
                : sourceProjectResult.msg;
          }
        } catch (e) {
          sourceProjectError = e.toString();
        }

        // 获取出库方仓库信息
        try {
          final sourceWarehouseResult = await _commonQueryApiService
              .getWarehouseByMaterial(materialId);
          if (sourceWarehouseResult.isSuccess) {
            sourceWarehouse = sourceWarehouseResult.data;
          } else {
            sourceWarehouseError = sourceWarehouseResult.msg.isEmpty
                ? '获取出库方仓库失败'
                : sourceWarehouseResult.msg;
          }
        } catch (e) {
          sourceWarehouseError = '获取出库方仓库异常: ${e.toString()}';
        }

        emit(
          state.copyWith(
            status: DispatchStatus.success,
            sourceProject: sourceProject,
            sourceWarehouse: sourceWarehouse,
            availableProjects: availableProjects,
            availableWarehouses: availableWarehouses,
            availableWarehouseUsers: users,
            sourceProjectError: sourceProjectError,
            sourceWarehouseError: sourceWarehouseError,
            availableProjectsError: availableProjectsError,
            availableWarehousesError: availableWarehousesError,
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
    });
  }

  Future<void> _onUpdateWarehouseUsersList(
    UpdateWarehouseUsersList event,
    Emitter<DispatchState> emit,
  ) async {
    await _tracingManager.scopeAction(event.tracingContext, () async {
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
    });
  }

  // 处理提交调拨申请事件
  Future<void> _onSubmitDispatchApplication(
    SubmitDispatchApplication event,
    Emitter<DispatchState> emit,
  ) async {
    await _tracingManager.scopeAction(event.tracingContext, () async {
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
    });
  }

  // 处理调拨入库事件
  Future<void> _onSubmitDispatchSignIn(
    SubmitDispatchSignIn event,
    Emitter<DispatchState> emit,
  ) async {
    await _tracingManager.scopeAction(event.tracingContext, () async {
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
    });
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

  /// 从错误材料对象中提取qrCode
  String _getErrorQrCode(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['qrCode']?.toString() ?? error['qr_code']?.toString() ?? '';
    }
    try {
      return (error as dynamic).qrCode?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }
}
