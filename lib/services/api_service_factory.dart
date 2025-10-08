/*
 * @Author: LeeZB
 * @Date: 2025-06-28 13:17:21
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 11:19:27
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/services/api/implementations/change_password_api_service_impl.dart';
import 'package:pipe_code_flutter/services/api/implementations/enum_api_service_impl.dart';
import 'package:pipe_code_flutter/services/api/implementations/install_api_service_impl.dart';
import 'package:pipe_code_flutter/services/api/implementations/inventory_api_service_impl.dart';
import 'package:pipe_code_flutter/services/api/implementations/map_api_service_impl.dart';
import 'package:pipe_code_flutter/services/api/implementations/scrap_api_service_impl.dart';
import 'package:pipe_code_flutter/services/api/implementations/signout_api_service_impl.dart';
import 'package:pipe_code_flutter/services/api/implementations/temporary_auth_api_service_impl.dart';
import 'package:pipe_code_flutter/services/api/interfaces/chanage_password_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/enum_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/install_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/inventory_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/map_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/profile_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/scrap_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/signout_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/temporary_auth_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_enum_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_install_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_inventory_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_map_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_profile_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_scrap_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_signout_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_temporary_auth_api_service.dart';
import 'package:pipe_code_flutter/utils/tracing_interceptor.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';
import '../utils/network_logger.dart';
import '../utils/auth_interceptor.dart';
import '../utils/location_interceptor.dart';
import 'api/implementations/dispatch_api_service_impl.dart';
import 'api/interfaces/api_service_interface.dart';
import 'api/implementations/api_service_impl.dart';
import 'api/interfaces/dispatch_api_service.dart';
import 'api/mock/mock_api_service.dart';
import 'api/interfaces/records_api_service.dart';
import 'api/implementations/real_records_api_service.dart';
import 'api/mock/mock_dispatch_api_service.dart';
import 'api/mock/mock_records_api_service.dart';
import 'api/interfaces/identification_api_service.dart';
import 'api/implementations/identification_api_service_impl.dart';
import 'api/mock/mock_identification_api_service.dart';
import 'api/interfaces/common_query_api_service.dart';
import 'api/implementations/common_query_api_service_impl.dart';
import 'api/mock/mock_common_query_api_service.dart';
import 'api/interfaces/todo_api_service.dart';
import 'api/implementations/api_todo_service.dart';
import 'api/mock/mock_todo_api_service.dart';
import 'api/interfaces/material_handle_api_service.dart';
import 'api/implementations/material_handle_api_service_impl.dart';
import 'api/mock/mock_material_handle_api_service.dart';
import 'api/interfaces/return_api_service.dart';
import 'api/implementations/return_api_service_impl.dart';
import 'api/mock/mock_return_api_service.dart';
import 'api/interfaces/acceptance_api_service.dart';
import 'api/implementations/acceptance_api_service_impl.dart';
import 'api/mock/mock_acceptance_api_service.dart';
import 'api/interfaces/cut_api_service.dart';
import 'api/implementations/cut_api_service_impl.dart';
import 'api/mock/mock_cut_api_service.dart';
import 'api/interfaces/upload_api_service.dart';
import 'api/implementations/upload_api_service_impl.dart';
import 'api/mock/mock_upload_api_service.dart';
import 'api/interfaces/recovery_api_service.dart';
import 'api/implementations/recovery_api_service_impl.dart';
import 'api/interfaces/storekeeper_action_api_service.dart';
import 'api/implementations/storekeeper_action_api_service_impl.dart';
import 'api/interfaces/signin_api_service.dart';
import 'api/implementations/signin_api_service_impl.dart';
import 'api/interfaces/qq_lbs_api_service.dart';
import 'api/implementations/qq_lbs_api_service_impl.dart';
import 'api/mock/mock_qq_lbs_api_service.dart';

/// Whitelist of endpoint patterns (as regular expressions) that require
/// location data to be injected.
///
/// Add API path patterns that need latitude and longitude.
/// Example: const List<String> _locationEndpointsWhitelist = [r'/api/v1/some/action/\d+'];
const List<String> _locationEndpointPatterns = [
  r'^/signout/do$',
  r'^/install/do$',
  r'^/return/do$',
  r'^/accept/do$',
  r'^/accept/after/accept/do$',
  r'^/dispatch/do$',
  r'^/dispatch/dispatch/receive$',
  r'^/waste/do$',
  // Example for a path with a dynamic parameter:
  r'^/wx/login/sms',
  r'^/wx/login/unite/password',
];

class ApiServiceFactory {
  static ApiServiceInterface create() {
    if (AppConfig.isMockEnabled) {
      return MockApiService();
    } else {
      final dio = createBaseDio();
      return ApiServiceImpl(dio);
    }
  }

  static RecordsApiService createRecordsService() {
    if (AppConfig.isMockEnabled) {
      return MockRecordsApiService();
    } else {
      final dio = createBaseDio();
      return RealRecordsApiService(dio);
    }
  }

  static IdentificationApiService createIdentificationService() {
    if (AppConfig.isMockEnabled) {
      return MockIdentificationApiService();
    } else {
      final dio = createBaseDio();
      return IdentificationApiServiceImpl(dio);
    }
  }

  static CommonQueryApiService createCommonQueryService() {
    if (AppConfig.isMockEnabled) {
      return MockCommonQueryApiService();
    } else {
      final dio = createBaseDio();
      return CommonQueryApiServiceImpl(dio);
    }
  }

  static TodoApiService createTodoService() {
    if (AppConfig.isMockEnabled) {
      return MockTodoApiService();
    } else {
      final dio = createBaseDio();
      return ApiTodoService(dio);
    }
  }

  static EnumApiService createEnumService() {
    if (AppConfig.isMockEnabled) {
      return MockEnumApiService();
    } else {
      final dio = createBaseDio();
      return EnumApiServiceImpl(dio);
    }
  }

  static MaterialHandleApiService createMaterialHandleService() {
    if (AppConfig.isMockEnabled) {
      return MockMaterialHandleApiService();
    } else {
      final dio = createBaseDio();
      return MaterialHandleApiServiceImpl(dio);
    }
  }

  static SignoutApiService createSignoutService() {
    if (AppConfig.isMockEnabled) {
      return MockSignoutApiService();
    } else {
      final dio = createBaseDio();
      return SignoutApiServiceImpl(dio);
    }
  }

  static InstallApiService createInstallApiService() {
    if (AppConfig.isMockEnabled) {
      return MockInstallApiService();
    } else {
      final dio = createBaseDio();
      return InstallApiServiceImpl(dio);
    }
  }

  static DispatchApiService createDispatchService() {
    if (AppConfig.isMockEnabled) {
      return MockDispatchApiService();
    } else {
      final dio = createBaseDio();
      return DispatchApiServiceImpl(dio);
    }
  }

  static ReturnApiService createReturnService() {
    if (AppConfig.isMockEnabled) {
      return MockReturnApiService();
    } else {
      final dio = createBaseDio();
      return ReturnApiServiceImpl(dio);
    }
  }

  static AcceptanceApiService createAcceptanceService() {
    if (AppConfig.isMockEnabled) {
      return MockAcceptanceApiService();
    } else {
      final dio = createBaseDio();
      return AcceptanceApiServiceImpl(dio);
    }
  }

  static CutApiService createCutService() {
    if (AppConfig.isMockEnabled) {
      return MockCutApiService();
    } else {
      final dio = createBaseDio();
      return CutApiServiceImpl(dio);
    }
  }

  static InventoryApiService createInventoryService() {
    if (AppConfig.isMockEnabled) {
      return MockInventoryApiService();
    } else {
      final dio = createBaseDio();
      return InventoryApiServiceImpl(dio);
    }
  }

  static ScrapApiService createScrapService() {
    if (AppConfig.isMockEnabled) {
      return MockScrapApiService();
    } else {
      final dio = createBaseDio();
      return ScrapApiServiceImpl(dio);
    }
  }

  static UploadApiService createUploadService() {
    if (AppConfig.isMockEnabled) {
      return MockUploadApiService();
    } else {
      final dio = _createUploadDio();
      return UploadApiServiceImpl(dio);
    }
  }

  static RecoveryApiService createRecoveryService() {
    // TODO: 添加mock实现
    // if (AppConfig.isMockEnabled) {
    //   return MockRecoveryApiService();
    // } else {
    final dio = createBaseDio();
    return RecoveryApiServiceImpl(dio);
    // }
  }

  static StorekeeperActionApiService createStorekeeperActionService() {
    // TODO: 添加mock实现
    // if (AppConfig.isMockEnabled) {
    //   return MockStorekeeperActionApiService();
    // } else {
    final dio = createBaseDio();
    return StorekeeperActionApiServiceImpl(dio);
    // }
  }

  static SigninApiService createSigninApiService() {
    final dio = createBaseDio();
    return SigninApiServiceImpl(dio);
  }

  static TemporaryAuthApiService createTemporaryAuthService() {
    if (AppConfig.isMockEnabled) {
      return MockTemporaryAuthApiService();
    } else {
      final dio = createBaseDio();
      return TemporaryAuthApiServiceImpl(dio);
    }
  }

  static MapApiService createMapApiService() {
    if (AppConfig.isMockEnabled) {
      return MockMapApiService();
    } else {
      final dio = createBaseDio();
      return MapApiServiceImpl(dio);
    }
  }

  static ChangePasswordApiService createChangePasswordService() {
    final dio = createBaseDio();
    return ChangePasswordApiServiceImpl(dio);
  }

  static QQLbsApiService createQQLbsService() {
    if (AppConfig.isMockEnabled) {
      return MockQQLbsApiService();
    } else {
      final dio = createBaseDio();
      return QQLbsApiServiceImpl(dio);
    }
  }

  static ProfileApiService createProfileService() {
    // TODO: 这里默认一直是Mock，需要后续有服务端接口后补充成具体实现
    return MockProfileApiService();
  }

  static Dio createBaseDio() {
    final dio = Dio();

    // if (AppConfig.isDevelopment) {
    //   final proxyAddress = '10.3.2.198:6152';
    //   final httpClient = HttpClient();
    //   // httpClient.findProxy = (uri) {
    //   //   return "PROXY $proxyAddress";
    //   // };
    //   httpClient.badCertificateCallback = (cert, host, port) => true;
    //
    //   dio.httpClientAdapter = IOHttpClientAdapter(
    //     createHttpClient: () => httpClient,
    //   );
    // }

    // Base configuration
    dio.options.baseUrl = AppConfig.apiBaseUrl;
    dio.options.connectTimeout = AppConfig.apiTimeout;
    dio.options.receiveTimeout = AppConfig.apiTimeout;
    dio.options.headers.addAll(AppConfig.defaultHeaders);

    // Add authentication interceptor (must be added before logging)
    dio.interceptors.add(AuthInterceptor());

    // Add location interceptor with the defined whitelist.
    dio.interceptors.add(
      LocationInterceptor(endpointPatterns: _locationEndpointPatterns),
    );

    // Add enhanced network logging interceptor in development
    if (AppConfig.isDevelopment) {
      // Use our custom network logger with detailed formatting
      dio.interceptors.add(NetworkLogger.createNetworkInterceptor());

      // Log Dio configuration
      Logger.info(
        'Dio configured with base URL: ${AppConfig.apiBaseUrl}',
        tag: 'NETWORK',
      );
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

    dio.interceptors.add(TracingInterceptor());

    return dio;
  }

  static Dio _createUploadDio() {
    final dio = Dio();

    // Base configuration for upload service
    dio.options.baseUrl = AppConfig.uploadBaseUrl;
    dio.options.connectTimeout = AppConfig.apiTimeout;
    dio.options.receiveTimeout = AppConfig.apiTimeout;
    dio.options.headers.addAll(AppConfig.defaultHeaders);

    // Add authentication interceptor
    dio.interceptors.add(AuthInterceptor());

    // Add location interceptor with the defined whitelist.
    dio.interceptors.add(
      LocationInterceptor(endpointPatterns: _locationEndpointPatterns),
    );

    // Add enhanced network logging interceptor in development
    if (AppConfig.isDevelopment) {
      dio.interceptors.add(NetworkLogger.createNetworkInterceptor());

      Logger.info(
        'Upload Dio configured with base URL: ${AppConfig.uploadBaseUrl}',
        tag: 'NETWORK',
      );
    }

    return dio;
  }
}
