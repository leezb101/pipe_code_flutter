import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routes.dart';
import 'config/service_locator.dart';
import 'bloc/auth/auth_bloc.dart';
import 'cubits/list_cubit.dart';
import 'repositories/auth_repository.dart';
import 'repositories/list_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize service locator with Mock environment for development
  // Switch to setupDevelopmentEnvironment() or setupProductionEnvironment() 
  // when you have a real API
  await setupMockEnvironment();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: getIt<AuthRepository>(),
          ),
        ),
        BlocProvider<ListCubit>(
          create: (context) => ListCubit(
            listRepository: getIt<ListRepository>(),
          ),
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