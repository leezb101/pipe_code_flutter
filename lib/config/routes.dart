import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_cubit.dart';
import 'package:pipe_code_flutter/bloc/scrap/scrap_bloc.dart';
import 'package:pipe_code_flutter/bloc/signout/signout_bloc.dart';
import 'package:pipe_code_flutter/repositories/interfaces/signout_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'package:pipe_code_flutter/bloc/spare_qr/spare_qr_bloc.dart';
import 'package:pipe_code_flutter/repositories/interfaces/spareqr_repository.dart';
import 'package:pipe_code_flutter/cubits/signin_detail_cubit.dart';
import 'package:pipe_code_flutter/repositories/interfaces/signin_repository.dart';
import 'package:pipe_code_flutter/cubits/temporary_auth.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/pages/install/install_page.dart';
import 'package:pipe_code_flutter/pages/install/install_detail_page.dart';
import 'package:pipe_code_flutter/pages/material/material_lifecycle_page.dart';
import 'package:pipe_code_flutter/pages/qmap/qmap.dart';
import 'package:pipe_code_flutter/pages/qmap/warehouse_detail.dart';
import 'package:pipe_code_flutter/pages/qmap/project_detail.dart';
import 'package:pipe_code_flutter/pages/scrap/scrap_pages.dart';
import 'package:pipe_code_flutter/pages/signin/signin_detail_page.dart';
import 'package:pipe_code_flutter/pages/signout/signout_audit_page.dart';
import 'package:pipe_code_flutter/pages/signout/signout_page.dart';
import 'package:pipe_code_flutter/pages/signout/signout_detail_page.dart';
import 'package:pipe_code_flutter/pages/spare_qr/spare_qr_page.dart';
import 'package:pipe_code_flutter/pages/temporary_auth/temporary_auth_page.dart';
import 'package:pipe_code_flutter/utils/tracing_navigator_observer.dart';
import 'package:pipe_code_flutter/widgets/pdf_previewer/pdf_previewer.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/boot_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/cut/cut_page.dart';
import '../pages/dispatch/dispatch_application_page.dart';
import '../pages/dispatch/dispatch_after_signin_page.dart';
import '../pages/main_page.dart';
import '../pages/recovery/recovery_pages.dart';
import '../pages/qr_scan/qr_scan_page.dart';
import '../pages/acceptance/acceptance_page.dart';
import '../pages/acceptance/acceptance_detail_page.dart';
import '../pages/acceptance/acceptance_confirmation_page.dart';
import '../pages/acceptance/acceptance_after_signin_page.dart';
import '../pages/acceptance/jsf_acceptance_page.dart';
import '../pages/dispatch/dispatch_confirmation_page.dart';
import '../pages/dispatch/dispatch_detail_page.dart';
import '../bloc/acceptance/acceptance_bloc.dart';
import '../pages/developer_settings_page.dart';
import '../pages/project_initiation/project_initiation_form_page.dart';
import '../pages/project_initiation/material_selection_page.dart';
import '../pages/records/records_list_page.dart';
import '../bloc/qr_scan/qr_scan_bloc.dart';
import '../services/qr_scan_service.dart';
import '../bloc/records/records_bloc.dart';
import '../cubits/material_selection_cubit.dart';
import '../models/qr_scan/qr_scan_config.dart';
import '../models/project/project_initiation.dart';
import '../models/records/record_type.dart';
import '../pages/material/material_detail_page.dart';
import '../pages/material/pipe_cutting_record_page.dart';
import '../bloc/material_detail/material_detail_bloc.dart';
import '../pages/return/return_page.dart';
import '../pages/return/return_detail_page.dart';
import '../bloc/return/return_bloc.dart';
import '../repositories/interfaces/return_repository.dart';
import '../repositories/interfaces/scrap_repository.dart';
import '../pages/inventory/inventory_list_page.dart';
import '../pages/inventory/inventory_page.dart';
import '../pages/inventory/inventory_detail_page.dart';
import '../pages/notification/pending_todo_list_page.dart';
import '../pages/storekeeper/storekeeper_non_project_page.dart';
import '../bloc/storekeeper_non_project/storekeeper_non_project_bloc.dart';
import '../repositories/interfaces/storekeeper_non_project_repository.dart';
import '../services/qr_scan_flow/qr_scan_flow_service.dart';
import '../pages/profile/change_password_page.dart';
import '../pages/privacy/privacy_policy_page.dart';
import 'service_locator.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/boot',
  observers: [TracingNavigatorObserver()],
  routes: [
    GoRoute(
      path: '/boot',
      name: 'boot',
      builder: (context, state) => const BootPage(),
    ),
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
          path: 'dispatch-application',
          name: 'dispatch-application',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            final codes = data?['codes'] as List<String>?;
            if (codes == null || codes.isEmpty) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return DispatchApplicationPage(initialCodes: codes);
          },
        ),
        GoRoute(
          path: 'spare-qr',
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
          path: 'qr-scan',
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
          path: 'acceptance',
          name: 'acceptance',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            final materials = data?['materialInfo'] as MaterialInfoForBusiness?;
            final codes = data?['codes'] as List<String>?;
            final isBatch = (data?['isBatch'] as bool?) ?? false;
            return BlocProvider(
              create: (context) => getIt<AcceptanceBloc>(),
              child: AcceptancePage(
                materials: materials,
                initialCodes: codes,
                initialIsBatch: isBatch,
              ),
            );
          },
        ),
        GoRoute(
          path: 'acceptance-detail',
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
              create: (context) => getIt<AcceptanceBloc>(),
              child: AcceptanceDetailPage(acceptanceId: acceptanceId),
            );
          },
        ),
        GoRoute(
          path: 'acceptance-confirmation',
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
              create: (context) => getIt<AcceptanceBloc>(),
              child: AcceptanceConfirmationPage(acceptanceId: acceptanceId),
            );
          },
        ),
        GoRoute(
          path: 'acceptance-after-signin',
          name: 'acceptance-after-signin',
          builder: (context, state) {
            final acceptanceIdParam = state.uri.queryParameters['id'];
            final acceptanceId = acceptanceIdParam != null
                ? int.tryParse(acceptanceIdParam)
                : null;
            if (acceptanceId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return MultiBlocProvider(
              providers: [
                BlocProvider<AcceptanceBloc>(
                  create: (context) => getIt<AcceptanceBloc>(),
                ),
                BlocProvider<MaterialHandleCubit>(
                  create: (context) => MaterialHandleCubit(),
                ),
              ],
              child: AcceptanceAfterSigninPage(acceptanceId: acceptanceId),
            );
          },
        ),
        GoRoute(
          path: 'jsf-acceptance',
          name: 'jsf-acceptance',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            final materials = data?['materialInfo'] as MaterialInfoForBusiness?;
            final codes = data?['codes'] as List<String>?;
            final isBatch = (data?['isBatch'] as bool?) ?? false;
            return JsfAcceptancePage(
              materials: materials,
              initialCodes: codes,
              initialIsBatch: isBatch,
            );
          },
        ),
        GoRoute(
          path: 'dispatch-confirmation',
          name: 'dispatch-confirmation',
          builder: (context, state) {
            final dispatchIdParam = state.uri.queryParameters['id'];
            final dispatchId = dispatchIdParam != null
                ? int.tryParse(dispatchIdParam)
                : null;
            if (dispatchId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return DispatchConfirmationPage(dispatchId: dispatchId);
          },
        ),
        GoRoute(
          path: 'dispatch-detail',
          name: 'dispatch-detail',
          builder: (context, state) {
            final dispatchIdParam = state.uri.queryParameters['id'];
            final dispatchId = dispatchIdParam != null
                ? int.tryParse(dispatchIdParam)
                : null;
            if (dispatchId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return DispatchDetailPage(dispatchId: dispatchId);
          },
        ),
        GoRoute(
          path: 'dispatch-after-signin',
          name: 'dispatch-after-signin',
          builder: (context, state) {
            final dispatchIdParam = state.uri.queryParameters['id'];
            final dispatchId = dispatchIdParam != null
                ? int.tryParse(dispatchIdParam)
                : null;
            if (dispatchId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return BlocProvider(
              create: (context) => MaterialHandleCubit(),
              child: DispatchAfterSigninPage(dispatchId: dispatchId),
            );
          },
        ),
        GoRoute(
          path: 'signin-detail',
          name: 'signin-detail',
          builder: (context, state) {
            final signinIdParam = state.uri.queryParameters['id'];
            final signinId = signinIdParam != null
                ? int.tryParse(signinIdParam)
                : null;
            if (signinId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return BlocProvider(
              create: (context) =>
                  SigninDetailCubit(signinRepository: getIt<SigninRepository>())
                    ..loadSigninDetail(signinId),
              child: SigninDetailPage(signinId: signinId),
            );
          },
        ),
        GoRoute(
          path: 'signout',
          name: 'signout',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            final codes = data != null ? data['codes'] as List<String>? : null;
            final isBatch =
                (data != null ? data['isBatch'] as bool? : null) ?? false;
            if (codes == null || codes.isEmpty) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return BlocProvider(
              create: (context) => SignoutBloc(
                getIt<SignoutRepository>(),
                getIt<MaterialHandleRepository>(),
              ),
              child: SignoutPage(initialCodes: codes, initialIsBatch: isBatch),
            );
          },
        ),
        GoRoute(
          path: 'signout-audit',
          name: 'signout-audit',
          builder: (context, state) {
            final signoutIdParam = state.uri.queryParameters['id'];
            final signoutId = signoutIdParam != null
                ? int.tryParse(signoutIdParam)
                : null;
            if (signoutId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return BlocProvider(
              create: (context) => SignoutBloc(
                getIt<SignoutRepository>(),
                getIt<MaterialHandleRepository>(),
              ),
              child: SignoutAuditPage(signoutId: signoutId),
            );
          },
        ),
        GoRoute(
          path: 'signout-detail',
          name: 'signout-detail',
          builder: (context, state) {
            final signoutIdParam = state.uri.queryParameters['id'];
            final signoutId = signoutIdParam != null
                ? int.tryParse(signoutIdParam)
                : null;
            if (signoutId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return BlocProvider(
              create: (context) => SignoutBloc(
                getIt<SignoutRepository>(),
                getIt<MaterialHandleRepository>(),
              ),
              child: SignoutDetailPage(signoutId: signoutId),
            );
          },
        ),
        GoRoute(
          path: 'recovery',
          name: 'recovery',
          builder: (context, state) {
            return const RecoveryPage();
          },
        ),
        GoRoute(
          path: 'install',
          name: 'install',
          builder: (context, state) {
            final signOutId = state.uri.queryParameters['id'];
            return BlocProvider(
              create: (context) => MaterialHandleCubit(),
              child: InstallPage(signOutId: signOutId),
            );
          },
        ),
        GoRoute(
          path: 'install-detail',
          name: 'install-detail',
          builder: (context, state) {
            final installIdParam = state.uri.queryParameters['id'];
            final installId = installIdParam != null
                ? int.tryParse(installIdParam)
                : null;
            if (installId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return InstallDetailPage(installId: installId);
          },
        ),
        GoRoute(
          path: 'records',
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
              create: (context) => getIt<RecordsBloc>(),
              child: RecordsListPage(initialTab: initialTab),
            );
          },
        ),
        GoRoute(
          path: 'material-detail',
          name: 'material-detail',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            if (data == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            final materialCode = data['codes'].first as String?;
            if (materialCode == null || materialCode.trim().isEmpty) {
              return const Scaffold(body: Center(child: Text('二维码内容无效')));
            }
            return MaterialDetailPage(materialCode: materialCode);
          },
          routes: [
            GoRoute(
              path: 'material-lifecycle',
              name: 'material-lifecycle',
              builder: (context, state) {
                final materialDetailBloc = state.extra as MaterialDetailBloc;
                final materialId = int.parse(
                  state.uri.queryParameters['materialId']!,
                );

                return BlocProvider.value(
                  value: materialDetailBloc,
                  child: MaterialLifecyclePage(materialId: materialId),
                );
              },
            ),
          ],
        ),
        // 独立的截管记录详情页面路由
        GoRoute(
          path: 'pipe-cutting-record',
          name: 'pipe-cutting-record',
          builder: (context, state) {
            final materialId = state.uri.queryParameters['materialId'];

            if (materialId == null || materialId.trim().isEmpty) {
              return const Scaffold(
                body: Center(child: Text('参数错误: materialId 缺失')),
              );
            }

            return PipeCuttingRecordPage(materialId: materialId);
          },
        ),
        GoRoute(
          path: 'project-initiation',
          name: 'project-initiation',
          builder: (context, state) {
            final projectId = state.uri.queryParameters['projectId'];
            return ProjectInitiationFormPage(
              projectId: projectId != null ? int.tryParse(projectId) : null,
            );
          },
          routes: [
            GoRoute(
              path: 'material-selection',
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
        GoRoute(
          path: 'return-material',
          name: 'return-material',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            if (data == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            if (data['codes'] == null ||
                (data['codes'] as List<String>).isEmpty) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return BlocProvider(
              create: (context) => ReturnBloc(
                returnRepository: getIt<ReturnRepository>(),
                materialHandleRepository: getIt<MaterialHandleRepository>(),
              ),
              child: ReturnPage(codes: data['codes'] as List<String>),
            );
          },
        ),
        GoRoute(
          path: 'return-detail',
          name: 'return-detail',
          builder: (context, state) {
            final returnIdParam = state.uri.queryParameters['id'];
            final returnId = returnIdParam != null
                ? int.tryParse(returnIdParam)
                : null;
            if (returnId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return BlocProvider(
              create: (context) => ReturnBloc(
                returnRepository: getIt<ReturnRepository>(),
                materialHandleRepository: getIt<MaterialHandleRepository>(),
              ),
              child: ReturnDetailPage(id: returnId),
            );
          },
        ),
        GoRoute(
          path: 'cut-pipe',
          name: 'cut-pipe',
          builder: (context, state) => const CutPage(),
        ),
        GoRoute(
          path: 'inventory',
          name: 'inventory-list',
          builder: (context, state) => const InventoryListPage(),
        ),
        GoRoute(
          path: 'inventory-apply',
          name: 'inventory-apply',
          builder: (context, state) {
            final taskId = state.extra as int?;
            if (taskId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return MultiBlocProvider(
              providers: [
                BlocProvider<MaterialHandleCubit>(
                  create: (context) => MaterialHandleCubit(),
                ),
              ],
              child: InventoryPage(taskId: taskId),
            );
          },
        ),
        GoRoute(
          path: 'inventory-detail',
          name: 'inventory-detail',
          builder: (context, state) {
            final taskId =
                int.tryParse(state.pathParameters['id'] ?? '') ??
                int.tryParse(state.uri.queryParameters['id'] ?? '');
            if (taskId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return BlocProvider<InventoryBloc>(
              create: (context) => getIt<InventoryBloc>(),
              child: InventoryDetailPage(taskId: taskId),
            );
          },
        ),
        GoRoute(
          path: 'scrap',
          name: 'scrap',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>?;
            if (data == null) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<ScrapBloc>(
                    create: (context) => ScrapBloc(
                      scrapRepository: getIt<ScrapRepository>(),
                      materialHandleRepository:
                          getIt<MaterialHandleRepository>(),
                    ),
                  ),
                  BlocProvider<MaterialHandleCubit>(
                    create: (context) => MaterialHandleCubit(),
                  ),
                ],
                child: ScrapPage(codes: [], materials: null),
              );
            } else {
              final codes = data['codes'] as List<String>?;
              final materials = data['materials'] as MaterialInfoForBusiness?;
              return MultiBlocProvider(
                providers: [
                  BlocProvider<ScrapBloc>(
                    create: (context) => ScrapBloc(
                      scrapRepository: getIt<ScrapRepository>(),
                      materialHandleRepository:
                          getIt<MaterialHandleRepository>(),
                    ),
                  ),
                  BlocProvider<MaterialHandleCubit>(
                    create: (context) => MaterialHandleCubit(),
                  ),
                ],
                child: ScrapPage(codes: codes, materials: materials),
              );
            }
          },
        ),
        GoRoute(
          path: 'scrap-detail',
          name: 'scrap-detail',
          builder: (context, state) {
            final scrapIdParam = state.uri.queryParameters['id'];
            final scrapId = scrapIdParam != null
                ? int.tryParse(scrapIdParam)
                : null;
            if (scrapId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return BlocProvider(
              create: (context) => ScrapBloc(
                scrapRepository: getIt<ScrapRepository>(),
                materialHandleRepository: getIt<MaterialHandleRepository>(),
              ),
              child: ScrapDetailPage(scrapId: scrapId),
            );
          },
        ),
        GoRoute(
          path: 'temporary-auth',
          name: 'temporary-auth',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => getIt<TemporaryAuthCubit>(),
              child: const TemporaryAuthPage(),
            );
          },
        ),
        GoRoute(
          path: 'qmap',
          name: 'qmap',
          builder: (context, state) => const Qmap(),
        ),
        GoRoute(
          path: 'warehouseDetail',
          name: 'warehouseDetail',
          builder: (context, state) {
            final idParam = state.uri.queryParameters['id'];
            final warehouseId = idParam != null ? int.tryParse(idParam) : null;
            if (warehouseId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return WarehouseDetailPage(warehouseId: warehouseId);
          },
        ),
        GoRoute(
          path: 'projectDetail',
          name: 'projectDetail',
          builder: (context, state) {
            final idParam = state.uri.queryParameters['id'];
            final projectId = idParam != null ? int.tryParse(idParam) : null;
            if (projectId == null) {
              return const Scaffold(body: Center(child: Text('参数错误')));
            }
            return ProjectDetailPage(projectId: projectId);
          },
        ),
      ],
    ),

    GoRoute(
      path: '/developer-settings',
      name: 'developer-settings',
      builder: (context, state) => const DeveloperSettingsPage(),
    ),
    GoRoute(
      path: '/pending-todo',
      name: 'pending-todo',
      builder: (context, state) => const PendingTodoListPage(),
    ),
    GoRoute(
      path: '/pdf-preview',
      name: 'pdf-preview',
      builder: (context, state) {
        final url = state.extra as String?;
        if (url == null) {
          return const Scaffold(body: Center(child: Text('参数错误')));
        }
        return PdfPreviewer(url: url);
      },
    ),
    GoRoute(
      path: '/storekeeper-non-project',
      name: 'storekeeper-non-project',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => StorekeeperNonProjectBloc(
            repository: getIt<StorekeeperNonProjectRepository>(),
            qrScanFlowService: getIt<QrScanFlowService>(),
          ),
          child: const StorekeeperNonProjectPage(),
        );
      },
    ),
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: '/privacy-policy',
      name: 'privacy-policy',
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
  ],
);
