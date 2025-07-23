import 'package:pipe_code_flutter/services/api/interfaces/material_handle_api_service.dart';

import '../models/common/result.dart';
import '../models/material/material_info_for_business.dart';

class MaterialHandleRepository {
  final MaterialHandleApiService _materialHandleApiService;

  MaterialHandleRepository(this._materialHandleApiService);

  /// 扫码查询所有物料信息
  Future<Result<MaterialInfoForBusiness>> scanSingleToQueryAll(String code) {
    return _materialHandleApiService.scanSingleToQueryAll(code);
  }

  /// 批量扫码查询所有物料信息
  /// [codes] 物料码列表
  Future<Result<MaterialInfoForBusiness>> scanBatchToQueryAll(
    List<String> codes,
  ) {
    return _materialHandleApiService.scanBatchToQueryAll(codes);
  }
}
