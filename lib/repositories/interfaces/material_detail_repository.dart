/*
 * @Author: LeeZB
 * @Date: 2025-08-06 17:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 17:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import '../../models/material/scan_identification_response.dart';
import '../../models/cut/pipe_cutting_record.dart';

abstract class MaterialDetailRepository {
  /// 获取材料详情（替代直接传入数据的方式）
  Future<ScanIdentificationData> getMaterialDetail(String materialCode);
  
  /// 获取截管记录
  Future<PipeCuttingRecord> getCuttingHistory(String materialId);
  
  /// 批量获取材料详情和截管记录（减少网络请求）
  Future<MaterialDetailWithData> getMaterialDetailWithCuttingHistory(String materialCode);
}

/// 辅助数据类，包含材料详情和截管记录
class MaterialDetailWithData {
  final ScanIdentificationData materialDetail;
  final PipeCuttingRecord? cuttingRecord;
  
  MaterialDetailWithData({
    required this.materialDetail,
    this.cuttingRecord,
  });
}