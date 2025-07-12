/*
 * @Author: LeeZB
 * @Date: 2025-06-28 13:17:21
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-02 12:33:31
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';
import '../utils/network_logger.dart';
import 'api/interfaces/api_service_interface.dart';
import 'api/implementations/api_service_impl.dart';
import 'api/mock/mock_api_service.dart';

class ApiServiceFactory {
  static ApiServiceInterface create() {
    if (AppConfig.isMockEnabled) {
      return MockApiService();
    } else {
      final dio = _createDio();
      return ApiServiceImpl(dio);
    }
  }

  static Dio _createDio() {
    final dio = Dio();

    // Base configuration
    dio.options.baseUrl = AppConfig.apiBaseUrl;
    dio.options.connectTimeout = AppConfig.apiTimeout;
    dio.options.receiveTimeout = AppConfig.apiTimeout;
    dio.options.headers.addAll(AppConfig.defaultHeaders);

    // Add enhanced network logging interceptor in development
    if (AppConfig.isDevelopment) {
      // Use our custom network logger with detailed formatting
      dio.interceptors.add(NetworkLogger.createNetworkInterceptor());
      
      // Log Dio configuration
      Logger.info('Dio configured with base URL: ${AppConfig.apiBaseUrl}', tag: 'NETWORK');
      Logger.info('Request timeout: ${AppConfig.apiTimeout}', tag: 'NETWORK');
    }

    // Add error handling interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Handle common HTTP errors
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - could trigger logout
            Logger.warning('Unauthorized request', tag: 'API');
          } else if (error.response?.statusCode == 500) {
            Logger.error('Server error', tag: 'API');
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}
