/*
 * @Author: LeeZB
 * @Date: 2025-07-09 10:15:25
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-16 10:06:58
 * @copyright: Copyright © 2025 高新供水.
 */
/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:35:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:35:00
 * @copyright: Copyright © 2025 高新供水.
 */
import '../../../models/common/result.dart';
import '../../../models/user/wx_login_vo.dart';
import '../../../models/user/current_user_on_project_role_info.dart';
import '../../../models/auth/login_account_vo.dart';
import '../../../models/auth/rf.dart';
import '../../../models/auth/captcha_result.dart';
import '../../../models/auth/sms_code_result.dart';

/// 认证API服务接口
/// 完全匹配API文档中的认证相关接口
abstract class AuthApiService {
  /// 账号密码登录
  /// POST /wx/login/unite/password
  /// [imgCode] 验证码标识符，来自验证码接口response header的img_code字段
  Future<Result<WxLoginVO>> loginWithPassword(
    LoginAccountVO loginRequest, {
    String? imgCode,
  });

  /// 短信验证码登录
  /// POST /wx/login/sms/{phone}/{code}
  /// [smsCode] SMS验证码标识符，来自短信验证码接口response header的sms_code字段
  Future<Result<WxLoginVO>> loginWithSms(
    String phone,
    String code, {
    String? smsCode,
  });

  /// 获取短信验证码
  /// GET /wx/sms/{phone}
  /// 返回包含sms_code标识符的完整结果
  Future<Result<SmsCodeResult>> requestSmsCode(String phone);

  /// 获取图片验证码
  /// GET /wx/login/getCodeImg
  /// 返回包含base64图片数据和img_code标识符的完整结果
  Future<Result<CaptchaResult>> requestCaptcha();

  /// 验证用户是否登录
  /// GET /wx/check
  Future<Result<WxLoginVO>> checkToken({String? tk});

  /// 刷新用户token
  /// POST /wx/rf
  Future<Result<WxLoginVO>> refreshToken(RF refreshRequest);

  /// 登出
  /// GET /wx/logout
  Future<ResultBoolean> logout();

  /// 注销用户
  /// GET /wx/logoff
  Future<ResultBoolean> logoff();

  /// 登录后选中项目
  /// GET /wx/select/{projectId}
  Future<Result<CurrentUserOnProjectRoleInfo>> selectProject(int projectId);

  /// 设置认证token
  void setAuthToken(String token);

  /// 清除认证token
  void clearAuthToken();
}
