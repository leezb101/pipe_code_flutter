/*
 * @Author: LeeZB
 * @Date: 2025-08-23 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-23 15:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/storekeeperActions/storekeeper_warehouse_item.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';

/// 仓管员非项目入库Repository接口
abstract class StorekeeperNonProjectRepository {
  /// 获取仓管员管理的仓库列表
  Future<Result<List<StorekeeperWarehouseItem>>> getStorekeeperWarehouses();

  /// 处理扫码操作获取物料信息
  /// [codes] 扫码得到的二维码字符串列表
  /// [operation] 操作类型：初次扫码、追加扫码、移除扫码
  /// [currentMaterials] 当前已有的物料列表（用于去重和匹配）
  Future<Result<MaterialProcessResult>> processScannedMaterials(
    List<String> codes,
    QrScanOperation operation,
    List<MaterialInfo> currentMaterials,
  );

  /// 校验提交数据的完整性
  /// [warehouseId] 选择的仓库ID
  /// [materials] 物料列表
  /// [imageUrl] 上传的图片URL
  /// [description] 描述信息
  Result<void> validateSubmissionData({
    required int warehouseId,
    required List<MaterialInfo> materials,
    required String imageUrl,
    String? description,
  });

  /// 提交非项目入库
  /// [warehouseId] 仓库ID
  /// [materials] 物料列表
  /// [imageUrl] 图片URL
  /// [description] 描述信息
  Future<Result<void>> submitNonProjectEntry({
    required int warehouseId,
    required List<MaterialInfo> materials,
    required String imageUrl,
    String? description,
  });
}

/// 物料处理结果模型
class MaterialProcessResult {
  const MaterialProcessResult({
    required this.operation,
    required this.processedMaterials,
    required this.addedCount,
    required this.removedCount,
    required this.duplicateCount,
    required this.skippedCount,
    this.duplicateCodes = const [],
    this.skippedCodes = const [],
    this.errorMessages = const [],
  });

  /// 操作类型
  final QrScanOperation operation;

  /// 处理后的物料列表（最终结果）
  final List<MaterialInfo> processedMaterials;

  /// 新增物料数量
  final int addedCount;

  /// 移除物料数量
  final int removedCount;

  /// 重复物料数量
  final int duplicateCount;

  /// 跳过物料数量（如移除时不存在的物料）
  final int skippedCount;

  /// 重复的二维码列表
  final List<String> duplicateCodes;

  /// 跳过的二维码列表
  final List<String> skippedCodes;

  /// 错误消息列表
  final List<String> errorMessages;

  /// 是否有操作结果
  bool get hasChanges => addedCount > 0 || removedCount > 0;

  /// 是否有需要提示的信息
  bool get hasNotifications =>
      duplicateCount > 0 || skippedCount > 0 || errorMessages.isNotEmpty;

  /// 获取操作摘要消息
  String getOperationSummary() {
    switch (operation) {
      case QrScanOperation.initial:
        return '初次扫码完成，共添加 $addedCount 个物料';
      case QrScanOperation.append:
        final parts = <String>[];
        if (addedCount > 0) parts.add('新增 $addedCount 个物料');
        if (duplicateCount > 0) parts.add('忽略 $duplicateCount 个重复物料');
        return parts.isNotEmpty ? parts.join('，') : '没有新增物料';
      case QrScanOperation.remove:
        final parts = <String>[];
        if (removedCount > 0) parts.add('移除 $removedCount 个物料');
        if (skippedCount > 0) parts.add('跳过 $skippedCount 个不存在物料');
        return parts.isNotEmpty ? parts.join('，') : '没有移除物料';
    }
  }
}
