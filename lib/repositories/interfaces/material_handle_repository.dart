import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';

abstract class MaterialHandleRepository {
  Future<Result<MaterialInfoForBusiness>> scanSingleToQueryAll(String code);
  Future<Result<MaterialInfoForBusiness>> scanBatchToQueryAll(
    List<String> codes,
  );
}
