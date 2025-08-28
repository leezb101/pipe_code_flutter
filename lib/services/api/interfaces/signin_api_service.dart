import 'package:pipe_code_flutter/models/acceptance/sign_in_info_vo.dart';
import 'package:pipe_code_flutter/models/common/result.dart';

abstract class SigninApiService {
  Future<Result<SignInInfoVO>> getSigninDetail(int id);
}
