import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/material/scan_identification_response.dart';
import 'package:pipe_code_flutter/models/recovery/material_categories.dart';
import 'package:pipe_code_flutter/models/recovery/vendors_map.dart';

abstract class RecoveryApiService {
  /// 步骤1，获取VendersMap
  Future<Result<VendorsMap>> getVendorsMap();

  /// 步骤2. 获取物料分类
  Future<Result<MaterialCategoriesList>> getMaterialCategories(String code);

  /// 步骤3. 提交全部字段，等待服务端确认，返回详细材料信息
  Future<Result<Map<String, dynamic>>> submitStep3Fields({
    required String code,
    required int type,
    required Map<String, dynamic> fields,
  });

  /// 步骤4. 正式提交，将step3的key也传入
  Future<Result<void>> submitStep4Fields(String qrCode, String key);
}
