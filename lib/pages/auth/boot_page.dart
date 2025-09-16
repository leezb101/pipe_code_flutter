import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

/// BootPage: 单职责启动路由
/// - 进入时触发一次 AuthCheckRequested（仅当当前状态为初始态）
/// - 根据 AuthState 决定跳转到 / 或 /login
/// 这样可以避免自动登录期间展示 /login 的闪屏或卡在初始化
class BootPage extends StatefulWidget {
  const BootPage({super.key});

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {
  bool _dispatched = false;
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AuthBloc>().state;
    // 仅当初始状态时派发一次检查，避免干扰已有流程
    if (!_dispatched && state is AuthInitial) {
      context.read<AuthBloc>().add(AuthCheckRequested());
      _dispatched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;

    // 如果在构建时已经有最终态，立刻导航（只执行一次）
    if (!_navigated) {
      if (state is AuthLoginSuccess) {
        _navigated = true;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.goNamed('main'),
        );
      } else if (state is AuthUnauthenticated || state is AuthLoginFailure) {
        _navigated = true;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.go('/login'),
        );
      }
    }

    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('正在准备应用…'),
            ],
          ),
        ),
      ),
    );
  }
}
