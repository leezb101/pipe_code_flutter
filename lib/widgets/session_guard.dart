/*
 * @Author: LeeZB
 * @Date: 2025-07-29 15:45:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-29 20:00:53
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/session/session_bloc.dart';
import '../bloc/session/session_state.dart';
import '../bloc/session/session_event.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import 'identity_selector.dart';
import 'project_selector.dart';

/// 会话状态守护组件 - 根据会话状态决定显示哪个界面
class SessionGuard extends StatefulWidget {
  const SessionGuard({super.key, required this.child});

  /// 会话建立后显示的子组件（通常是主界面）
  final Widget child;

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  /// 初始化会话
  void _initializeSession() {
    // 监听认证状态，当登录成功时初始化会话
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      context.read<SessionBloc>().add(
        SessionInitializeRequested(wxLoginVO: authState.wxLoginVO),
      );
      // 同时设置用户数据
      context.read<UserBloc>().add(UserSetData(wxLoginVO: authState.wxLoginVO));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 监听认证状态变化
        BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState is AuthLoginSuccess) {
              // 登录成功，初始化会话
              context.read<SessionBloc>().add(
                SessionInitializeRequested(wxLoginVO: authState.wxLoginVO),
              );
              context.read<UserBloc>().add(
                UserSetData(wxLoginVO: authState.wxLoginVO),
              );
            } else if (authState is AuthUnauthenticated) {
              // 未认证，清除会话
              context.read<SessionBloc>().add(const SessionClearRequested());
            }
          },
        ),
      ],
      child: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, sessionState) {
          // 如果现在已经建立了会话，只是需要切换身份或项目，则需要保留原状态，而不是直接通过laoding状态进行重新创建组件，导致页面重建状态丢失
          if (sessionState is SessionProjectEstablished ||
              sessionState is SessionStorekeeperEstablished) {
            bool isLoading = false;
            if (sessionState is SessionProjectEstablished) {
              isLoading = sessionState.isSwitching;
            } else if (sessionState is SessionStorekeeperEstablished) {
              isLoading = sessionState.isSwitching;
            }

            return Stack(
              children: [
                widget.child,
                if (isLoading)
                  const Material(
                    color: Colors.black38,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            );
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildSessionContent(context, sessionState),
          );
        },
      ),
    );
  }

  /// 根据会话状态构建内容
  Widget _buildSessionContent(BuildContext context, SessionState sessionState) {
    switch (sessionState.runtimeType) {
      case SessionInitial:
        return _buildLoadingView('正在初始化...');

      case SessionLoading:
        return _buildLoadingView('正在加载...');

      case SessionIdentitySelectionRequired:
        final state = sessionState as SessionIdentitySelectionRequired;
        return IdentitySelector(
          wxLoginVO: state.wxLoginVO,
          onProjectParticipantSelected: () {
            context.read<SessionBloc>().add(
              const SessionSelectProjectParticipant(),
            );
          },
          onStorekeeperSelected: () {
            context.read<SessionBloc>().add(const SessionSelectStorekeeper());
          },
        );

      case SessionProjectSelectionRequired:
        final state = sessionState as SessionProjectSelectionRequired;
        return ProjectSelector(
          wxLoginVO: state.wxLoginVO,
          availableProjects: state.availableProjects,
          onProjectSelected: (projectId) {
            context.read<SessionBloc>().add(
              SessionProjectSelected(projectId: projectId),
            );
          },
          onLogout: () {
            context.read<AuthBloc>().add(AuthLogoutRequested());
          },
        );

      case SessionStorekeeperEstablished:
      case SessionProjectEstablished:
        // 会话已建立，显示主界面
        return widget.child;

      case SessionNoProjectsAvailable:
        final state = sessionState as SessionNoProjectsAvailable;
        return _buildNoProjectsView(context, state);

      case SessionError:
        final state = sessionState as SessionError;
        return _buildErrorView(context, state.error);

      default:
        return _buildLoadingView('正在加载...');
    }
  }

  /// 构建加载视图
  Widget _buildLoadingView(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建无项目视图
  Widget _buildNoProjectsView(
    BuildContext context,
    SessionNoProjectsAvailable state,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目信息'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 顶部用户信息
            _buildUserInfoCard(state.wxLoginVO),
            const SizedBox(height: 40),

            // 无项目提示
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF95A5A6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(
                        Icons.business_center_outlined,
                        size: 60,
                        color: Color(0xFF95A5A6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '暂无可参与的项目',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '您当前没有被分配到任何项目',
                      style: TextStyle(fontSize: 16, color: Color(0xFF95A5A6)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '请联系项目管理员为您分配项目权限',
                      style: TextStyle(fontSize: 16, color: Color(0xFF95A5A6)),
                    ),
                    const SizedBox(height: 40),

                    // 联系管理员按钮
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton.icon(
                        onPressed: () => _showContactInfo(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.contact_support),
                        label: const Text(
                          '联系管理员',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 退出登录按钮
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7F8C8D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFF7F8C8D)),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          '退出登录',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息卡片
  Widget _buildUserInfoCard(dynamic wxLoginVO) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(
              context,
            ).primaryColor.withValues(alpha: 0.1),
            child: Text(
              wxLoginVO.name.isNotEmpty ? wxLoginVO.name[0] : 'U',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wxLoginVO.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '手机: ${wxLoginVO.phone}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView(BuildContext context, String error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('会话初始化失败: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<SessionBloc>().add(const SessionReloadRequested());
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示联系信息
  void _showContactInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('联系管理员'),
        content: const Text('请联系您的项目管理员或系统管理员，申请项目参与权限。\n\n如需技术支持，请联系系统客服。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
