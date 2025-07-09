/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:25:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 23:25:00
 * @copyright: Copyright © 2025 高新供水.
 */
import '../models/common/result.dart';
import '../models/user/wx_login_vo.dart';
import '../models/user/current_user_on_project_role_info.dart';
import '../models/auth/login_account_vo.dart';
import '../models/auth/rf.dart';
import '../services/api/interfaces/api_service_interface.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiServiceInterface _apiService;
  final StorageService _storageService;

  AuthRepository({
    required ApiServiceInterface apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  /// 账号密码登录
  Future<Result<WxLoginVO>> loginWithPassword(LoginAccountVO loginRequest) async {
    try {
      final result = await _apiService.auth.loginWithPassword(loginRequest);
      
      if (result.isSuccess && result.data != null) {
        // 保存token
        await _storageService.saveAuthToken(result.data!.tk);
        _apiService.auth.setAuthToken(result.data!.tk);
        
        // 保存用户信息
        await _storageService.saveUserData(result.data!.toJson());
      }
      
      return result;
    } catch (e) {
      return Result(
        code: -1,
        msg: e.toString(),
        tc: 0,
        data: null,
      );
    }
  }

  /// 短信验证码登录
  Future<Result<WxLoginVO>> loginWithSms(String phone, String code) async {
    try {
      final result = await _apiService.auth.loginWithSms(phone, code);
      
      if (result.isSuccess && result.data != null) {
        // 保存token
        await _storageService.saveAuthToken(result.data!.tk);
        _apiService.auth.setAuthToken(result.data!.tk);
        
        // 保存用户信息
        await _storageService.saveUserData(result.data!.toJson());
      }
      
      return result;
    } catch (e) {
      return Result(
        code: -1,
        msg: e.toString(),
        tc: 0,
        data: null,
      );
    }
  }

  /// 请求短信验证码
  Future<Result<void>> requestSmsCode(String phone) async {
    try {
      return await _apiService.auth.requestSmsCode(phone);
    } catch (e) {
      return Result(
        code: -1,
        msg: e.toString(),
        tc: 0,
        data: null,
      );
    }
  }

  /// 选择项目
  Future<Result<CurrentUserOnProjectRoleInfo>> selectProject(int projectId) async {
    try {
      final result = await _apiService.auth.selectProject(projectId);
      
      if (result.isSuccess && result.data != null) {
        // 保存项目选择信息
        await _storageService.saveString('last_selected_project_id', projectId.toString());
        await _storageService.saveString('current_project_role_info', result.data!.toJson().toString());
      }
      
      return result;
    } catch (e) {
      return Result(
        code: -1,
        msg: e.toString(),
        tc: 0,
        data: null,
      );
    }
  }

  /// 检查token有效性
  Future<Result<WxLoginVO>> checkToken() async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) {
        return const Result(
          code: 401,
          msg: '未登录',
          tc: 0,
          data: null,
        );
      }
      
      return await _apiService.auth.checkToken(tk: token);
    } catch (e) {
      return Result(
        code: -1,
        msg: e.toString(),
        tc: 0,
        data: null,
      );
    }
  }

  /// 刷新token
  Future<Result<WxLoginVO>> refreshToken(RF refreshRequest) async {
    try {
      final result = await _apiService.auth.refreshToken(refreshRequest);
      
      if (result.isSuccess && result.data != null) {
        // 更新token
        await _storageService.saveAuthToken(result.data!.tk);
        _apiService.auth.setAuthToken(result.data!.tk);
        
        // 更新用户信息
        await _storageService.saveUserData(result.data!.toJson());
      }
      
      return result;
    } catch (e) {
      return Result(
        code: -1,
        msg: e.toString(),
        tc: 0,
        data: null,
      );
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _apiService.auth.logout();
    } catch (e) {
      // 即使服务器端登出失败，也要清除本地数据
    } finally {
      // 清除本地数据
      await _storageService.clearAuthToken();
      await _storageService.clearUserData();
      await _storageService.remove('last_selected_project_id');
      await _storageService.remove('current_project_role_info');
      _apiService.auth.clearAuthToken();
    }
  }

  /// 获取最后选择的项目ID
  Future<String?> getLastSelectedProjectId() async {
    return _storageService.getString('last_selected_project_id');
  }

  /// 检查是否为首次登录
  Future<bool> isFirstLogin() async {
    final lastProjectId = await getLastSelectedProjectId();
    return lastProjectId == null;
  }

  /// 标记已登录过
  Future<void> markAsLoggedIn() async {
    await _storageService.setBool('has_logged_in_before', true);
  }

  /// 检查是否已登录
  bool get isLoggedIn {
    // 这里可以检查token是否存在
    // 实际实现可能需要异步检查
    return true; // 简化实现
  }
}