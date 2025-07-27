/*
 * @Author: LeeZB
 * @Date: 2025-07-27 13:09:35
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-27 13:54:16
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
import 'package:pipe_code_flutter/repositories/dispatch_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/common_query_api_service.dart';

part 'dispatch_event.dart';
part 'dispatch_state.dart';

class DispatchBloc extends Bloc<DispatchEvent, DispatchState> {
  final DispatchRepository _dispatchRepository;
  final CommonQueryApiService _commonQueryApiService;

  DispatchBloc({
    DispatchRepository? dispatchRepository,
    CommonQueryApiService? commonQueryApiService,
  }) : _dispatchRepository = dispatchRepository ?? getIt<DispatchRepository>(),
       _commonQueryApiService =
           commonQueryApiService ?? getIt<CommonQueryApiService>(),
       super(const DispatchState()) {
    on<LoadDispatchDetail>(_onLoadDispatchDetail);
    on<LoadApplicationData>(_onLoadApplicationData);
    on<SubmitDispatchApplication>(_onSubmitDispatchApplication);
    on<AuditDispatch>(_onAuditDispatch);
    on<SubmitDispatchSignIn>(_onSubmitDispatchSignIn);
    on<UpdateScannedMaterials>(_onUpdateScannedMaterials);
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
        sourceWarehouse.id,
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
}
