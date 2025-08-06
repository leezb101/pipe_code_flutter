/*
 * @Author: LeeZB
 * @Date: 2025-08-06 17:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 17:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import '../../services/api/interfaces/identification_api_service.dart';
import '../../services/api/interfaces/cut_api_service.dart';
import '../../repositories/interfaces/material_detail_repository.dart';
import '../../models/material/scan_identification_response.dart';
import '../../models/cut/pipe_cutting_record.dart';
import '../../utils/exceptions.dart';

class MaterialDetailRepositoryImpl implements MaterialDetailRepository {
  final IdentificationApiService _identificationApiService;
  final CutApiService _cutApiService;

  MaterialDetailRepositoryImpl(
    this._identificationApiService,
    this._cutApiService,
  );

  @override
  Future<ScanIdentificationData> getMaterialDetail(String materialCode) async {
    final result = await _identificationApiService.scanMaterialIdentification(materialCode);
    
    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw GetMaterialDetailException(result.msg);
    }
  }

  @override
  Future<PipeCuttingRecord> getCuttingHistory(String materialId) async {
    final result = await _cutApiService.getCuttingHistory(materialId);

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw GetCuttingHistoryException(result.msg);
    }
  }

  @override
  Future<MaterialDetailWithData> getMaterialDetailWithCuttingHistory(String materialCode) async {
    // 并行获取材料详情和截管记录
    final materialDetailFuture = getMaterialDetail(materialCode);
    final cuttingRecordFuture = getCuttingHistory(materialCode);

    try {
      final results = await Future.wait([
        materialDetailFuture,
        cuttingRecordFuture,
      ], eagerError: false);

      return MaterialDetailWithData(
        materialDetail: results[0] as ScanIdentificationData,
        cuttingRecord: results[1] as PipeCuttingRecord?,
      );
    } catch (e) {
      // 如果截管记录获取失败，至少返回材料详情
      final materialDetail = await materialDetailFuture;
      return MaterialDetailWithData(
        materialDetail: materialDetail,
        cuttingRecord: null,
      );
    }
  }
}