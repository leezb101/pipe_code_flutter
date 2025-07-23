/*
 * @Author: LeeZB
 * @Date: 2025-07-22 18:09:13
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-23 11:45:11
 * @copyright: Copyright © 2025 高新供水.
 */
import '../../../models/material/material_info_base.dart';
import '../../../models/material/material_info_for_business.dart';
import '../../../models/common/result.dart';
import '../../../models/material/sync_vendor_data_error.dart';
import '../interfaces/material_handle_api_service.dart';

class MockMaterialHandleApiService implements MaterialHandleApiService {
  @override
  Future<Result<MaterialInfoForBusiness>> scanSingleToQueryAll(
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
  Future<Result<MaterialInfoForBusiness>> scanBatchToQueryAll(
    List<String> codes,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return Result(
      code: 0,
      msg: '成功',
      data: _generateMaterialInfoBaseList(codes.length),
    );
  }

  MaterialInfoForBusiness _generateMaterialInfoBaseList(int? count) {
    return MaterialInfoForBusiness(
      normal: List.generate(count ?? 10, (index) {
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
      }),
      error: List.generate(2, (index) {
        return SyncVendorDataError(
          qrCode: "35$index",
          code: "XXZG",
          name: "新兴铸管",
          msg: '该管已报废$index',
        );
      }),
    );
  }
}
