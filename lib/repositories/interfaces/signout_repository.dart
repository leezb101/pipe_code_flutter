/*
 * @Author: LeeZB
 * @Date: 2025-07-24 19:39:02
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 19:29:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/common/warehouse_user_info_vo.dart';
import 'package:pipe_code_flutter/models/common/warehouse_vo.dart';
import 'package:pipe_code_flutter/models/signout/do_signout_request_vo.dart';
import 'package:pipe_code_flutter/models/signout/signout_info_vo.dart';

abstract class SignoutRepository {
  Future<Result<SignoutInfoVo>> getSignoutDetail(int id);
  Future<Result<void>> doSignout(DoSignoutRequestVo request);
  Future<Result<void>> auditSignout(CommonDoBusinessAuditVO request);
  Future<Result<WarehouseUserInfoVO>> getWarehouseUsers(int warehouseId);
  Future<Result<WarehouseVO>> getWarehouseInfoByMaterialId(
    int materialId,
  );
}
