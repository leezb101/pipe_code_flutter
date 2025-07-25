import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/signout/do_signout_request_vo.dart';
import 'package:pipe_code_flutter/models/signout/signout_info_vo.dart';
import 'package:pipe_code_flutter/services/api/interfaces/signout_api_service.dart';

class MockSignoutApiService implements SignoutApiService {
  @override
  Future<Result<void>> doSignout(DoSignoutRequestVo request) {
    // TODO: implement doSignout
    throw UnimplementedError();
  }

  @override
  Future<Result<SignoutInfoVo>> getSignoutDetail(int id) {
    // TODO: implement getSignoutDetail
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> auditSignout(CommonDoBusinessAuditVO request) {
    // TODO: implement auditSignout
    throw UnimplementedError();
  }
}
