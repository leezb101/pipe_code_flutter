import 'package:pipe_code_flutter/models/acceptance/sign_in_info_vo.dart';

abstract class SigninRepository {
  Future<SignInInfoVO> getSigninDetail(int id);
}
