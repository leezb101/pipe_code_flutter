/*
 * @Author: LeeZB
 * @Date: 2025-08-07 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-07 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/user/wx_login_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/user_repository.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

/// SSE认证帮助类
/// 负责为SSE连接提供认证支持
class SseAuthHelper {
  static const String _tag = 'SSE_AUTH_HELPER';
  static const String _tokenHeaderKey = 'tk';

  /// 获取认证头
  /// 返回用于SSE连接的认证头信息
  static Future<Map<String, String>> getAuthHeaders() async {
    try {
      // 检查UserRepository是否已注册
      if (!getIt.isRegistered<UserRepository>()) {
        Logger.warning(
          'UserRepository is not registered in service locator',
          tag: _tag,
        );
        return {};
      }

      final userRepository = getIt<UserRepository>();
      
      // 从缓存中获取用户数据
      final wxLoginVO = await userRepository.loadUserFromStorage();

      if (wxLoginVO != null && wxLoginVO.tk.isNotEmpty) {
        final headers = {
          _tokenHeaderKey: wxLoginVO.tk,
        };

        Logger.info(
          'Generated auth headers for SSE connection',
          tag: _tag,
        );

        return headers;
      } else {
        Logger.warning(
          'No valid token found for SSE authentication',
          tag: _tag,
        );
        return {};
      }
    } catch (e) {
      Logger.error(
        'Failed to generate auth headers: ${e.toString()}',
        tag: _tag,
      );
      return {};
    }
  }

  /// 检查是否已认证
  /// 返回用户是否已登录且token有效
  static Future<bool> isAuthenticated() async {
    try {
      if (!getIt.isRegistered<UserRepository>()) {
        return false;
      }

      final userRepository = getIt<UserRepository>();
      final wxLoginVO = await userRepository.loadUserFromStorage();

      return wxLoginVO != null && 
             wxLoginVO.tk.isNotEmpty && 
             wxLoginVO.own;
    } catch (e) {
      Logger.error(
        'Failed to check authentication status: ${e.toString()}',
        tag: _tag,
      );
      return false;
    }
  }

  /// 获取当前用户信息
  /// 返回当前登录用户的WxLoginVO信息
  static Future<WxLoginVO?> getCurrentUser() async {
    try {
      if (!getIt.isRegistered<UserRepository>()) {
        return null;
      }

      final userRepository = getIt<UserRepository>();
      return await userRepository.loadUserFromStorage();
    } catch (e) {
      Logger.error(
        'Failed to get current user: ${e.toString()}',
        tag: _tag,
      );
      return null;
    }
  }

  /// 检查用户是否有权限接收通知
  /// 根据WxLoginVO的own字段判断
  static Future<bool> hasNotificationPermission() async {
    try {
      final wxLoginVO = await getCurrentUser();
      return wxLoginVO?.own ?? false;
    } catch (e) {
      Logger.error(
        'Failed to check notification permission: ${e.toString()}',
        tag: _tag,
      );
      return false;
    }
  }

  /// 获取用户ID
  /// 返回当前用户的ID，用于日志和调试
  static Future<String?> getUserId() async {
    try {
      final wxLoginVO = await getCurrentUser();
      return wxLoginVO?.id;
    } catch (e) {
      Logger.error(
        'Failed to get user ID: ${e.toString()}',
        tag: _tag,
      );
      return null;
    }
  }

  /// 刷新认证信息
  /// 强制从存储重新加载用户信息
  static Future<bool> refreshAuthInfo() async {
    try {
      if (!getIt.isRegistered<UserRepository>()) {
        return false;
      }

      final userRepository = getIt<UserRepository>();
      
      // 刷新缓存并重新加载
      userRepository.refreshCache();
      final wxLoginVO = await userRepository.loadUserFromStorage();

      final isValid = wxLoginVO != null && 
                     wxLoginVO.tk.isNotEmpty && 
                     wxLoginVO.own;

      Logger.info(
        'Auth info refreshed, isValid: $isValid',
        tag: _tag,
      );

      return isValid;
    } catch (e) {
      Logger.error(
        'Failed to refresh auth info: ${e.toString()}',
        tag: _tag,
      );
      return false;
    }
  }

  /// 验证token格式
  /// 检查token是否符合基本格式要求
  static bool validateTokenFormat(String token) {
    if (token.isEmpty) {
      return false;
    }

    // 基本格式检查：非空且不包含空格
    return token.trim().isNotEmpty && !token.contains(' ');
  }

  /// 获取认证信息摘要
  /// 用于日志记录（不包含敏感信息）
  static Future<Map<String, dynamic>> getAuthSummary() async {
    try {
      final wxLoginVO = await getCurrentUser();
      
      if (wxLoginVO == null) {
        return {'status': 'not_authenticated'};
      }

      return {
        'status': 'authenticated',
        'userId': wxLoginVO.id,
        'hasToken': wxLoginVO.tk.isNotEmpty,
        'hasPermission': wxLoginVO.own,
        'tokenValid': validateTokenFormat(wxLoginVO.tk),
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// 清除认证信息
  /// 用于登出时清理
  static Future<void> clearAuthInfo() async {
    try {
      if (getIt.isRegistered<UserRepository>()) {
        final userRepository = getIt<UserRepository>();
        await userRepository.clearUserData();
      }

      Logger.info('Auth info cleared', tag: _tag);
    } catch (e) {
      Logger.error(
        'Failed to clear auth info: ${e.toString()}',
        tag: _tag,
      );
    }
  }
}