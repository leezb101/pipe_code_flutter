enum Environment {
  development,
  staging,
  production,
}

enum DataSource {
  mock,
  api,
}

class AppConfig {
  static Environment _environment = Environment.development;
  static DataSource _dataSource = DataSource.mock;

  static Environment get environment => _environment;
  static DataSource get dataSource => _dataSource;
  
  static bool get isMockEnabled => _dataSource == DataSource.mock;
  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static void setDataSource(DataSource source) {
    _dataSource = source;
  }

  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.example.com';
      case Environment.staging:
        return 'https://staging-api.example.com';
      case Environment.production:
        return 'https://api.example.com';
    }
  }

  static Duration get apiTimeout => const Duration(seconds: 10);

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}