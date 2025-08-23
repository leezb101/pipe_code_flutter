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
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';

abstract class StorekeeperNonProjectEvent extends Equatable {
  const StorekeeperNonProjectEvent();

  @override
  List<Object?> get props => [];
}

/// 加载仓库列表
class LoadWarehouses extends StorekeeperNonProjectEvent {
  const LoadWarehouses();
}

/// 选择仓库
class SelectWarehouse extends StorekeeperNonProjectEvent {
  final StorekeeperWarehouseItem warehouse;

  const SelectWarehouse(this.warehouse);

  @override
  List<Object?> get props => [warehouse];
}

/// 开始扫码（记录当前状态用于可能的取消操作）
class StartScanning extends StorekeeperNonProjectEvent {
  final QrScanOperation operation;

  const StartScanning(this.operation);

  @override
  List<Object?> get props => [operation];
}

/// 处理扫码结果
class ProcessScannedCodes extends StorekeeperNonProjectEvent {
  final List<String> codes;
  final QrScanOperation operation;

  const ProcessScannedCodes({required this.codes, required this.operation});

  @override
  List<Object?> get props => [codes, operation];
}

/// 取消扫码（用户直接返回，未扫码）
class CancelScanning extends StorekeeperNonProjectEvent {
  const CancelScanning();
}

/// 手动移除物料
class RemoveMaterial extends StorekeeperNonProjectEvent {
  final MaterialInfo material;

  const RemoveMaterial(this.material);

  @override
  List<Object?> get props => [material];
}

/// 清空物料列表
class ClearMaterials extends StorekeeperNonProjectEvent {
  const ClearMaterials();
}

/// 开始上传图片
class StartImageUpload extends StorekeeperNonProjectEvent {
  const StartImageUpload();
}

/// 图片上传完成
class ImageUploadCompleted extends StorekeeperNonProjectEvent {
  final String imageUrl;

  const ImageUploadCompleted(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

/// 图片上传失败
class ImageUploadFailed extends StorekeeperNonProjectEvent {
  final String error;

  const ImageUploadFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// 移除图片
class RemoveImage extends StorekeeperNonProjectEvent {
  const RemoveImage();
}

/// 更新描述
class UpdateDescription extends StorekeeperNonProjectEvent {
  final String description;

  const UpdateDescription(this.description);

  @override
  List<Object?> get props => [description];
}

/// 清空描述
class ClearDescription extends StorekeeperNonProjectEvent {
  const ClearDescription();
}

/// 提交入库
class SubmitEntry extends StorekeeperNonProjectEvent {
  const SubmitEntry();
}

/// 清除错误消息
class ClearErrorMessage extends StorekeeperNonProjectEvent {
  const ClearErrorMessage();
}

/// 清除操作消息
class ClearOperationMessage extends StorekeeperNonProjectEvent {
  const ClearOperationMessage();
}

/// 重置状态（用于完成入库后重新开始）
class ResetState extends StorekeeperNonProjectEvent {
  const ResetState();
}

/// 刷新页面（重新加载仓库列表，保持当前选择）
class RefreshPage extends StorekeeperNonProjectEvent {
  const RefreshPage();
}
