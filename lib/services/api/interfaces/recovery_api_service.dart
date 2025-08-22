import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/recovery/material_categories.dart';
import 'package:pipe_code_flutter/models/recovery/vendors_map.dart';

abstract class RecoveryApiService {
  /// 步骤1，获取VendersMap
  Future<Result<VendorsMap>> getVendorsMap();

  /// 步骤2. 获取物料分类
  Future<Result<MaterialCategoriesList>> getMaterialCategories(String code);
}
