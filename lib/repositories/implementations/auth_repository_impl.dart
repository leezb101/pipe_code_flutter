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
import 'package:pipe_code_flutter/services/api/interfaces/api_service_interface.dart';
import 'package:pipe_code_flutter/services/storage_service.dart';
import 'package:pipe_code_flutter/repositories/interfaces/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiServiceInterface _apiService;
  final StorageService _storageService;

  AuthRepositoryImpl({
    required ApiServiceInterface apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  @override
  Future<Result<WxLoginVO>> loginWithPassword(
    LoginAccountVO loginRequest, {
    String? imgCode,
  }) async {
    try {
      final result = await _apiService.auth.loginWithPassword(
        loginRequest,
        imgCode: imgCode,
      );

      if (result.isSuccess && result.data != null) {
        // 保存token
        await _storageService.saveAuthToken(result.data!.tk);
        _apiService.auth.setAuthToken(result.data!.tk);

        // 保存用户信息
        await _storageService.saveUserData(result.data!.toJson());
      }

      return result;
    } catch (e) {
      return Result(code: -1, msg: '登录失败，请稍后再试', data: null);
    }
  }

  @override
  Future<Result<WxLoginVO>> loginWithSms(
    String phone,
    String code, {
    String? smsCode,
  }) async {
    try {
      final result = await _apiService.auth.loginWithSms(
        phone,
        code,
        smsCode: smsCode,
      );

      if (result.isSuccess && result.data != null) {
        // 保存token
        await _storageService.saveAuthToken(result.data!.tk);
        _apiService.auth.setAuthToken(result.data!.tk);

        // 保存用户信息
        await _storageService.saveUserData(result.data!.toJson());
      }

      return result;
    } catch (e) {
      return Result(code: -1, msg: '登录失败，请稍后再试', data: null);
    }
  }

  @override
  Future<Result<SmsCodeResult>> requestSmsCode(String phone) async {
    try {
      return await _apiService.auth.requestSmsCode(phone);
    } catch (e) {
      return Result(code: -1, msg: e.toString(), data: null);
    }
  }

  @override
  Future<Result<CaptchaResult>> requestCaptcha() async {
    try {
      return await _apiService.auth.requestCaptcha();
    } catch (e) {
      return Result(code: -1, msg: e.toString(), data: null);
    }
  }

  @override
  Future<Result<CurrentUserOnProjectRoleInfo>> selectProject(
    int projectId,
  ) async {
    try {
      final result = await _apiService.auth.selectProject(projectId);

      if (result.isSuccess && result.data != null) {
        // 迁移旧数据（一次性）并按用户隔离保存项目选择信息
        await _storageService.migrateProjectRelatedKeys();

        // 保存到用户隔离的key
        await _storageService.setUserString(
          'last_selected_project_id',
          projectId.toString(),
        );
        // 同步记录选择时间戳（毫秒）用于TTL控制（60天）
        await _storageService.setUserInt(
          'last_selected_project_id_ts',
          DateTime.now().millisecondsSinceEpoch,
        );
        await _storageService.setUserString(
          'current_project_role_info',
          _storageService.encodeJsonString(result.data!.toJson()),
        );
      }

      return result;
    } catch (e) {
      return Result(code: -1, msg: '登录失败，请稍后再试', data: null);
    }
  }

  @override
  Future<Result<WxLoginVO>> checkToken() async {
    try {
      final token = _storageService.getAuthToken();
      if (token == null) {
        return const Result(code: 401, msg: '未登录', data: null);
      }

      return await _apiService.auth.checkToken(tk: token);
    } catch (e) {
      return Result(code: -1, msg: e.toString(), data: null);
    }
  }

  @override
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
      return Result(code: -1, msg: '登录失败，请稍后再试', data: null);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiService.auth.logout();
    } catch (e) {
      // 即使服务器端登出失败，也要清除本地数据
    } finally {
      // 清除本地数据
      await _storageService.clearAuthToken();
      await _storageService.clearUserData();
      // 清理用户隔离数据（保留 last_selected_project_id 以优化回访体验）
      await _storageService.removeUserKey('current_project_role_info');
      await _storageService.remove('last_selected_project_id');
      await _storageService.remove('current_project_role_info');
      _apiService.auth.clearAuthToken();
    }
  }

  @override
  Future<String?> getLastSelectedProjectId() async {
    // 优先读取用户隔离key并检查TTL（60天）
    const ttlDays = 60;
    final scoped = _storageService.getUserString('last_selected_project_id');
    if (scoped != null) {
      final ts = _storageService.getUserInt('last_selected_project_id_ts');
      if (ts != null) {
        final savedAt = DateTime.fromMillisecondsSinceEpoch(ts);
        final isExpired = DateTime.now().difference(savedAt).inDays > ttlDays;
        if (isExpired) {
          // 过期即清除并返回null
          await _storageService.removeUserKey('last_selected_project_id');
          await _storageService.removeUserKey('last_selected_project_id_ts');
          return null;
        }
      }
      return scoped;
    }

    // scoped 不存在时尝试迁移旧键，再读一次（旧键无时间戳则视为无TTL，迁移后开始记录）
    await _storageService.migrateLegacyKeyToUserScoped(
      'last_selected_project_id',
    );
    final migrated = _storageService.getUserString('last_selected_project_id');
    if (migrated != null) {
      // 对于迁移过来的旧值，写入当前时间为起点
      await _storageService.setUserInt(
        'last_selected_project_id_ts',
        DateTime.now().millisecondsSinceEpoch,
      );
      return migrated;
    }

    // 最后兜底读取旧全局键
    return _storageService.getString('last_selected_project_id');
  }

  @override
  Future<bool> isFirstLogin() async {
    final lastProjectId = await getLastSelectedProjectId();
    return lastProjectId == null;
  }

  @override
  Future<void> markAsLoggedIn() async {
    await _storageService.setBool('has_logged_in_before', true);
  }

  @override
  bool get isLoggedIn {
    // 这里可以检查token是否存在
    // 实际实现可能需要异步检查
    return true; // 简化实现
  }
}
