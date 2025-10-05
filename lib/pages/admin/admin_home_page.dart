/*
 * @Author: LeeZB
 * @Date: 2025-09-10 00:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-10 00:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../bloc/session/session_bloc.dart';
import '../../bloc/session/session_state.dart';
import '../../utils/toast_utils.dart';
import '../../models/qr_scan/qr_scan_config.dart';
import '../../services/tracing/improved_tracing_manager.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理中心'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, sessionState) {
          if (sessionState is SessionAdminEstablished) {
            return _buildAdminContent(context, sessionState);
          }
          return const Center(child: Text('会话状态异常'));
        },
      ),
    );
  }

  /// 构建管理方首页内容
  Widget _buildAdminContent(
    BuildContext context,
    SessionAdminEstablished state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await GetIt.instance<ImprovedTracingManager>().scopeActionWithTitle(
          '下拉刷新管理中心',
          () async {
            // 管理员页面暂时没有实际的数据加载逻辑
            await Future.delayed(const Duration(milliseconds: 500));
          },
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context, state.wxLoginVO),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildFunctionModules(context),
          ],
        ),
      ),
    );
  }

  /// 构建欢迎卡片
  Widget _buildWelcomeCard(BuildContext context, dynamic wxLoginVO) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[600]!, Colors.blue[800]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  wxLoginVO.name.isNotEmpty ? wxLoginVO.name[0] : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '欢迎回来，${wxLoginVO.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wxLoginVO.admin ? '系统管理员' : '管理层',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建快捷操作
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快捷功能',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context: context,
                title: '扫码识别',
                icon: Icons.qr_code_scanner,
                color: Colors.orange,
                onTap: () => _navigateToScan(
                  context,
                  QrScanConfig(
                    scanMode: QrScanMode.single,
                    context: const {
                      'entry': 'standalone',
                      'route': '/material-detail',
                      'data': <String, dynamic>{},
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context: context,
                title: '地图查看',
                icon: Icons.map,
                color: Colors.green,
                onTap: () => _navigateToMap(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建功能模块
  Widget _buildFunctionModules(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '功能模块',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildModuleCard(
          context: context,
          title: '待办事项',
          subtitle: '查看系统待办任务',
          icon: Icons.task_alt,
          color: Colors.blue,
          onTap: () => _showComingSoon(context, '待办事项'),
        ),
        // const SizedBox(height: 12),
        // _buildModuleCard(
        //   context: context,
        //   title: '数据统计',
        //   subtitle: '查看系统运营数据',
        //   icon: Icons.analytics,
        //   color: Colors.purple,
        //   onTap: () => _showComingSoon(context, '数据统计'),
        // ),
        // const SizedBox(height: 12),
        // _buildModuleCard(
        //   context: context,
        //   title: '系统管理',
        //   subtitle: '系统配置与管理',
        //   icon: Icons.settings,
        //   color: Colors.grey,
        //   onTap: () => _showComingSoon(context, '系统管理'),
        // ),
      ],
    );
  }

  /// 构建操作卡片
  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建模块卡片
  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  /// 导航到扫码页面（使用GoRouter）
  void _navigateToScan(BuildContext context, QrScanConfig config) async {
    final result = await context.pushNamed('qr-scan', extra: config);
    if (result != null && context.mounted) {
      // _showScanResult(context, result, config);
    }
  }

  /// 导航到地图页面
  void _navigateToMap(BuildContext context) {
    context.pushNamed('qmap');
  }

  /// 显示开发中提示
  void _showComingSoon(BuildContext context, String feature) {
    context.showInfoToast('$feature功能正在开发中，敬请期待！');
  }
}
