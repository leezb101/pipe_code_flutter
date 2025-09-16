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
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/config/tracing_route_mappings.dart';
import 'package:pipe_code_flutter/repositories/interfaces/spareqr_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/services/tracing/tracing_context.dart';
import 'package:pipe_code_flutter/services/tracing/tracing_manager.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
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
import 'package:get_it/get_it.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  static const platform = MethodChannel('com.zzwater.pipe_code_trace');

  int _currentIndex = 0;
  final TracingManager _tracingManager = getIt<TracingManager>();
  List<String> _routeNames = [];
  bool _isUiInitialized = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Widget> _pages = [];
  // 用于动态存储当前角色对应的页面、路由名和导航项
  List<BottomNavigationBarItem> _navItems = [];

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

  void _initializePagesAndNavigation() {
    // 默认为普通用户配置（3个标签页）
    _pages = [
      RepositoryProvider(
        create: (context) => (GetIt.instance<SpareqrRepository>()),
        child: const HomePage(),
      ),
      BlocProvider(
        create: (context) => RecordsBloc(GetIt.instance<RecordsRepository>()),
        child: const RecordsListPage(),
      ),
      const ProfilePage(),
    ];

    _navItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
      BottomNavigationBarItem(icon: Icon(Icons.list), label: '记录'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
    ];
  }

  void _updatePagesForAdmin() {
    // 管理方用户配置（2个标签页：首页 + 我的）
    _pages = [
      const AdminHomePage(), // 管理方专属首页
      const ProfilePage(),
    ];

    _navItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
    ];

    // 重置当前索引，防止越界
    if (_currentIndex >= _pages.length) {
      _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tracingManager.popContext();
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
            context.go('/login');
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
          bottomNavigationBar: BottomNavigationBar(
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
            items: _navItems,
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
      _navItems = const [
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
    } else {
      _pages = [const HomePage(), const RecordsListPage(), const ProfilePage()];
      _routeNames = [
        homeTabRouteName,
        recordsTabRouteName,
        profileTabRouteName,
      ];
      _navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt),
          label: '记录',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '我的',
        ),
      ];
    }
  }

  /// Tracing 方法：更新当前 Tab 的上下文
  void _updateTabContext(int index, {bool isInitial = false}) {
    // 对于非首次加载（即用户手动切换 Tab），先弹出上一个 Tab 的上下文。
    if (!isInitial) {
      _tracingManager.popContext();
    }

    // 确保索引在安全范围内
    if (index < _routeNames.length) {
      final routeName = _routeNames[index];
      final tracingInfo = tracingRouteMappings[routeName];

      if (tracingInfo != null) {
        final context = TracingContext(
          source: tracingInfo.source,
          action: isInitial ? 'enter_main_subpage' : 'switch_tab',
          description: tracingInfo.description,
        );
        _tracingManager.pushContext(context);
      }
    }
  }

  /// 根据会话状态更新页面配置
  void _updatePagesBasedOnSession(SessionState sessionState) {
    if (sessionState is SessionAdminEstablished) {
      // 管理方用户：首页 + 我的
      if (_pages.length != 2 || _pages[0] is! AdminHomePage) {
        _updatePagesForAdmin();
      }
    } else {
      // 普通用户：首页 + 记录 + 我的
      if (_pages.length != 3 || _pages[0] is AdminHomePage) {
        _initializePagesAndNavigation();
      }
    }
  }
}
