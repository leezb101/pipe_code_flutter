import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../config/app_config.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/services/storage_service.dart';
import 'package:pipe_code_flutter/services/sse/sse_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // 只有当当前状态不是已加载状态时，才触发加载
    final currentState = context.read<UserBloc>().state;
    if (currentState is UserInitial || currentState is UserEmpty) {
      context.read<UserBloc>().add(const UserLoadRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Ensure SSE is fully disconnected when user logs out
            getIt<SseService>().disconnect();
            context.pushReplacementNamed('login');
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // 头部用户信息区域
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person, size: 30),
                        ),
                        const SizedBox(height: 16),
                        if (userState is UserLoaded) ...[
                          Text(
                            userState.wxLoginVO.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (userState.wxLoginVO.phone.isNotEmpty)
                            Text(
                              userState.wxLoginVO.phone,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ] else if (userState is UserLoading) ...[
                          const Text(
                            '加载中...',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            '未登录',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 功能菜单区域
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '功能菜单',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // QMap功能
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.map, color: Colors.blue),
                            title: const Text('QMap'),
                            subtitle: const Text('查看地图示例'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              context.pushNamed('qmap');
                            },
                          ),
                        ),

                        // 修改密码
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.lock_reset_outlined,
                              color: Colors.orange,
                            ),
                            title: const Text('修改密码'),
                            subtitle: const Text('更改账户密码'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              context.pushNamed('change-password');
                            },
                          ),
                        ),

                        // 清除本机记住信息
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.cleaning_services_outlined,
                              color: Colors.purple,
                            ),
                            title: const Text('清除记住信息'),
                            subtitle: const Text('清除此用户在本机记住的信息'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () =>
                                _showClearRememberedInfoDialog(context),
                          ),
                        ),

                        // Developer Settings (only in development)
                        if (AppConfig.isDevelopment) ...[
                          Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: Colors.orange.shade50,
                            child: ListTile(
                              leading: const Icon(
                                Icons.developer_mode,
                                color: Colors.orange,
                              ),
                              title: const Text('开发者设置'),
                              subtitle: Text(
                                'Data Source: ${AppConfig.isMockEnabled ? "Mock" : "API"}',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                context.pushNamed('developer-settings');
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // 系统设置区域
                        const Text(
                          '系统设置',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 退出登录
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            title: const Text('退出登录'),
                            subtitle: const Text('退出当前账户'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 底部信息
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'App Version: 1.0.0',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Flutter Bloc Template',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('退出登录'),
          content: const Text('确定退出登录吗？'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),
          ],
        );
      },
    );
  }

  void _showClearRememberedInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('清除记住的信息'),
          content: const Text('这将清除此用户在本机保存的项目选择等偏好信息，是否继续？'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('清除'),
              onPressed: () async {
                Navigator.of(context).pop();
                final storage = getIt<StorageService>();
                await storage.clearUserRememberedInfo();
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('已清除本机记住的信息')));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
