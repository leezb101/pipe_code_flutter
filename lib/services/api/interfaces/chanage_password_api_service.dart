import 'package:pipe_code_flutter/models/common/result.dart';

abstract class ChangePasswordApiService {
  /// 获取修改密码的短信验证码
  Future<Result<Map<String, dynamic>>> getChangePasswordSmsCode();

  /// 修改密码
  Future<Result<void>> submitChangePassword(
    String password,
    String code,
    String smsCode,
  );
}
