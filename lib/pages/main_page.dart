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
import 'package:pipe_code_flutter/repositories/interfaces/spareqr_repository.dart';
import 'package:go_router/go_router.dart';
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Future<void> _moveToBack() async {
    try {
      await platform.invokeMethod('moveTaskToBack');
    } on PlatformException catch (e) {
      Logger.error("Failed to move task to back: '${e.message}'.");
    }
  }

  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _initializePagesAndNavigation();
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
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, sessionState) {
        // 根据会话状态决定页面配置
        _updatePagesBasedOnSession(sessionState);

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
              }
            },
            items: _navItems,
          ),
        );
      },
    );
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
