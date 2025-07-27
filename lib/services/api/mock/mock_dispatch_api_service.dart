import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/dispatch/dispatch_detail_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_apply_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_sign_in_vo.dart';
import 'package:pipe_code_flutter/services/api/interfaces/dispatch_api_service.dart';

class MockDispatchApiService implements DispatchApiService {
  @override
  Future<Result<void>> doDispatch(DoDispatchApplyVo request) {
    // TODO: implement doDispatch
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> doDispatchSignin(DoDispatchSignInVo request) {
    // TODO: implement doDispatchSignin
    throw UnimplementedError();
  }

  @override
  Future<Result<DispatchDetailVo>> getDispatchDetail(int id) {
    // TODO: implement getDispatchDetail
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> auditDispatch(CommonDoBusinessAuditVO request) {
    // TODO: implement auditDispatch
    throw UnimplementedError();
  }
}
