import 'package:get_it/get_it.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_bloc.dart';
import 'package:pipe_code_flutter/bloc/dispatch/dispatch_bloc.dart';
import 'package:pipe_code_flutter/bloc/install/install_bloc.dart';
import 'package:pipe_code_flutter/bloc/project_initiation/project_initiation_bloc.dart';
import 'package:pipe_code_flutter/bloc/qr_scan/qr_scan_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_bloc.dart';
import 'package:pipe_code_flutter/bloc/return/return_bloc.dart';
import 'package:pipe_code_flutter/bloc/session/session_bloc.dart';
import 'package:pipe_code_flutter/bloc/signout/signout_bloc.dart';
import 'package:pipe_code_flutter/bloc/spare_qr/spare_qr_bloc.dart';
import 'package:pipe_code_flutter/bloc/cut/cut_bloc.dart';
import 'package:pipe_code_flutter/repositories/interfaces/acceptance_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/auth_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/cut_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/dispatch_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/enum_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/install_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/list_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/project_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/records_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/return_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/signout_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/spareqr_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/user_repository.dart';
import 'package:pipe_code_flutter/repositories/repository_factory.dart';
import 'package:pipe_code_flutter/services/api/interfaces/common_query_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/identification_api_service.dart';
import 'package:pipe_code_flutter/services/api_service_factory.dart';
import 'package:pipe_code_flutter/services/qr_scan_service.dart';
import 'package:pipe_code_flutter/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // API Services needed by Blocs or other services directly
  getIt.registerLazySingleton<CommonQueryApiService>(
    () => ApiServiceFactory.createCommonQueryService(),
  );
  getIt.registerLazySingleton<IdentificationApiService>(
    () => ApiServiceFactory.createIdentificationService(),
  );

  // QR Scan Service
  getIt.registerLazySingleton<QrScanService>(() => QrScanServiceImpl());

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
  await getIt<EnumRepository>().initializeEnums();

  getIt.registerLazySingleton<InstallRepository>(
    () => RepositoryFactory.createInstallRepository(),
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

  // Wait for async singletons to be ready before registering dependent Blocs
  await getIt.isReady<AuthRepository>();
  await getIt.isReady<ProjectRepository>();
  await getIt.isReady<UserRepository>();

  // Blocs
  getIt.registerFactory<SessionBloc>(
    () => SessionBloc(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<AcceptanceBloc>(
    () => AcceptanceBloc(
      getIt<AcceptanceRepository>(),
      getIt<MaterialHandleRepository>(),
    ),
  );
  getIt.registerFactory<DispatchBloc>(
    () => DispatchBloc(
      dispatchRepository: getIt<DispatchRepository>(),
      commonQueryApiService: getIt<CommonQueryApiService>(),
    ),
  );
  getIt.registerFactory<InstallBloc>(
    () => InstallBloc(installRepository: getIt<InstallRepository>()),
  );
  getIt.registerFactory<ProjectInitiationBloc>(() => ProjectInitiationBloc());
  getIt.registerFactory<QrScanBloc>(
    () => QrScanBloc(qrScanService: getIt<QrScanService>()),
  );
  getIt.registerFactory<RecordsBloc>(
    () => RecordsBloc(getIt<RecordsRepository>()),
  );
  getIt.registerFactory<ReturnBloc>(
    () => ReturnBloc(returnRepository: getIt<ReturnRepository>()),
  );
  getIt.registerFactory<SignoutBloc>(
    () => SignoutBloc(getIt<SignoutRepository>()),
  );
  getIt.registerFactory<SpareQrBloc>(
    () => SpareQrBloc(repository: getIt<SpareqrRepository>()),
  );
  getIt.registerFactory<CutBloc>(
    () => CutBloc(cutRepository: getIt<CutRepository>()),
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
