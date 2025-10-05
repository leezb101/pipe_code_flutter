/*
 * @Author: LeeZB
 * @Date: 2025-06-28 13:17:21
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-01 19:22:14
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/enum/enum_cubit.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_event.dart';
import 'package:pipe_code_flutter/bloc/session/session_bloc.dart';
import 'package:pipe_code_flutter/repositories/interfaces/enum_repository.dart';
import 'package:pipe_code_flutter/services/tracing/improved_tracing_manager.dart';
import 'config/routes.dart';
import 'services/qr_scan_flow/qr_scan_flow_service.dart';
import 'config/service_locator.dart';
import 'config/app_config.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/user/user_bloc.dart';
import 'bloc/user/user_event.dart';
import 'bloc/project/project_bloc.dart';
import 'bloc/project/project_event.dart';
import 'bloc/records/records_bloc.dart';
import 'bloc/records/records_event.dart';
import 'cubits/list_cubit.dart';
import 'repositories/interfaces/auth_repository.dart';
import 'repositories/interfaces/user_repository.dart';
import 'repositories/interfaces/list_repository.dart';
import 'repositories/interfaces/records_repository.dart';
import 'widgets/notification/floating_todo_banner.dart';
import 'services/notification/notification_manager.dart';
import 'widgets/startup_gate.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // TODO: implement createHttpClient
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  if (kDebugMode) {
    HttpClient.enableTimelineLogging = true;
  }

  WidgetsFlutterBinding.ensureInitialized();

  // First setup service locator with default configuration
  // await setupMockEnvironment();
  await setupDevelopmentEnvironment();
  // await setupProductionEnvironment();

  // Then initialize AppConfig which will load saved settings
  await AppConfig.initialize();

  // Re-setup service locator with loaded configuration
  // await setupServiceLocator(
  //   environment: AppConfig.environment,
  //   dataSource: AppConfig.dataSource,
  // );
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
        BlocProvider<EnumCubit>(
          create: (context) => EnumCubit(getIt<EnumRepository>()),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: getIt<AuthRepository>(),
            tracingManager: getIt<ImprovedTracingManager>(),
          )..add(AuthCheckRequested()),
        ),
        BlocProvider<SessionBloc>(create: (context) => getIt<SessionBloc>()),
        BlocProvider<UserBloc>(
          create: (context) =>
              UserBloc(userRepository: getIt<UserRepository>()),
        ),
        BlocProvider<ProjectBloc>(
          create: (context) =>
              ProjectBloc(authRepository: getIt<AuthRepository>()),
        ),
        BlocProvider<ListCubit>(
          create: (context) =>
              ListCubit(listRepository: getIt<ListRepository>()),
        ),
        BlocProvider<InventoryBloc>(
          create: (context) => getIt<InventoryBloc>(),
        ),
        // 全局提供 RecordsBloc，供任意页面刷新记录列表使用
        BlocProvider<RecordsBloc>(
          create: (context) => RecordsBloc(getIt<RecordsRepository>()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Tear down notification system when user logs out or auth expires
            NotificationManager.instance.stop();
            context.read<UserBloc>().add(const UserClearData());
            context.read<ProjectBloc>().add(const ProjectClearData());
            context.read<InventoryBloc>().add(InventoryReset());
            // 退出登录时清理记录缓存，确保不同账号隔离
            context.read<RecordsBloc>().add(const ClearRecordsCache());
          }
          if (state is AuthLoginSuccess) {
            // Note: SSE connection will be established by SessionBloc via NotificationManager
            // This avoids duplicate connection attempts and maintains single source of truth
            // 登录成功后也清理一次缓存，避免沿用上次残留
            context.read<RecordsBloc>().add(const ClearRecordsCache());
          }
          if (state is AuthTokenRefreshed) {
            // Refresh notification system on token refresh
            NotificationManager.instance.restart();
          }
        },
        child: RepositoryProvider<QrScanFlowService>(
          create: (_) => const QrScanFlowService(),
          child: MaterialApp.router(
            title: '建设一码通',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1976D2),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'PingFang SC', // 使用苹方字体，更适合中文显示
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1976D2),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              cardTheme: const CardThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            routerConfig: appRouter,
            builder: (context, child) {
              // 启动门卫：网络可用并完成初始化后放行
              return StartupGate(
                child: FloatingTodoBannerHost(child: child ?? const SizedBox()),
              );
            },
          ),
        ),
      ),
    );
  }
}

// TODO: 所有业务的详情页需要补完，目前看到只有scrap和return有详情页
