/*
 * @Author: LeeZB
 * @Date: 2025-06-21 21:18:36
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-08 10:07:33
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/main_page.dart';
import '../pages/qr_scan/qr_scan_page.dart';
import '../pages/inventory/inventory_confirmation_page.dart';
import '../pages/developer_settings_page.dart';
import '../bloc/qr_scan/qr_scan_bloc.dart';
import '../models/qr_scan/qr_scan_config.dart';
import '../models/inventory/pipe_material.dart';
import '../services/qr_scan_service.dart';
import 'service_locator.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/main',
      name: 'main',
      builder: (context, state) => const MainPage(),
      routes: [
        GoRoute(
          path: '/qr-scan',
          name: 'qr-scan',
          builder: (context, state) {
            final config = state.extra as QrScanConfig?;
            if (config == null) {
              return const Scaffold(body: Center(child: Text('扫码配置错误')));
            }
            return BlocProvider(
              create: (context) =>
                  QrScanBloc(qrScanService: getIt<QrScanService>()),
              child: QrScanPage(config: config),
            );
          },
        ),
        GoRoute(
          path: '/inventory-confirmation',
          name: 'inventory-confirmation',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            if (data == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            final materials = data['materials'] as List<PipeMaterial>?;
            final scanMode = data['scanMode'] as String?;
            if (materials == null || scanMode == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return InventoryConfirmationPage(
              materials: materials,
              scanMode: scanMode,
            );
          },
        ),
      ],
    ),

    GoRoute(
      path: '/developer-settings',
      name: 'developer-settings',
      builder: (context, state) => const DeveloperSettingsPage(),
    ),
  ],
);
