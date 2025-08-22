import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/recovery/material_categories.dart';
import 'package:pipe_code_flutter/models/recovery/vendors_map.dart';
import 'package:pipe_code_flutter/services/api/interfaces/recovery_api_service.dart';

class MockRecoveryApiService implements RecoveryApiService {
  @override
  Future<Result<MaterialCategoriesList>> getMaterialCategories(String code) {
    // TODO: implement getMaterialCategories
    throw UnimplementedError();
  }

  @override
  Future<Result<VendorsMap>> getVendorsMap() {
    // TODO: implement getVendorsMap
    throw UnimplementedError();
  }
}
