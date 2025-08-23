/*
 * @Author: LeeZB
 * @Date: 2025-08-23 16:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-23 16:30:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/storekeeperActions/storekeeper_warehouse_item.dart';

/// 仓管员非项目入库状态
class StorekeeperNonProjectState extends Equatable {
  const StorekeeperNonProjectState({
    this.status = StorekeeperNonProjectStatus.initial,
    this.warehouses = const [],
    this.selectedWarehouse,
    this.materials = const [],
    this.imageUrl,
    this.description,
    this.errorMessage,
    this.operationMessage,
    this.stateBeforeScanning,
  });

  /// 主状态
  final StorekeeperNonProjectStatus status;

  /// 仓库列表
  final List<StorekeeperWarehouseItem> warehouses;

  /// 选中的仓库
  final StorekeeperWarehouseItem? selectedWarehouse;

  /// 物料列表
  final List<MaterialInfo> materials;

  /// 上传的图片URL
  final String? imageUrl;

  /// 描述信息
  final String? description;

  /// 错误消息（用于一次性显示和清除）
  final String? errorMessage;

  /// 操作消息（用于显示操作结果，如"新增3个物料"）
  final String? operationMessage;

  /// 扫码前的状态（用于取消扫码时恢复）
  final StorekeeperNonProjectState? stateBeforeScanning;

  @override
  List<Object?> get props => [
    status,
    warehouses,
    selectedWarehouse,
    materials,
    imageUrl,
    description,
    errorMessage,
    operationMessage,
    stateBeforeScanning,
  ];

  /// 复制状态，支持清除错误和操作消息
  StorekeeperNonProjectState copyWith({
    StorekeeperNonProjectStatus? status,
    List<StorekeeperWarehouseItem>? warehouses,
    StorekeeperWarehouseItem? selectedWarehouse,
    List<MaterialInfo>? materials,
    String? imageUrl,
    String? description,
    String? errorMessage,
    String? operationMessage,
    StorekeeperNonProjectState? stateBeforeScanning,
    bool clearErrorMessage = false,
    bool clearOperationMessage = false,
    bool clearSelectedWarehouse = false,
    bool clearImageUrl = false,
    bool clearDescription = false,
    bool clearStateBeforeScanning = false,
  }) {
    return StorekeeperNonProjectState(
      status: status ?? this.status,
      warehouses: warehouses ?? this.warehouses,
      selectedWarehouse: clearSelectedWarehouse
          ? null
          : (selectedWarehouse ?? this.selectedWarehouse),
      materials: materials ?? this.materials,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      description: clearDescription ? null : (description ?? this.description),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      operationMessage: clearOperationMessage
          ? null
          : (operationMessage ?? this.operationMessage),
      stateBeforeScanning: clearStateBeforeScanning
          ? null
          : (stateBeforeScanning ?? this.stateBeforeScanning),
    );
  }

  /// 检查是否可以提交
  bool get canSubmit =>
      selectedWarehouse != null &&
      materials.isNotEmpty &&
      imageUrl != null &&
      imageUrl!.isNotEmpty &&
      status != StorekeeperNonProjectStatus.submitting;

  /// 检查是否有仓库可选
  bool get hasWarehouses => warehouses.isNotEmpty;

  /// 检查是否有物料
  bool get hasMaterials => materials.isNotEmpty;

  /// 检查是否有错误消息需要显示
  bool get hasErrorMessage => errorMessage != null && errorMessage!.isNotEmpty;

  /// 检查是否有操作消息需要显示
  bool get hasOperationMessage =>
      operationMessage != null && operationMessage!.isNotEmpty;

  /// 获取物料数量
  int get materialCount => materials.length;

  /// 创建扫码前状态快照（排除扫码相关的临时状态）
  StorekeeperNonProjectState createScanningSnapshot() {
    return copyWith(
      clearErrorMessage: true,
      clearOperationMessage: true,
      clearStateBeforeScanning: true,
    );
  }

  /// 从扫码前状态恢复
  StorekeeperNonProjectState restoreFromScanning() {
    if (stateBeforeScanning == null) return this;

    return stateBeforeScanning!.copyWith(
      // 保留可能在扫码期间更新的非关键信息
      clearStateBeforeScanning: true,
    );
  }
}

/// 仓管员非项目入库状态枚举
enum StorekeeperNonProjectStatus {
  /// 初始状态
  initial,

  /// 加载仓库列表中
  loadingWarehouses,

  /// 仓库列表已加载
  warehousesLoaded,

  /// 准备就绪（已选择仓库）
  ready,

  /// 扫码中（用户在扫码页面）
  scanning,

  /// 处理扫码结果中
  processingScannedMaterials,

  /// 物料列表已更新
  materialsUpdated,

  /// 上传图片中
  uploadingImage,

  /// 图片已上传
  imageUploaded,

  /// 提交中
  submitting,

  /// 提交成功
  submitSuccess,

  /// 重置中（清理状态准备新的入库）
  resetting,
}
