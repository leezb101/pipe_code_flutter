/*
 * @Author: LeeZB
 * @Date: 2025-06-21 21:18:36
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-20 12:26:48
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/spare_qr/spare_qr_bloc.dart';
import 'package:pipe_code_flutter/pages/spare_qr/spare_qr_page.dart';
import 'package:pipe_code_flutter/repositories/spareqr_repository.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/main_page.dart';
import '../pages/qr_scan/qr_scan_page.dart';
import '../pages/inventory/inventory_confirmation_page.dart';
import '../pages/acceptance/acceptance_page.dart';
import '../pages/acceptance/acceptance_detail_page.dart';
import '../pages/acceptance/acceptance_confirmation_page.dart';
import '../bloc/acceptance/acceptance_bloc.dart';
import '../repositories/acceptance_repository.dart';
import '../pages/developer_settings_page.dart';
import '../pages/project_initiation/project_initiation_form_page.dart';
import '../pages/project_initiation/material_selection_page.dart';
import '../pages/records/records_list_page.dart';
import '../bloc/qr_scan/qr_scan_bloc.dart';
import '../bloc/project_initiation/project_initiation_bloc.dart';
import '../bloc/records/records_bloc.dart';
import '../cubits/material_selection_cubit.dart';
import '../repositories/records_repository.dart';
import '../models/qr_scan/qr_scan_config.dart';
import '../models/inventory/pipe_material.dart';
import '../models/project/project_initiation.dart';
import '../models/records/record_type.dart';
import '../services/qr_scan_service.dart';
import '../pages/material/material_detail_page.dart';
import '../models/material/scan_identification_response.dart';
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
      path: '/',
      name: 'main',
      builder: (context, state) => const MainPage(),
      routes: [
        GoRoute(
          path: '/spare-qr',
          name: 'spare-qr',
          builder: (context, state) {
            return BlocProvider(
              create: (context) =>
                  SpareQrBloc(repository: getIt<SpareqrRepository>()),
              child: const SpareQrPage(),
            );
          },
        ),
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
          path: '/acceptance',
          name: 'acceptance',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            if (data == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            final materials = data['materials'] as List<PipeMaterial>?;
            if (materials == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return BlocProvider(
              create: (context) =>
                  AcceptanceBloc(getIt<AcceptanceRepository>()),
              child: AcceptancePage(materials: materials),
            );
          },
        ),
        GoRoute(
          path: '/acceptance-detail',
          name: 'acceptance-detail',
          builder: (context, state) {
            final acceptanceIdParam = state.uri.queryParameters['id'];
            final acceptanceId = acceptanceIdParam != null
                ? int.tryParse(acceptanceIdParam)
                : null;
            if (acceptanceId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return BlocProvider(
              create: (context) =>
                  AcceptanceBloc(getIt<AcceptanceRepository>()),
              child: AcceptanceDetailPage(acceptanceId: acceptanceId),
            );
          },
        ),
        GoRoute(
          path: '/acceptance-confirmation',
          name: 'acceptance-confirmation',
          builder: (context, state) {
            final acceptanceIdParam = state.uri.queryParameters['id'];
            final acceptanceId = acceptanceIdParam != null
                ? int.tryParse(acceptanceIdParam)
                : null;
            if (acceptanceId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return BlocProvider(
              create: (context) =>
                  AcceptanceBloc(getIt<AcceptanceRepository>()),
              child: AcceptanceConfirmationPage(acceptanceId: acceptanceId),
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
        GoRoute(
          path: '/records',
          name: 'records',
          builder: (context, state) {
            final tabParam = state.uri.queryParameters['tab'];
            RecordType? initialTab;
            if (tabParam != null) {
              try {
                initialTab = RecordType.values.firstWhere(
                  (type) => type.name == tabParam,
                );
              } catch (e) {
                initialTab = null;
              }
            }
            return BlocProvider(
              create: (context) => RecordsBloc(getIt<RecordsRepository>()),
              child: RecordsListPage(initialTab: initialTab),
            );
          },
        ),
        GoRoute(
          path: '/material-detail',
          name: 'material-detail',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            if (data == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            final identificationData = data['identificationData'] as ScanIdentificationData?;
            if (identificationData == null) {
              return const Scaffold(body: Center(child: Text('材料信息错误')));
            }
            return MaterialDetailPage(identificationData: identificationData);
          },
        ),
        GoRoute(
          path: '/project-initiation',
          name: 'project-initiation',
          builder: (context, state) {
            final projectId = state.uri.queryParameters['projectId'];
            return BlocProvider(
              create: (context) => ProjectInitiationBloc(),
              child: ProjectInitiationFormPage(
                projectId: projectId != null ? int.tryParse(projectId) : null,
              ),
            );
          },
          routes: [
            GoRoute(
              path: '/material-selection',
              name: 'material-selection',
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>?;
                return BlocProvider(
                  create: (context) => MaterialSelectionCubit(),
                  child: MaterialSelectionPage(
                    existingMaterials:
                        data?['existingMaterials'] as List<ProjectMaterial>?,
                    remarks: data?['remarks'] as String?,
                  ),
                );
              },
            ),
          ],
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
