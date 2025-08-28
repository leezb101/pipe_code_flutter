import 'package:pipe_code_flutter/models/acceptance/sign_in_info_vo.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/services/api/interfaces/signin_api_service.dart';

class MockSigninApiService implements SigninApiService {
  @override
  Future<Result<SignInInfoVO>> getSigninDetail(int id) {
    // TODO: implement getSigninDetail
    throw UnimplementedError();
  }
}
