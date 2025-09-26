import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../services/privacy_policy_service.dart';
import '../../config/service_locator.dart' as sl;
import '../../widgets/privacy/privacy_compliance_dialog.dart';

/// BootPage: 应用启动页
/// - 首先检查隐私政策合规性
/// - 然后进行身份验证检查
/// - 根据结果导航到相应页面
class BootPage extends StatefulWidget {
  const BootPage({super.key});

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {
  bool _dispatched = false;
  bool _navigated = false;
  bool _privacyChecked = false;

  @override
  void initState() {
    super.initState();
    // 在下一帧开始后进行检查，避免在构建期间调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPrivacyPolicyAndAuth();
    });
  }

  /// 检查隐私政策和身份验证的完整流程
  Future<void> _checkPrivacyPolicyAndAuth() async {
    if (_privacyChecked) return;

    // 确保widget已经完成构建
    if (!mounted) return;

    try {
      // 1. 首先检查隐私政策
      final privacyService = sl.getIt<PrivacyPolicyService>();
      if (privacyService.shouldShowPrivacyPolicy()) {
        final agreed = await PrivacyComplianceDialog.show(context);
        if (!agreed) {
          // 用户不同意隐私政策，应用无法继续使用
          // PrivacyComplianceDialog 内部已处理退出逻辑
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        _privacyChecked = true;
      });

      // 2. 隐私政策检查通过后，进行身份验证检查
      final state = context.read<AuthBloc>().state;
      // 仅当初始状态时派发一次检查，避免干扰已有流程
      if (!_dispatched && state is AuthInitial) {
        context.read<AuthBloc>().add(AuthCheckRequested());
        setState(() {
          _dispatched = true;
        });
      }
    } catch (e) {
      // 处理可能的异常，确保应用不会卡在加载页面
      if (mounted) {
        setState(() {
          _privacyChecked = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;

    // 如果在构建时已经有最终态，立刻导航（只执行一次）
    if (!_navigated && _privacyChecked) {
      if (state is AuthLoginSuccess) {
        _navigated = true;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.goNamed('main'),
        );
      } else if (state is AuthUnauthenticated || state is AuthLoginFailure) {
        _navigated = true;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.goNamed('login'),
        );
      }
    }

    // 动态显示状态信息
    String statusText = '正在准备应用…';
    if (!_privacyChecked) {
      statusText = '正在检查隐私政策…';
    } else if (_dispatched) {
      statusText = '正在验证身份…';
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(statusText),
            ],
          ),
        ),
      ),
    );
  }
}
