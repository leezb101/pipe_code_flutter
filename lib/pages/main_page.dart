/*
 * @Author: LeeZB
 * @Date: 2025-07-29 19:58:49
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-01 18:50:25
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_state.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/config/tracing_route_mappings.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/services/tracing/tracing_context.dart';
import 'package:pipe_code_flutter/services/tracing/improved_tracing_manager.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/models/records/record_type.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/session/session_bloc.dart';
import '../bloc/session/session_state.dart';
import '../pages/home/home_page.dart';
import '../pages/records/records_list_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/admin/admin_home_page.dart';
import '../widgets/session_guard.dart';
import '../bloc/records/records_bloc.dart';
import '../repositories/interfaces/records_repository.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  static const platform = MethodChannel('com.zzwater.pipe_code_trace');

  int _currentIndex = 0;
  final ImprovedTracingManager _tracingManager =
      getIt<ImprovedTracingManager>();
  List<String> _routeNames = [];
  bool _isUiInitialized = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Widget> _pages = [];
  // 页面集合（根据身份动态配置）

  Future<void> _moveToBack() async {
    try {
      await platform.invokeMethod('moveTaskToBack');
    } on PlatformException catch (e) {
      Logger.error("Failed to move task to back: '${e.message}'.");
    }
  }

  @override
  void initState() {
    super.initState();
    // _initializePagesAndNavigation();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  //（移除旧初始化方法，统一使用 _setupTabsForRole）

  @override
  void dispose() {
    _animationController.dispose();
    _tracingManager.popPageContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _moveToBack();
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // 用户未认证，跳转到登录页面
            context.goNamed('login');
          }
        },
        child: SessionGuard(child: _buildMainInterface()),
      ),
    );
  }

  /// 构建主界面
  Widget _buildMainInterface() {
    return BlocConsumer<SessionBloc, SessionState>(
      listener: (context, state) {
        if ((state is SessionAdminEstablished ||
                state is SessionProjectEstablished ||
                state is SessionStorekeeperEstablished) &&
            !_isUiInitialized) {
          // 根据用户角色初始化标签页和导航
          bool isAdmin = state is SessionAdminEstablished;
          _setupTabsForRole(isAdmin);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _updateTabContext(0, isInitial: true);
            }
          });
          setState(() {
            _isUiInitialized = true;
          });
        }
      },
      builder: (context, sessionState) {
        // 首次挂载后可能错过已建立状态的变更（例如仓管员场景不会有后续状态刷新），
        // 因此在 builder 中检测一次并进行初始化，确保 UI 能正确展示。
        if (!_isUiInitialized &&
            (sessionState is SessionAdminEstablished ||
                sessionState is SessionProjectEstablished ||
                sessionState is SessionStorekeeperEstablished)) {
          final bool isAdmin = sessionState is SessionAdminEstablished;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _isUiInitialized) return;
            _setupTabsForRole(isAdmin);
            _updateTabContext(0, isInitial: true);
            setState(() {
              _isUiInitialized = true;
            });
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!_isUiInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
          bottomNavigationBar: BlocBuilder<RecordsBloc, RecordsState>(
            builder: (context, recordsState) {
              final isAdmin = sessionState is SessionAdminEstablished;
              final todoCount = _computeTodoBadgeCount(
                recordsState,
                sessionState,
              );
              final items = _buildNavItemsWithBadge(todoCount, isAdmin);
              return BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                onTap: (index) {
                  if (index != _currentIndex) {
                    _animationController.reset();
                    setState(() {
                      _currentIndex = index;
                    });
                    _animationController.forward();
                    _updateTabContext(index);
                  }
                },
                items: items,
              );
            },
          ),
        );
      },
    );
  }

  /// 根据会话状态更新页面和追踪配置
  void _setupTabsForRole(bool isAdmin) {
    if (isAdmin) {
      _pages = [const AdminHomePage(), const ProfilePage()];
      _routeNames = [adminHomeTabRouteName, profileTabRouteName];
    } else {
      // 普通用户：首页、记录、我的
      _pages = [const HomePage(), const RecordsListPage(), const ProfilePage()];
      _routeNames = [
        homeTabRouteName,
        recordsTabRouteName,
        profileTabRouteName,
      ];
    }
  }

  /// Tracing 方法：更新当前 Tab 的上下文
  void _updateTabContext(int index, {bool isInitial = false}) {
    // 对于非首次加载（即用户手动切换 Tab），先弹出上一个 Tab 的上下文。
    if (!isInitial) {
      _tracingManager.popPageContext();
    }

    // 确保索引在安全范围内
    if (index < _routeNames.length) {
      final routeName = _routeNames[index];
      final tracingInfo = tracingRouteMappings[routeName];

      if (tracingInfo != null) {
        final context = TracingContext(
          source: tracingInfo.source,
          action: isInitial
              ? '进入${tracingInfo.description}'
              : index == 0
              ? '首页'
              : index == 1
              ? '记录'
              : '我的',
          description: tracingInfo.description,
        );
        _tracingManager.pushPageContext(context);
      }
    }
  }

  ///（已移除）旧的基于会话状态的页面更新逻辑由 _setupTabsForRole 统一处理

  // ==== Helpers for badge/count ====
  int _computeTodoBadgeCount(
    RecordsState recordsState,
    SessionState sessionState,
  ) {
    final ids = _resolveIds(sessionState);
    final int? uid = ids.$1;
    final int? pid = ids.$2;

    // counts from current state (if visible tab)
    int todoFromState = 0;
    int whFromState = 0;
    if (recordsState is RecordsLoaded) {
      if (recordsState.currentTab == RecordType.todo) {
        todoFromState = recordsState.records.length;
      } else if (recordsState.currentTab == RecordType.warehouseTodo) {
        whFromState = recordsState.records.length;
      }
    }

    // counts from cache
    int todoFromCache = 0;
    int whFromCache = 0;
    try {
      final repo = getIt<RecordsRepository>();
      todoFromCache =
          repo
              .getCachedRecords(RecordType.todo, userId: uid, projectId: pid)
              ?.length ??
          0;
      if (sessionState is SessionStorekeeperEstablished) {
        whFromCache =
            repo
                .getCachedRecords(
                  RecordType.warehouseTodo,
                  userId: uid,
                  projectId: pid,
                )
                ?.length ??
            0;
      }
    } catch (_) {
      // ignore cache failures
    }

    // prefer state over cache for whichever tab is currently active
    final int todoFinal = todoFromState > 0 ? todoFromState : todoFromCache;
    final bool includeWarehouse = sessionState is SessionStorekeeperEstablished;
    final int whFinal = includeWarehouse
        ? (whFromState > 0 ? whFromState : whFromCache)
        : 0;
    return todoFinal + whFinal;
  }

  List<BottomNavigationBarItem> _buildNavItemsWithBadge(
    int todoCount,
    bool isAdmin,
  ) {
    if (isAdmin) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: '管理',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '我的',
        ),
      ];
    }

    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: '首页',
      ),
      BottomNavigationBarItem(
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.list_alt_outlined),
            if (todoCount > 0)
              Positioned(right: -6, top: -3, child: _Badge(count: todoCount)),
          ],
        ),
        activeIcon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.list_alt),
            if (todoCount > 0)
              Positioned(right: -6, top: -3, child: _Badge(count: todoCount)),
          ],
        ),
        label: '记录',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: '我的',
      ),
    ];
  }

  // Copy of resolve from records_list_page for consistency
  (int?, int?) _resolveIds(SessionState sessionState) {
    int? uid;
    int? pid;
    if (sessionState is SessionProjectEstablished) {
      uid = int.tryParse(sessionState.user.id);
      pid = sessionState.project.projectId;
    } else if (sessionState is SessionStorekeeperEstablished) {
      uid = int.tryParse(sessionState.user.id);
    }
    return (uid, pid);
  }
}

// Simple badge widget used in BottomNavigationBar icons
class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final String text = count > 99 ? '99+' : count.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 16),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
