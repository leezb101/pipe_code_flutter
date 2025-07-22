/*
 * @Author: LeeZB
 * @Date: 2025-07-22 17:52:47
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-22 17:56:54
 * @copyright: Copyright © 2025 高新供水.
 */
import '../../../models/material/material_info_base.dart';
import '../../../models/common/result.dart';

abstract class MaterialHandleApiService {
  /// 在业务操作中扫描一个物料码获取整批物料信息
  ///
  /// [code] 单个物料码
  ///
  /// 返回物料信息列表，只包含基础属性[MaterialInfoBase]
  Future<Result<List<MaterialInfoBase>>> scanSingleToQueryAll(String code);

  /// 在业务操作中批量扫描记录物料码后获取对应批量物料信息
  ///
  /// [codes] 物料码列表
  ///
  /// 返回物料信息列表，只包含基础属性[MaterialInfoBase]
  Future<Result<List<MaterialInfoBase>>> scanBatchToQueryAll(
    List<String> codes,
  );
}
