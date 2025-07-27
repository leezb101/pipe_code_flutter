import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/dispatch/dispatch_detail_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_apply_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_sign_in_vo.dart';

abstract class DispatchApiService {
  Future<Result<DispatchDetailVo>> getDispatchDetail(int id);

  Future<Result<void>> doDispatch(DoDispatchApplyVo request);

  Future<Result<void>> auditDispatch(CommonDoBusinessAuditVO request);

  Future<Result<void>> doDispatchSignin(DoDispatchSignInVo request);
}
