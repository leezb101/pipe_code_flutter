/*
 * @Author: LeeZB
 * @Date: 2025-07-27 11:26:37
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-28 15:56:10
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_apply_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_sign_in_vo.dart';

import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/dispatch/dispatch_detail_vo.dart';

abstract class DispatchRepository {
  Future<Result<DispatchDetailVo>> getDispatchDetail(int id);
  Future<Result<void>> doDispatch(DoDispatchApplyVo request);
  Future<Result<void>> auditDispatch(CommonDoBusinessAuditVO request);
  Future<Result<void>> doDispatchSignin(DoDispatchSignInVo request);
}
