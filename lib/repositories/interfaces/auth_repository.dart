/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:25:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-28 15:36:14
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/user/wx_login_vo.dart';
import 'package:pipe_code_flutter/models/user/current_user_on_project_role_info.dart';
import 'package:pipe_code_flutter/models/auth/login_account_vo.dart';
import 'package:pipe_code_flutter/models/auth/rf.dart';
import 'package:pipe_code_flutter/models/auth/captcha_result.dart';
import 'package:pipe_code_flutter/models/auth/sms_code_result.dart';

abstract class AuthRepository {
  Future<Result<WxLoginVO>> loginWithPassword(
    LoginAccountVO loginRequest, {
    String? imgCode,
  });

  Future<Result<WxLoginVO>> loginWithSms(
    String phone,
    String code, {
    String? smsCode,
  });

  Future<Result<SmsCodeResult>> requestSmsCode(String phone);

  Future<Result<CaptchaResult>> requestCaptcha();

  Future<Result<CurrentUserOnProjectRoleInfo>> selectProject(
    int projectId,
  );

  Future<Result<WxLoginVO>> checkToken();

  Future<Result<WxLoginVO>> refreshToken(RF refreshRequest);

  Future<void> logout();

  Future<String?> getLastSelectedProjectId();

  Future<bool> isFirstLogin();

  Future<void> markAsLoggedIn();

  bool get isLoggedIn;
}
