import 'package:get_it/get_it.dart';
import 'package:pipe_code_flutter/repositories/spareqr_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/spareqr_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/list_repository.dart';
import '../repositories/records_repository.dart';
import '../services/api/interfaces/api_service_interface.dart';
import '../services/api/interfaces/records_api_service.dart';
import '../services/api_service_factory.dart';
import '../services/storage_service.dart';
import '../services/qr_scan_service.dart';
import 'app_config.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator({
  Environment? environment,
  DataSource? dataSource,
}) async {
  // Configure app environment
  if (environment != null) {
    await AppConfig.setEnvironment(environment);
  }
  if (dataSource != null) {
    await AppConfig.setDataSource(dataSource);
  }

  // Reset service locator if already initialized
  if (getIt.isRegistered<SharedPreferences>()) {
    await getIt.reset();
  }

  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Services
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(getIt<SharedPreferences>()),
  );

  // API Service - automatically chooses Mock or Real based on config
  getIt.registerLazySingleton<ApiServiceInterface>(
    () => ApiServiceFactory.create(),
  );

  // Records API Service - automatically chooses Mock or Real based on config
  getIt.registerLazySingleton<RecordsApiService>(
    () => ApiServiceFactory.createRecordsService(),
  );

  // QR Scan Service
  getIt.registerLazySingleton<QrScanService>(() => QrScanServiceImpl());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      apiService: getIt<ApiServiceInterface>(),
      storageService: getIt<StorageService>(),
    ),
  );

  getIt.registerLazySingleton<SpareqrRepository>(
    () => SpareqrRepository(apiservice: getIt<ApiServiceInterface>()),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(
      apiService: getIt<ApiServiceInterface>(),
      storageService: getIt<StorageService>(),
    ),
  );

  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepository(
      apiService: getIt<ApiServiceInterface>(),
      storageService: getIt<StorageService>(),
    ),
  );

  getIt.registerLazySingleton<ListRepository>(
    () => ListRepository(apiService: getIt<ApiServiceInterface>()),
  );

  getIt.registerLazySingleton<RecordsRepository>(
    () => RecordsRepository(getIt<RecordsApiService>()),
  );
}

// Convenience methods for quick setup
Future<void> setupMockEnvironment() async {
  await setupServiceLocator(
    environment: Environment.development,
    dataSource: DataSource.mock,
  );
}

Future<void> setupProductionEnvironment() async {
  await setupServiceLocator(
    environment: Environment.production,
    dataSource: DataSource.api,
  );
}

Future<void> setupDevelopmentEnvironment() async {
  await setupServiceLocator(
    environment: Environment.development,
    dataSource: DataSource.api,
  );
}
