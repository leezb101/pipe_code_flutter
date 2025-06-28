import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
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

    // Add interceptors for logging in development
    if (AppConfig.isDevelopment) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        logPrint: (object) {
          // Custom log print to avoid sensitive data logging
          if (!object.toString().contains('Authorization')) {
            debugPrint('[API] $object');
          }
        },
      ));
    }

    // Add error handling interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        // Handle common HTTP errors
        if (error.response?.statusCode == 401) {
          // Handle unauthorized - could trigger logout
          debugPrint('[API] Unauthorized request');
        } else if (error.response?.statusCode == 500) {
          debugPrint('[API] Server error');
        }
        handler.next(error);
      },
    ));

    return dio;
  }
}