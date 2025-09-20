import 'package:get_it/get_it.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_bloc.dart';
import 'package:pipe_code_flutter/bloc/return/return_bloc.dart';
import 'package:pipe_code_flutter/bloc/scrap/scrap_bloc.dart';
import 'package:pipe_code_flutter/bloc/session/session_bloc.dart';
import 'package:pipe_code_flutter/bloc/signout/signout_bloc.dart';
import 'package:pipe_code_flutter/bloc/spare_qr/spare_qr_bloc.dart';
import 'package:pipe_code_flutter/bloc/cut/cut_bloc.dart';
import 'package:pipe_code_flutter/bloc/material_detail/material_detail_bloc.dart';
import 'package:pipe_code_flutter/bloc/recovery/recovery_bloc.dart';
import 'package:pipe_code_flutter/bloc/storekeeper_non_project/storekeeper_non_project_bloc.dart';
import 'package:pipe_code_flutter/cubits/signin_detail_cubit.dart';
import 'package:pipe_code_flutter/cubits/temporary_auth.dart';
import 'package:pipe_code_flutter/repositories/interfaces/acceptance_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/auth_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/cut_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/dispatch_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/enum_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/install_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/inventory_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/list_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_detail_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/project_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/records_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/recovery_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/return_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/scrap_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/signin_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/signout_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/spareqr_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/temporary_auth_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/user_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/storekeeper_non_project_repository.dart';
import 'package:pipe_code_flutter/repositories/repository_factory.dart';
import 'package:pipe_code_flutter/services/api/interfaces/common_query_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/identification_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/scrap_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/upload_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/map_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/chanage_password_api_service.dart';
import 'package:pipe_code_flutter/services/api_service_factory.dart';
import 'package:pipe_code_flutter/services/qr_scan_service.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:pipe_code_flutter/services/base_speech_service.dart';
import 'package:pipe_code_flutter/services/speech_service_factory.dart';
import 'package:pipe_code_flutter/services/storage_service.dart';
import 'package:pipe_code_flutter/services/notification/background_handler.dart';
import 'package:pipe_code_flutter/services/notification/notification_manager.dart';
import 'package:pipe_code_flutter/services/sse/sse_service.dart';
import 'package:pipe_code_flutter/services/tracing/tracing_manager.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_config.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator({
  Environment? environment,
  DataSource? dataSource,
}) async {
  Logger.debug(
    '=========Setting up service locator with environment: $environment, dataSource: $dataSource',
  );
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
  // SSE Service
  getIt.registerLazySingleton<SseService>(
    () => SseService(),
    dispose: (service) => service.dispose(),
  );
  getIt.registerLazySingleton<BaseSpeechService>(
    () => SpeechServiceFactory.createSpeechService(),
  );

  // API Services needed by Blocs or other services directly
  getIt.registerLazySingleton<CommonQueryApiService>(
    () => ApiServiceFactory.createCommonQueryService(),
  );
  getIt.registerLazySingleton<IdentificationApiService>(
    () => ApiServiceFactory.createIdentificationService(),
  );
  getIt.registerLazySingleton<ScrapApiService>(
    () => ApiServiceFactory.createScrapService(),
  );
  getIt.registerLazySingleton<UploadApiService>(
    () => ApiServiceFactory.createUploadService(),
  );
  getIt.registerLazySingleton<MapApiService>(
    () => ApiServiceFactory.createMapApiService(),
  );
  getIt.registerLazySingleton<ChangePasswordApiService>(
    () => ApiServiceFactory.createChangePasswordService(),
  );

  // QR Scan Service
  getIt.registerLazySingleton<QrScanService>(() => QrScanServiceImpl());
  getIt.registerLazySingleton<QrScanFlowService>(
    () => const QrScanFlowService(),
  );

  // Notification Services
  getIt.registerLazySingleton<TracingManager>(() => TracingManager());
  getIt.registerSingleton<NotificationManager>(NotificationManager.instance);
  getIt.registerSingleton<BackgroundNotificationHandler>(
    BackgroundNotificationHandler.instance,
  );

  // Repositories (using RepositoryFactory)
  getIt.registerLazySingleton<AcceptanceRepository>(
    () => RepositoryFactory.createAcceptanceRepository(),
  );
  getIt.registerLazySingletonAsync<AuthRepository>(
    () => RepositoryFactory.createAuthRepository(),
  );
  getIt.registerLazySingleton<DispatchRepository>(
    () => RepositoryFactory.createDispatchRepository(),
  );
  getIt.registerSingleton<EnumRepository>(
    RepositoryFactory.createEnumRepository(),
  );
  // 延后到网络就绪后由 StartupGate 触发 initializeAppData()

  getIt.registerLazySingleton<InstallRepository>(
    () => RepositoryFactory.createInstallRepository(),
  );
  getIt.registerLazySingleton<InventoryRepository>(
    () => RepositoryFactory.createInventoryRepository(),
  );
  getIt.registerLazySingleton<ListRepository>(
    () => RepositoryFactory.createListRepository(),
  );
  getIt.registerLazySingleton<MaterialHandleRepository>(
    () => RepositoryFactory.createMaterialHandleRepository(),
  );
  getIt.registerLazySingletonAsync<ProjectRepository>(
    () => RepositoryFactory.createProjectRepository(),
  );
  getIt.registerLazySingleton<RecordsRepository>(
    () => RepositoryFactory.createRecordsRepository(),
  );
  getIt.registerLazySingleton<RecoveryRepository>(
    () => RepositoryFactory.createRecoveryRepository(),
  );
  getIt.registerLazySingleton<ReturnRepository>(
    () => RepositoryFactory.createReturnRepository(),
  );
  getIt.registerLazySingleton<SignoutRepository>(
    () => RepositoryFactory.createSignoutRepository(),
  );
  getIt.registerLazySingleton<SpareqrRepository>(
    () => RepositoryFactory.createSpareqrRepository(),
  );
  getIt.registerLazySingletonAsync<UserRepository>(
    () => RepositoryFactory.createUserRepository(),
  );

  getIt.registerLazySingleton<CutRepository>(
    () => RepositoryFactory.createCutRepository(),
  );

  getIt.registerLazySingleton<ScrapRepository>(
    () => RepositoryFactory.createScrapRepository(),
  );

  getIt.registerLazySingleton<MaterialDetailRepository>(
    () => RepositoryFactory.createMaterialDetailRepository(),
  );
  getIt.registerLazySingleton<StorekeeperNonProjectRepository>(
    () => RepositoryFactory.createStorekeeperNonProjectRepository(),
  );
  getIt.registerLazySingleton<SigninRepository>(
    () => RepositoryFactory.createSigninRepository(),
  );
  getIt.registerLazySingleton<TemporaryAuthRepository>(
    () => RepositoryFactory.createTemporaryAuthRepository(),
  );
  // Wait for async singletons to be ready before registering dependent Blocs
  await getIt.isReady<AuthRepository>();
  await getIt.isReady<ProjectRepository>();
  await getIt.isReady<UserRepository>();
  Logger.debug('=========All repositories are ready');

  // Blocs
  getIt.registerLazySingleton<SessionBloc>(
    () => SessionBloc(
      authRepository: getIt<AuthRepository>(),
      projectRepository: getIt<ProjectRepository>(),
    ),
  );

  getIt.registerFactory<RecordsBloc>(
    () => RecordsBloc(getIt<RecordsRepository>()),
  );
  getIt.registerFactory<RecoveryBloc>(
    () => RecoveryBloc(repository: getIt<RecoveryRepository>()),
  );
  getIt.registerFactory<ReturnBloc>(
    () => ReturnBloc(returnRepository: getIt<ReturnRepository>()),
  );
  getIt.registerFactory<SignoutBloc>(
    () => SignoutBloc(
      getIt<SignoutRepository>(),
      getIt<MaterialHandleRepository>(),
    ),
  );
  getIt.registerFactory<SpareQrBloc>(
    () => SpareQrBloc(repository: getIt<SpareqrRepository>()),
  );
  getIt.registerFactory<CutBloc>(
    () => CutBloc(cutRepository: getIt<CutRepository>()),
  );
  getIt.registerFactory<MaterialDetailBloc>(() => MaterialDetailBloc());
  getIt.registerFactory<InventoryBloc>(
    () => InventoryBloc(
      inventoryRepository: getIt<InventoryRepository>(),
      materialHandleRepository: getIt<MaterialHandleRepository>(),
    ),
  );

  getIt.registerFactory<SigninDetailCubit>(
    () => SigninDetailCubit(signinRepository: getIt<SigninRepository>()),
  );

  getIt.registerFactory<ScrapBloc>(
    () => ScrapBloc(
      scrapRepository: getIt<ScrapRepository>(),
      materialHandleRepository: getIt<MaterialHandleRepository>(),
    ),
  );

  getIt.registerFactory<StorekeeperNonProjectBloc>(
    () => StorekeeperNonProjectBloc(
      repository: getIt<StorekeeperNonProjectRepository>(),
      qrScanFlowService: getIt<QrScanFlowService>(),
    ),
  );
  getIt.registerFactory<TemporaryAuthCubit>(
    () => TemporaryAuthCubit(
      sessionBloc: getIt<SessionBloc>(),
      repository: getIt<TemporaryAuthRepository>(),
    ),
  );

  // Configure app environment
  Logger.debug('=========Setting app environment and data source');
  if (environment != null) {
    await AppConfig.setEnvironment(environment);
  }
  if (dataSource != null) {
    await AppConfig.setDataSource(dataSource);
  }
}

/// Execute network-dependent initializations after connectivity is granted.
Future<void> initializeAppData() async {
  Logger.debug('=========Initializing network-dependent app data');
  try {
    await getIt<EnumRepository>().initializeEnums();
    Logger.debug('=========Enum initialization done');
  } catch (e, s) {
    Logger.error('Enum initialization failed: $e\n$s');
    rethrow;
  }
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
