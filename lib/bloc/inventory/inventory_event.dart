import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object?> get props => [];
}

/// 获取盘点任务列表 (用于首页角标和列表页)
class InventoryTasksFetched extends InventoryEvent {
  final bool isRefresh;
  const InventoryTasksFetched({this.isRefresh = false});
}

/// 获取盘点任务详情
class InventoryDetailFetched extends InventoryEvent {
  final int taskId;
  const InventoryDetailFetched(this.taskId);
}

/// 扫码完成, 处理二维码
class InventoryScanCompleted extends InventoryEvent {
  final List<String> qrCodes;
  const InventoryScanCompleted(this.qrCodes);
}

/// 扫码查询物料成功，直接处理物料信息
class InventoryMaterialsCompared extends InventoryEvent {
  final List<MaterialInfo> scannedMaterials;
  const InventoryMaterialsCompared(this.scannedMaterials);
}

/// 暂存待上传的照片
class InventoryPhotosUpdated extends InventoryEvent {
  final String? photo1;
  final String? photo2;
  const InventoryPhotosUpdated({this.photo1, this.photo2});
}

/// 提交盘点
class InventorySubmitted extends InventoryEvent {}

/// 重置状态
class InventoryReset extends InventoryEvent {}
