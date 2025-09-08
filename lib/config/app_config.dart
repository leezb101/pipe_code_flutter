import '../services/storage_service.dart';
import 'service_locator.dart';

enum Environment { development, staging, production }

enum DataSource { mock, api }

class AppConfig {
  static Environment _environment = Environment.development;
  static DataSource _dataSource = DataSource.mock;
  static bool _isInitialized = false;

  static Environment get environment => _environment;
  static DataSource get dataSource => _dataSource;

  static bool get isMockEnabled => _dataSource == DataSource.mock;
  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final storageService = getIt<StorageService>();

      // Load environment setting
      final envString = storageService.getString('app_environment');
      if (envString != null) {
        _environment = Environment.values.firstWhere(
          (e) => e.name == envString,
          orElse: () => Environment.development,
        );
      }

      // Load data source setting
      final dataSourceString = storageService.getString('app_data_source');
      if (dataSourceString != null) {
        _dataSource = DataSource.values.firstWhere(
          (e) => e.name == dataSourceString,
          orElse: () => DataSource.mock,
        );
      }

      _isInitialized = true;
    } catch (e) {
      // If there's an error loading settings, use defaults
      _environment = Environment.development;
      _dataSource = DataSource.mock;
      _isInitialized = true;
    }
  }

  static Future<void> setEnvironment(Environment env) async {
    _environment = env;
    await _saveEnvironment();
  }

  static Future<void> setDataSource(DataSource source) async {
    _dataSource = source;
    await _saveDataSource();
  }

  static Future<void> _saveEnvironment() async {
    try {
      final storageService = getIt<StorageService>();
      await storageService.setString('app_environment', _environment.name);
    } catch (e) {
      // Handle error if needed
    }
  }

  static Future<void> _saveDataSource() async {
    try {
      final storageService = getIt<StorageService>();
      await storageService.setString('app_data_source', _dataSource.name);
    } catch (e) {
      // Handle error if needed
    }
  }

  static Future<void> reset() async {
    try {
      final storageService = getIt<StorageService>();
      await storageService.remove('app_environment');
      await storageService.remove('app_data_source');
      _environment = Environment.development;
      _dataSource = DataSource.mock;
    } catch (e) {
      // Handle error if needed
    }
  }

  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        // return 'https://dev-api.example.com';
        // return 'http://10.2.220.12:8775/m';
        // return 'http://10.3.3.213:9000/m'; // 孙煊
        // return 'http://10.3.2.223:8775/m'; // 和宇翔
        return 'http://10.3.6.235/m';
      case Environment.staging:
        return 'https://staging-api.example.com';
      case Environment.production:
        return 'https://api.example.com';
    }
  }

  static String get uploadBaseUrl {
    switch (_environment) {
      case Environment.development:
        // 上传文件接口可能与业务接口使用不同的 base URL
        // 默认情况下与 apiBaseUrl 相同，但可以根据需要单独配置
        return 'http://10.3.6.235'; // 本地开发环境
      case Environment.staging:
        return 'http://10.3.6.235'; // 本地开发环境
      case Environment.production:
        return 'http://10.3.6.235'; // 本地开发环境
    }
  }

  static String get uploadUrl => '$uploadBaseUrl/group1/upload';

  static String get sseBaseUrl {
    switch (_environment) {
      case Environment.development:
        return '$apiBaseUrl/cmm/sse/rt';
      case Environment.staging:
        return '$apiBaseUrl/cmm/sse/rt';
      case Environment.production:
        return '$apiBaseUrl/cmm/sse/rt';
    }
  }

  static Duration get apiTimeout => const Duration(seconds: 100);
  static Duration get sseTimeout => const Duration(seconds: 300);
  static Duration get sseHeartbeatInterval => const Duration(seconds: 120);
  static Duration get sseReconnectDelay => const Duration(seconds: 5);
  static int get sseMaxRetryCount => 100;

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
