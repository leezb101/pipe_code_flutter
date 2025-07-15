/*
 * @Author: LeeZB
 * @Date: 2025-07-14 17:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 17:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:dio/dio.dart';
import '../config/service_locator.dart';
import '../repositories/user_repository.dart';
import 'logger.dart';

/// 认证拦截器
/// 自动为已认证的请求添加 tk token 到 headers 中
class AuthInterceptor extends Interceptor {
  static const String _tag = 'AUTH_INTERCEPTOR';
  static const String _tokenHeaderKey = 'tk';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // 获取用户仓库实例
      final userRepository = getIt<UserRepository>();
      
      // 尝试从缓存中获取用户数据
      final wxLoginVO = await userRepository.loadUserFromStorage();
      
      if (wxLoginVO != null && wxLoginVO.tk.isNotEmpty) {
        // 如果用户已登录且有token，添加到headers中
        options.headers[_tokenHeaderKey] = wxLoginVO.tk;
        
        Logger.info(
          'Added token to request: ${options.method} ${options.path}',
          tag: _tag,
        );
      } else {
        Logger.debug(
          'No token found for request: ${options.method} ${options.path}',
          tag: _tag,
        );
      }
    } catch (e) {
      // 如果获取token失败，记录错误但不阻断请求
      Logger.warning(
        'Failed to get token for request: ${options.method} ${options.path} - Error: $e',
        tag: _tag,
      );
    }
    
    // 继续处理请求
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 如果是401未授权错误，可能是token过期
    if (err.response?.statusCode == 401) {
      Logger.warning(
        'Received 401 Unauthorized - Token may be expired or invalid',
        tag: _tag,
      );
      
      // 这里可以触发token刷新或重新登录逻辑
      // 暂时只记录日志，具体处理逻辑可以后续完善
    }
    
    handler.next(err);
  }
}