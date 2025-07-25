import 'package:get_it/get_it.dart';
import 'package:pipe_code_flutter/repositories/enum_repository.dart';
import 'package:pipe_code_flutter/repositories/install_repository.dart';
import 'package:pipe_code_flutter/repositories/signout_repository.dart';
import 'package:pipe_code_flutter/repositories/spareqr_repository.dart';
import 'package:pipe_code_flutter/repositories/material_handle_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/enum_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/install_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/signout_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/list_repository.dart';
import '../repositories/records_repository.dart';
import '../repositories/acceptance_repository.dart';
import '../services/api/interfaces/api_service_interface.dart';
import '../services/api/interfaces/records_api_service.dart';
import '../services/api/interfaces/identification_api_service.dart';
import '../services/api/interfaces/common_query_api_service.dart';
import '../services/api/interfaces/todo_api_service.dart';
import '../services/api/interfaces/material_handle_api_service.dart';
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

  // Identification API Service - automatically chooses Mock or Real based on config
  getIt.registerLazySingleton<IdentificationApiService>(
    () => ApiServiceFactory.createIdentificationService(),
  );

  // Common Query API Service - automatically chooses Mock or Real based on config
  getIt.registerLazySingleton<CommonQueryApiService>(
    () => ApiServiceFactory.createCommonQueryService(),
  );

  getIt.registerLazySingleton<TodoApiService>(
    () => ApiServiceFactory.createTodoService(),
  );

  getIt.registerLazySingleton<EnumApiService>(
    () => ApiServiceFactory.createEnumService(),
  );

  getIt.registerLazySingleton<MaterialHandleApiService>(
    () => ApiServiceFactory.createMaterialHandleService(),
  );

  getIt.registerSingleton<EnumRepository>(
    EnumRepository(getIt<EnumApiService>()),
  );

  await getIt<EnumRepository>().initializeEnums();

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
    () =>
        RecordsRepository(getIt<RecordsApiService>(), getIt<TodoApiService>()),
  );

  getIt.registerLazySingleton<AcceptanceRepository>(
    () => AcceptanceRepository(
      getIt<ApiServiceInterface>().acceptance,
      getIt<CommonQueryApiService>(),
    ),
  );

  getIt.registerLazySingleton<MaterialHandleRepository>(
    () => MaterialHandleRepository(getIt<MaterialHandleApiService>()),
  );
  getIt.registerLazySingleton<SignoutApiService>(
    () => ApiServiceFactory.createSignoutService(),
  );
  getIt.registerLazySingleton<SignoutRepository>(
    () => SignoutRepository(
      getIt<ApiServiceInterface>().signout,
      getIt<CommonQueryApiService>(),
    ),
  );

  getIt.registerLazySingleton<InstallRepository>(
    () => InstallRepository(
      getIt<InstallApiService>(),
      getIt<CommonQueryApiService>(),
    ),
  );

  getIt.registerLazySingleton<InstallApiService>(
    () => ApiServiceFactory.createInstallApiService(),
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
