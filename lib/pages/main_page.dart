import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/repositories/spareqr_repository.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../pages/home/home_page.dart';
import '../pages/records/records_list_page.dart';
import '../pages/profile/profile_page.dart';
import '../widgets/session_guard.dart';
import '../bloc/records/records_bloc.dart';
import '../repositories/records_repository.dart';
import 'package:get_it/get_it.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _pages = [
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // 用户未认证，跳转到登录页面
          context.go('/login');
        }
      },
      child: SessionGuard(
        child: _buildMainInterface(),
      ),
    );
  }

  /// 构建主界面
  Widget _buildMainInterface() {
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '记录'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}