/*
 * @Author: LeeZB
 * @Date: 2025-06-28 13:17:21
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-22 16:24:51
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/enum/enum_cubit.dart';
import 'package:pipe_code_flutter/repositories/enum_repository.dart';
import 'config/routes.dart';
import 'config/service_locator.dart';
import 'config/app_config.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/user/user_bloc.dart';
import 'bloc/user/user_event.dart';
import 'bloc/project/project_bloc.dart';
import 'bloc/project/project_event.dart';
import 'cubits/list_cubit.dart';
import 'repositories/auth_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/list_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // First setup service locator with default configuration
  // await setupMockEnvironment();
  await setupDevelopmentEnvironment();

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
          create: (context) =>
              AuthBloc(authRepository: getIt<AuthRepository>()),
        ),
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
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFullyAuthenticated) {
            context.read<UserBloc>().add(
              UserSetData(wxLoginVO: state.wxLoginVO),
            );
            // // 登录成功后，触发项目上下文加载
            // context.read<ProjectBloc>().add(
            //   ProjectLoadUserContext(userId: state.user.id),
            // );
          } else if (state is AuthUnauthenticated) {
            context.read<UserBloc>().add(const UserClearData());
            context.read<ProjectBloc>().add(const ProjectClearData());
          }
        },
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
        ),
      ),
    );
  }
}
