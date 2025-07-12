/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:40:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:40:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:dio/dio.dart';
import '../interfaces/auth_api_service.dart';
import 'base_api_service.dart';
import '../../../models/common/result.dart';
import '../../../models/user/wx_login_vo.dart';
import '../../../models/user/current_user_on_project_role_info.dart';
import '../../../models/auth/login_account_vo.dart';
import '../../../models/auth/rf.dart';
import '../../../models/auth/captcha_result.dart';
import '../../../models/auth/sms_code_result.dart';
import '../../../utils/logger.dart';
import '../../../utils/network_logger.dart';

/// 认证API服务实现
/// 完全匹配API文档中的认证相关接口
class AuthApiServiceImpl extends BaseApiService implements AuthApiService {
  AuthApiServiceImpl(super.dio);

  @override
  Future<Result<WxLoginVO>> loginWithPassword(
    LoginAccountVO loginRequest, {
    String? imgCode,
  }) async {
    try {
      Logger.info('开始密码登录', tag: 'LOGIN');
      
      // 准备请求headers
      final headers = <String, dynamic>{};
      if (imgCode != null) {
        headers['img_code'] = imgCode;
        Logger.captcha('登录请求包含验证码标识', imgCode: imgCode);
      } else {
        Logger.warning('登录请求缺少验证码标识', tag: 'LOGIN');
      }
      
      final response = await dio.post(
        '/wx/login/unite/password',
        data: loginRequest.toJson(),
        options: Options(headers: headers),
      );
      
      Logger.info('密码登录请求完成', tag: 'LOGIN');
      
      // 完整打印响应数据用于调试
      NetworkLogger.printFullJson(response.data, title: 'PASSWORD_LOGIN_RESPONSE');
      
      return Result.fromJson(response.data, (json) => WxLoginVO.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      Logger.error('密码登录网络错误: ${e.type}', tag: 'LOGIN', error: e);
      throw handleError(e);
    }
  }

  @override
  Future<Result<WxLoginVO>> loginWithSms(String phone, String code, {String? smsCode}) async {
    try {
      Logger.info('开始短信验证码登录', tag: 'SMS_LOGIN');
      
      // 准备请求headers
      final headers = <String, dynamic>{};
      if (smsCode != null) {
        headers['sms_code'] = smsCode;
        Logger.info('短信登录请求包含sms_code标识: ${smsCode.length > 8 ? '${smsCode.substring(0, 8)}...' : smsCode}', tag: 'SMS_LOGIN');
      } else {
        Logger.warning('短信登录请求缺少sms_code标识', tag: 'SMS_LOGIN');
      }
      
      final response = await dio.post(
        '/wx/login/sms/$phone/$code',
        options: Options(headers: headers),
      );
      
      Logger.info('短信登录请求完成', tag: 'SMS_LOGIN');
      
      // 完整打印响应数据用于调试
      NetworkLogger.printFullJson(response.data, title: 'SMS_LOGIN_RESPONSE');
      
      return Result.fromJson(response.data, (json) => WxLoginVO.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      Logger.error('短信登录网络错误: ${e.type}', tag: 'SMS_LOGIN', error: e);
      throw handleError(e);
    }
  }

  @override
  Future<Result<SmsCodeResult>> requestSmsCode(String phone) async {
    try {
      Logger.info('开始请求短信验证码', tag: 'SMS_CODE');
      
      final response = await dio.get('/wx/sms/$phone');
      
      // 专门检查短信验证码接口的响应
      Logger.info('短信验证码接口响应状态: ${response.statusCode}', tag: 'SMS_CODE');
      
      // 检查header中的sms_code字段
      final smsCode = response.headers.value('sms_code');
      if (smsCode == null || smsCode.isEmpty) {
        Logger.error('短信验证码header字段未找到: sms_code', tag: 'SMS_CODE');
        Logger.warning('可用的response headers: ${response.headers.map.keys.join(', ')}', tag: 'SMS_CODE');
        return const Result(
          code: -1,
          msg: '短信验证码接口缺少sms_code header字段',
          tc: 0,
          data: null,
        );
      }
      
      Logger.info('短信验证码header字段已找到: ${smsCode.length > 8 ? '${smsCode.substring(0, 8)}...' : smsCode}', tag: 'SMS_CODE');
      
      // 检查响应体中的数据
      final apiResult = Result.fromJson(response.data, (json) => json);
      if (apiResult.isSuccess) {
        // 创建SmsCodeResult对象
        final smsCodeResult = SmsCodeResult.create(
          phone: phone,
          smsCode: smsCode,
          message: apiResult.msg,
        );
        
        Logger.info('短信验证码完整数据构建成功: ${smsCodeResult.toString()}', tag: 'SMS_CODE');
        
        return Result(
          code: apiResult.code,
          msg: apiResult.msg,
          tc: apiResult.tc,
          data: smsCodeResult,
        );
      } else {
        Logger.error('短信验证码接口返回失败: ${apiResult.msg}', tag: 'SMS_CODE');
        return Result(
          code: apiResult.code,
          msg: apiResult.msg,
          tc: apiResult.tc,
          data: null,
        );
      }
    } on DioException catch (e) {
      Logger.error('短信验证码请求网络错误: ${e.type}', tag: 'SMS_CODE', error: e);
      throw handleError(e);
    }
  }

  @override
  Future<Result<CaptchaResult>> requestCaptcha() async {
    try {
      Logger.info('开始请求图形验证码', tag: 'CAPTCHA');
      
      final response = await dio.get('/wx/login/getCodeImg');
      
      // 专门检查验证码接口的响应
      NetworkLogger.logCaptchaResponse(response);
      
      // 检查header中的img_code字段
      final imgCode = response.headers.value('img_code');
      if (imgCode == null || imgCode.isEmpty) {
        Logger.error('验证码header字段未找到: img_code', tag: 'CAPTCHA');
        Logger.warning('可用的response headers: ${response.headers.map.keys.join(', ')}', tag: 'CAPTCHA');
        return const Result(
          code: -1,
          msg: '验证码接口缺少img_code header字段',
          tc: 0,
          data: null,
        );
      }
      
      Logger.captcha('验证码header字段已找到', imgCode: imgCode);
      
      // 检查响应体中的数据
      final apiResult = Result.fromJson(response.data, (json) => json as String);
      if (apiResult.isSuccess && apiResult.data != null) {
        final base64Data = apiResult.data!;
        final dataSize = base64Data.length;
        Logger.captcha('验证码数据接收成功', dataSize: dataSize);
        
        // 验证base64格式
        try {
          if (base64Data.startsWith('data:image/') || base64Data.length > 100) {
            Logger.info('验证码数据格式验证通过', tag: 'CAPTCHA');
          }
        } catch (e) {
          Logger.warning('验证码数据格式可能异常: $e', tag: 'CAPTCHA');
        }
        
        // 创建CaptchaResult对象
        final captchaResult = CaptchaResult(
          base64Data: base64Data,
          imgCode: imgCode,
        );
        
        Logger.info('验证码完整数据构建成功: ${captchaResult.toString()}', tag: 'CAPTCHA');
        
        return Result(
          code: apiResult.code,
          msg: apiResult.msg,
          tc: apiResult.tc,
          data: captchaResult,
        );
      } else {
        Logger.error('验证码接口返回失败: ${apiResult.msg}', tag: 'CAPTCHA');
        return Result(
          code: apiResult.code,
          msg: apiResult.msg,
          tc: apiResult.tc,
          data: null,
        );
      }
    } on DioException catch (e) {
      Logger.error('验证码请求网络错误: ${e.type}', tag: 'CAPTCHA', error: e);
      throw handleError(e);
    }
  }

  @override
  Future<Result<WxLoginVO>> checkToken({String? tk}) async {
    try {
      final queryParams = tk != null ? {'tk': tk} : <String, dynamic>{};
      final response = await dio.get('/wx/check', queryParameters: queryParams);
      return Result.fromJson(response.data, (json) => WxLoginVO.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<Result<WxLoginVO>> refreshToken(RF refreshRequest) async {
    try {
      final response = await dio.post('/wx/rf', data: refreshRequest.toJson());
      return Result.fromJson(response.data, (json) => WxLoginVO.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<ResultBoolean> logout() async {
    try {
      final response = await dio.get('/wx/logout');
      return ResultBoolean.fromJson(response.data);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<ResultBoolean> logoff() async {
    try {
      final response = await dio.get('/wx/logoff');
      return ResultBoolean.fromJson(response.data);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<Result<CurrentUserOnProjectRoleInfo>> selectProject(int projectId) async {
    try {
      final response = await dio.get('/wx/select/$projectId');
      return Result.fromJson(response.data, (json) => CurrentUserOnProjectRoleInfo.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  @override
  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }
}