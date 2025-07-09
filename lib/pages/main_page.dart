import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_state.dart';
import '../bloc/user/user_event.dart';
import '../bloc/project/project_bloc.dart';
import '../bloc/project/project_state.dart';
import '../bloc/project/project_event.dart';
import '../pages/home/home_page.dart';
import '../pages/list/list_page.dart';
import '../pages/profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _pages = const [
    HomePage(),
    ListPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    
    // 初始化项目状态管理
    _initializeProjectState();
  }

  void _initializeProjectState() {
    // 检查认证状态并加载用户数据
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      // 触发用户数据加载
      context.read<UserBloc>().add(UserSetData(wxLoginVO: authState.wxLoginVO));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 监听用户状态变化，触发项目列表加载
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserLoaded) {
              context.read<ProjectBloc>().add(
                ProjectLoadUserProjects(wxLoginVO: state.wxLoginVO),
              );
            }
          },
        ),
        // 监听认证状态变化
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoginSuccess) {
              // 登录成功后设置用户数据
              context.read<UserBloc>().add(UserSetData(wxLoginVO: state.wxLoginVO));
            } else if (state is AuthUnauthenticated) {
              // 用户未认证，清除所有状态
              context.read<UserBloc>().add(const UserClearData());
              context.read<ProjectBloc>().add(const ProjectClearData());
            }
          },
        ),
      ],
      child: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, projectState) {
          // 如果项目状态为初始状态，显示加载界面
          if (projectState is ProjectInitial) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // 如果项目状态有错误，显示错误界面
          if (projectState is ProjectError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('加载项目信息失败: ${projectState.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // 重新加载项目数据
                        final userState = context.read<UserBloc>().state;
                        if (userState is UserLoaded) {
                          context.read<ProjectBloc>().add(
                            ProjectLoadUserProjects(wxLoginVO: userState.wxLoginVO),
                          );
                        }
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // 如果项目状态为加载中，也显示正常主界面（让HomePage处理loading状态）
          if (projectState is ProjectLoading) {
            return Scaffold(
              body: FadeTransition(
                opacity: _fadeAnimation,
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
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
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    label: 'List',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            );
          }
          
          // 正常显示主界面
          return Scaffold(
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'List',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}