import '../../../models/material/material_info_base.dart';
import '../../../models/common/result.dart';
import '../interfaces/material_handle_api_service.dart';

class MockMaterialHandleApiService implements MaterialHandleApiService {
  @override
  Future<Result<List<MaterialInfoBase>>> scanSingleToQueryAll(
    String code,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return Result(
      code: 0,
      msg: '成功',
      data: _generateMaterialInfoBaseList(null),
    );
  }

  @override
  Future<Result<List<MaterialInfoBase>>> scanBatchToQueryAll(
    List<String> codes,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return Result(
      code: 0,
      msg: '成功',
      data: _generateMaterialInfoBaseList(codes.length),
    );
  }

  List<MaterialInfoBase> _generateMaterialInfoBaseList(int? count) {
    return List.generate(count ?? 10, (index) {
      return MaterialInfoBase(
        materialCode: "35$index",
        deliveryNumber: "84$index",
        batchCode: "11$index",
        mfgNm: "cillum commodo laboris$index",
        purNm: "quis$index",
        prodStdNo: "laboris ad quis dolore$index",
        prodNm: "in$index",
        spec: "commodo proident est$index",
        pressLvl: "anim nisi$index",
        weight: "adipisicing magna ut$index",
      );
    });
  }
}
