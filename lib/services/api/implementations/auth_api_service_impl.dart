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

/// 认证API服务实现
/// 完全匹配API文档中的认证相关接口
class AuthApiServiceImpl extends BaseApiService implements AuthApiService {
  AuthApiServiceImpl(super.dio);

  @override
  Future<Result<WxLoginVO>> loginWithPassword(LoginAccountVO loginRequest) async {
    try {
      final response = await dio.post('/wx/login/unite/password', data: loginRequest.toJson());
      return Result.fromJson(response.data, (json) => WxLoginVO.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<Result<WxLoginVO>> loginWithSms(String phone, String code) async {
    try {
      final response = await dio.post('/wx/login/sms/$phone/$code');
      return Result.fromJson(response.data, (json) => WxLoginVO.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<Result<void>> requestSmsCode(String phone) async {
    try {
      final response = await dio.get('/wx/sms/$phone');
      return Result.fromJson(response.data, (json) => null);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<Result<String>> requestCaptcha() async {
    try {
      final response = await dio.get('/wx/login/getCodeImg');
      return Result.fromJson(response.data, (json) => json as String);
    } on DioException catch (e) {
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