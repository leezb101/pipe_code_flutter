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
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: '清除此用户在本机记住的信息',
            onPressed: () => _showClearRememberedInfoDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    child: Icon(Icons.person, size: 60),
                  ),
                  const SizedBox(height: 20),
                  if (userState is UserLoaded) ...[
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Username'),
                        subtitle: Text(userState.wxLoginVO.account ?? '用户'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: Text(
                          userState.wxLoginVO.phone.isEmpty
                              ? 'No email'
                              : userState.wxLoginVO.phone,
                        ),
                      ),
                    ),
                    if (userState.wxLoginVO.nick != null)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.badge),
                          title: const Text('Name'),
                          subtitle:
                              ('${userState.wxLoginVO.name} ${userState.wxLoginVO.nick ?? ''}')
                                  .trim()
                                  .isEmpty
                              ? const Text('No name set')
                              : Text(
                                  '${userState.wxLoginVO.name} ${userState.wxLoginVO.nick ?? ''}',
                                ),
                        ),
                      ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.map),
                        title: const Text('ArcGIS Map'),
                        subtitle: const Text('View ArcGIS Map Example'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          context.pushNamed('arcgis-map');
                        },
                      ),
                    ),
                  ] else if (userState is UserLoading) ...[
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Username'),
                        subtitle: Text('Loading...'),
                      ),
                    ),
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.email),
                        title: Text('Email'),
                        subtitle: Text('Loading...'),
                      ),
                    ),
                  ] else ...[
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Username'),
                        subtitle: Text('Not available'),
                      ),
                    ),
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.email),
                        title: Text('Email'),
                        subtitle: Text('Not available'),
                      ),
                    ),
                  ],
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.info),
                      title: Text('App Version'),
                      subtitle: Text('1.0.0'),
                    ),
                  ),
                  // Developer Settings (only in development)
                  if (AppConfig.isDevelopment) ...[
                    const SizedBox(height: 8),
                    Card(
                      color: Colors.orange.shade50,
                      child: ListTile(
                        leading: const Icon(
                          Icons.developer_mode,
                          color: Colors.orange,
                        ),
                        title: const Text('Developer Settings'),
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
                  const Spacer(),
                  const Text(
                    'Flutter Bloc Template',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Logout'),
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
