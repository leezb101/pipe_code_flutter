/*
 * @Author: LeeZB
 * @Date: 2025-06-28 13:17:21
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 14:52:51
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routes.dart';
import 'config/service_locator.dart';
import 'config/app_config.dart';
import 'bloc/auth/auth_bloc.dart';
import 'cubits/list_cubit.dart';
import 'repositories/auth_repository.dart';
import 'repositories/list_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // First setup service locator with default configuration
  await setupMockEnvironment();

  // Then initialize AppConfig which will load saved settings
  await AppConfig.initialize();

  // Re-setup service locator with loaded configuration
  await setupServiceLocator(
    environment: AppConfig.environment,
    dataSource: AppConfig.dataSource,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authRepository: getIt<AuthRepository>()),
        ),
        BlocProvider<ListCubit>(
          create: (context) =>
              ListCubit(listRepository: getIt<ListRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Flutter Bloc Template',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
