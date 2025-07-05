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
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
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
                        subtitle: Text(userState.user.username),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: Text(userState.user.email.isEmpty ? 'No email' : userState.user.email),
                      ),
                    ),
                    if (userState.user.firstName != null || userState.user.lastName != null)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.badge),
                          title: const Text('Name'),
                          subtitle: ('${userState.user.firstName ?? ''} ${userState.user.lastName ?? ''}').trim().isEmpty 
                            ? const Text('No name set')
                            : Text('${userState.user.firstName ?? ''} ${userState.user.lastName ?? ''}'),
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
                        leading: const Icon(Icons.developer_mode, color: Colors.orange),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
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
}