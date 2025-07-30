import 'package:pipe_code_flutter/services/api/interfaces/material_handle_api_service.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';

class MaterialHandleRepositoryImpl implements MaterialHandleRepository {
  final MaterialHandleApiService _materialHandleApiService;

  MaterialHandleRepositoryImpl(this._materialHandleApiService);

  @override
  Future<Result<MaterialInfoForBusiness>> scanSingleToQueryAll(String code) {
    return _materialHandleApiService.scanSingleToQueryAll(code);
  }

  @override
  Future<Result<MaterialInfoForBusiness>> scanBatchToQueryAll(
    List<String> codes,
  ) {
    return _materialHandleApiService.scanBatchToQueryAll(codes);
  }
}
