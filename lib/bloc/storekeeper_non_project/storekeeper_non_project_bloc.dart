/*
 * @Author: LeeZB
 * @Date: 2025-08-23 16:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-23 16:30:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/storekeeperActions/storekeeper_warehouse_item.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';
import 'package:pipe_code_flutter/repositories/interfaces/storekeeper_non_project_repository.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'storekeeper_non_project_event.dart';
import 'storekeeper_non_project_state.dart';

class StorekeeperNonProjectBloc
    extends Bloc<StorekeeperNonProjectEvent, StorekeeperNonProjectState> {
  StorekeeperNonProjectBloc({
    required StorekeeperNonProjectRepository repository,
    required QrScanFlowService qrScanFlowService,
  }) : _repository = repository,
       _qrScanFlowService = qrScanFlowService,
       super(const StorekeeperNonProjectState()) {
    // 注册事件处理器
    on<LoadWarehouses>(_onLoadWarehouses);
    on<SelectWarehouse>(_onSelectWarehouse);
    on<StartScanning>(_onStartScanning);
    on<ProcessScannedCodes>(_onProcessScannedCodes);
    on<CancelScanning>(_onCancelScanning);
    on<RemoveMaterial>(_onRemoveMaterial);
    on<ClearMaterials>(_onClearMaterials);
    on<StartImageUpload>(_onStartImageUpload);
    on<ImageUploadCompleted>(_onImageUploadCompleted);
    on<ImageUploadFailed>(_onImageUploadFailed);
    on<RemoveImage>(_onRemoveImage);
    on<UpdateDescription>(_onUpdateDescription);
    on<ClearDescription>(_onClearDescription);
    on<SubmitEntry>(_onSubmitEntry);
    on<ClearErrorMessage>(_onClearErrorMessage);
    on<ClearOperationMessage>(_onClearOperationMessage);
    on<ResetState>(_onResetState);
    on<RefreshPage>(_onRefreshPage);
  }

  final StorekeeperNonProjectRepository _repository;
  final QrScanFlowService _qrScanFlowService;

  /// 加载仓库列表
  Future<void> _onLoadWarehouses(
    LoadWarehouses event,
    Emitter<StorekeeperNonProjectState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StorekeeperNonProjectStatus.loadingWarehouses,
        clearErrorMessage: true,
      ),
    );

    final result = await _repository.getStorekeeperWarehouses();

    if (result.isSuccess) {
      final warehouses = result.data ?? [];
      emit(
        state.copyWith(
          status: StorekeeperNonProjectStatus.warehousesLoaded,
          warehouses: warehouses,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: StorekeeperNonProjectStatus.warehousesLoaded,
          warehouses: [],
          errorMessage: result.msg,
        ),
      );
    }
  }

  /// 选择仓库
  void _onSelectWarehouse(
    SelectWarehouse event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    emit(
      state.copyWith(
        status: StorekeeperNonProjectStatus.ready,
        selectedWarehouse: event.warehouse,
        clearErrorMessage: true,
      ),
    );
  }

  /// 开始扫码
  void _onStartScanning(
    StartScanning event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    // 保存当前状态，以便取消时恢复
    final stateSnapshot = state.createScanningSnapshot();

    emit(
      state.copyWith(
        status: StorekeeperNonProjectStatus.scanning,
        stateBeforeScanning: stateSnapshot,
        clearErrorMessage: true,
        clearOperationMessage: true,
      ),
    );
  }

  /// 处理扫码结果
  Future<void> _onProcessScannedCodes(
    ProcessScannedCodes event,
    Emitter<StorekeeperNonProjectState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StorekeeperNonProjectStatus.processingScannedMaterials,
        clearErrorMessage: true,
      ),
    );

    final result = await _repository.processScannedMaterials(
      event.codes,
      event.operation,
      state.materials,
    );

    if (result.isSuccess) {
      final processResult = result.data!;

      emit(
        state.copyWith(
          status: StorekeeperNonProjectStatus.materialsUpdated,
          materials: processResult.processedMaterials,
          operationMessage: processResult.getOperationSummary(),
          clearStateBeforeScanning: true,
        ),
      );

      // 如果有需要特别提示的信息，设置为错误消息以便显示
      if (processResult.hasNotifications) {
        final notifications = <String>[];

        if (processResult.duplicateCount > 0) {
          notifications.add('忽略了 ${processResult.duplicateCount} 个重复物料');
        }

        if (processResult.skippedCount > 0) {
          notifications.add('跳过了 ${processResult.skippedCount} 个不存在的物料');
        }

        if (processResult.errorMessages.isNotEmpty) {
          notifications.addAll(processResult.errorMessages);
        }

        if (notifications.isNotEmpty) {
          // 使用errorMessage来显示这些通知，因为它们需要用户确认
          emit(state.copyWith(errorMessage: notifications.join('\n')));
        }
      }
    } else {
      // 扫码处理失败，恢复到扫码前状态
      final restoredState = state.restoreFromScanning();
      emit(restoredState.copyWith(errorMessage: result.msg));
    }
  }

  /// 取消扫码
  void _onCancelScanning(
    CancelScanning event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    // 恢复到扫码前的状态
    final restoredState = state.restoreFromScanning();
    emit(restoredState);
  }

  /// 移除物料
  void _onRemoveMaterial(
    RemoveMaterial event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    final updatedMaterials = List<MaterialInfo>.from(state.materials);
    updatedMaterials.removeWhere(
      (material) =>
          material.baseInfo.materialId == event.material.baseInfo.materialId,
    );

    emit(
      state.copyWith(
        materials: updatedMaterials,
        operationMessage: '已移除物料：${event.material.baseInfo.prodNm ?? '未知'}',
        clearErrorMessage: true,
      ),
    );
  }

  /// 清空物料列表
  void _onClearMaterials(
    ClearMaterials event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    emit(
      state.copyWith(
        materials: [],
        operationMessage: '已清空物料列表',
        clearErrorMessage: true,
      ),
    );
  }

  /// 开始上传图片
  void _onStartImageUpload(
    StartImageUpload event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    emit(
      state.copyWith(
        status: StorekeeperNonProjectStatus.uploadingImage,
        clearErrorMessage: true,
      ),
    );
  }

  /// 图片上传完成
  void _onImageUploadCompleted(
    ImageUploadCompleted event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    emit(
      state.copyWith(
        status: StorekeeperNonProjectStatus.imageUploaded,
        imageUrl: event.imageUrl,
        operationMessage: '图片上传成功',
      ),
    );
  }

  /// 图片上传失败
  void _onImageUploadFailed(
    ImageUploadFailed event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    // 恢复到上传前的状态
    final previousStatus = state.hasMaterials
        ? StorekeeperNonProjectStatus.materialsUpdated
        : StorekeeperNonProjectStatus.ready;

    emit(
      state.copyWith(
        status: previousStatus,
        errorMessage: '图片上传失败: ${event.error}',
      ),
    );
  }

  /// 移除图片
  void _onRemoveImage(
    RemoveImage event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    emit(
      state.copyWith(
        imageUrl: '',
        operationMessage: '已移除图片',
        clearImageUrl: true,
        clearErrorMessage: true,
      ),
    );
  }

  /// 更新描述
  void _onUpdateDescription(
    UpdateDescription event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    emit(
      state.copyWith(description: event.description, clearErrorMessage: true),
    );
  }

  /// 清空描述
  void _onClearDescription(
    ClearDescription event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    emit(
      state.copyWith(
        description: '',
        clearDescription: true,
        clearErrorMessage: true,
      ),
    );
  }

  /// 提交入库
  Future<void> _onSubmitEntry(
    SubmitEntry event,
    Emitter<StorekeeperNonProjectState> emit,
  ) async {
    // 先进行本地校验
    if (!state.canSubmit) {
      emit(state.copyWith(errorMessage: _getSubmitValidationError()));
      return;
    }

    emit(
      state.copyWith(
        status: StorekeeperNonProjectStatus.submitting,
        clearErrorMessage: true,
      ),
    );

    final result = await _repository.submitNonProjectEntry(
      warehouseId: state.selectedWarehouse!.id,
      materials: state.materials,
      imageUrl: state.imageUrl!,
      description: state.description,
    );

    if (result.isSuccess) {
      emit(
        state.copyWith(
          status: StorekeeperNonProjectStatus.submitSuccess,
          operationMessage: '入库成功',
        ),
      );
    } else {
      // 提交失败，恢复到提交前状态
      final previousStatus = state.imageUrl != null
          ? StorekeeperNonProjectStatus.imageUploaded
          : StorekeeperNonProjectStatus.materialsUpdated;

      emit(state.copyWith(status: previousStatus, errorMessage: result.msg));
    }
  }

  /// 清除错误消息
  void _onClearErrorMessage(
    ClearErrorMessage event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    emit(state.copyWith(clearErrorMessage: true));
  }

  /// 清除操作消息
  void _onClearOperationMessage(
    ClearOperationMessage event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    emit(state.copyWith(clearOperationMessage: true));
  }

  /// 重置状态
  void _onResetState(
    ResetState event,
    Emitter<StorekeeperNonProjectState> emit,
  ) {
    emit(
      state.copyWith(
        status: StorekeeperNonProjectStatus.ready,
        materials: [],
        imageUrl: '',
        description: '',
        clearImageUrl: true,
        clearDescription: true,
        clearErrorMessage: true,
        clearOperationMessage: true,
        clearStateBeforeScanning: true,
      ),
    );
  }

  /// 刷新页面
  Future<void> _onRefreshPage(
    RefreshPage event,
    Emitter<StorekeeperNonProjectState> emit,
  ) async {
    // 保留当前选择的仓库
    final selectedWarehouse = state.selectedWarehouse;

    emit(
      state.copyWith(
        status: StorekeeperNonProjectStatus.loadingWarehouses,
        clearErrorMessage: true,
      ),
    );

    final result = await _repository.getStorekeeperWarehouses();

    if (result.isSuccess) {
      final warehouses = result.data ?? [];

      // 尝试在新列表中找到之前选择的仓库
      StorekeeperWarehouseItem? newSelectedWarehouse;
      if (selectedWarehouse != null) {
        try {
          newSelectedWarehouse = warehouses.firstWhere(
            (w) => w.id == selectedWarehouse.id,
          );
        } catch (e) {
          // 如果没找到，选择第一个仓库（如果有的话）
          newSelectedWarehouse = warehouses.isNotEmpty
              ? warehouses.first
              : null;
        }
      }

      final newStatus = newSelectedWarehouse != null
          ? StorekeeperNonProjectStatus.ready
          : StorekeeperNonProjectStatus.warehousesLoaded;

      emit(
        state.copyWith(
          status: newStatus,
          warehouses: warehouses,
          selectedWarehouse: newSelectedWarehouse,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: StorekeeperNonProjectStatus.warehousesLoaded,
          warehouses: [],
          errorMessage: result.msg,
        ),
      );
    }
  }

  /// 获取提交校验错误信息
  String _getSubmitValidationError() {
    if (state.selectedWarehouse == null) {
      return '请选择仓库';
    }
    if (state.materials.isEmpty) {
      return '请添加物料';
    }
    if (state.imageUrl == null || state.imageUrl!.isEmpty) {
      return '请上传图片';
    }
    return '数据不完整，无法提交';
  }

  /// 构建QR扫码配置
  QrScanConfig buildQrScanConfig(QrScanOperation operation) {
    final currentCodes = state.materials
        .map((m) => m.baseInfo.materialCode ?? '')
        .where((code) => code.isNotEmpty)
        .toList();

    final request = QrScanFlowRequest(
      operation: operation,
      currentCodes: currentCodes,
      batch: true,
      title: _getScanTitle(operation),
      skipValidation: false,
    );

    return _qrScanFlowService.buildConfig(request);
  }

  /// 获取扫码标题
  String _getScanTitle(QrScanOperation operation) {
    switch (operation) {
      case QrScanOperation.initial:
        return '扫码入库';
      case QrScanOperation.append:
        return '追加扫码';
      case QrScanOperation.remove:
        return '扫码剔除';
    }
  }
}
