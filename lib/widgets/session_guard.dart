/*
 * @Author: LeeZB
 * @Date: 2025-07-29 15:45:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-04 15:35:28
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../bloc/session/session_bloc.dart';
import '../bloc/session/session_state.dart';
import '../bloc/session/session_event.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../repositories/interfaces/records_repository.dart';
import '../services/qr_scan_flow/qr_scan_flow_service.dart';
import '../models/qr_scan/qr_scan_config.dart';
import '../services/tracing/improved_tracing_manager.dart';
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
      GetIt.instance<ImprovedTracingManager>().scopeActionWithTitle(
        '初始化会话',
        () async {
          context.read<SessionBloc>().add(
            SessionInitializeRequested(wxLoginVO: authState.wxLoginVO),
          );
          // 同时设置用户数据
          context.read<UserBloc>().add(
            UserSetData(wxLoginVO: authState.wxLoginVO),
          );
        },
      );
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
              GetIt.instance<ImprovedTracingManager>().scopeActionWithTitle(
                '登录成功处理',
                () async {
                  context.read<SessionBloc>().add(
                    SessionInitializeRequested(wxLoginVO: authState.wxLoginVO),
                  );
                  context.read<UserBloc>().add(
                    UserSetData(wxLoginVO: authState.wxLoginVO),
                  );
                  // 登录成功后清理所有记录缓存（确保账户隔离）
                  try {
                    GetIt.instance<RecordsRepository>().clearCache();
                  } catch (_) {}
                },
              );
            } else if (authState is AuthUnauthenticated) {
              // 未认证，清除会话
              GetIt.instance<ImprovedTracingManager>().scopeActionWithTitle(
                '退出登录处理',
                () async {
                  context.read<SessionBloc>().add(
                    const SessionClearRequested(),
                  );
                  // 退出登录时清理所有记录缓存
                  try {
                    GetIt.instance<RecordsRepository>().clearCache();
                  } catch (_) {}
                },
              );
            }
          },
        ),
      ],
      child: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, sessionState) {
          // 如果现在已经建立了会话，只是需要切换身份或项目，则需要保留原状态，而不是直接通过laoding状态进行重新创建组件，导致页面重建状态丢失
          if (sessionState is SessionProjectEstablished ||
              sessionState is SessionStorekeeperEstablished ||
              sessionState is SessionAdminEstablished) {
            bool isLoading = false;
            if (sessionState is SessionProjectEstablished) {
              isLoading = sessionState.isSwitching;
            } else if (sessionState is SessionStorekeeperEstablished) {
              isLoading = sessionState.isSwitching;
            } else if (sessionState is SessionAdminEstablished) {
              isLoading = sessionState.isSwitching;
            }

            return Stack(
              children: [
                widget.child,
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
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
    switch (sessionState) {
      case SessionInitial():
        return _buildLoadingView('正在初始化...');

      case SessionLoading():
        return _buildLoadingView('正在加载...');

      case SessionIdentitySelectionRequired():
        final state = sessionState;
        return IdentitySelector(
          wxLoginVO: state.wxLoginVO,
          onProjectParticipantSelected: () {
            GetIt.instance<ImprovedTracingManager>().scopeActionWithTitle(
              '选择项目参与者身份',
              () async {
                context.read<SessionBloc>().add(
                  const SessionSelectProjectParticipant(),
                );
              },
            );
          },
          onStorekeeperSelected: () {
            GetIt.instance<ImprovedTracingManager>().scopeActionWithTitle(
              '选择仓管员身份',
              () async {
                context.read<SessionBloc>().add(
                  const SessionSelectStorekeeper(),
                );
              },
            );
          },
        );

      case SessionProjectSelectionRequired():
        final state = sessionState;
        return ProjectSelector(
          wxLoginVO: state.wxLoginVO,
          availableProjects: state.availableProjects,
          onProjectSelected: (projectId) {
            GetIt.instance<ImprovedTracingManager>().scopeActionWithTitle(
              '选择项目',
              () async {
                context.read<SessionBloc>().add(
                  SessionProjectSelected(projectId: projectId),
                );
              },
            );
          },
          onLogout: () {
            GetIt.instance<ImprovedTracingManager>().scopeActionWithTitle(
              '退出登录',
              () async {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            );
          },
        );

      case SessionStorekeeperEstablished():
      case SessionProjectEstablished():
      case SessionAdminEstablished():
        // 会话已建立，显示主界面
        return widget.child;

      case SessionNoProjectsAvailable():
        final state = sessionState;
        return _buildNoProjectsView(context, state);

      case SessionError():
        final state = sessionState;
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

                    // 扫码识别按钮
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton.icon(
                        onPressed: () => _handleQrIdentify(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECC71),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text(
                          '扫码识别',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

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
                          GetIt.instance<ImprovedTracingManager>()
                              .scopeActionWithTitle('退出登录', () async {
                                context.read<AuthBloc>().add(
                                  AuthLogoutRequested(),
                                );
                              });
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

  /// 处理扫码识别
  Future<void> _handleQrIdentify(BuildContext context) async {
    await GetIt.instance<ImprovedTracingManager>().scopeActionWithTitle(
      '扫码识别',
      () async {
        try {
          final flow = RepositoryProvider.of<QrScanFlowService>(context);
          final request = QrScanFlowRequest(
            operation: QrScanOperation.initial,
            currentCodes: const [],
            batch: false, // 单码识别
            title: '扫码识别',
            context: const {
              'source': 'sessionGuard_noProjects',
              'entry': 'standalone',
              'operation': 'identify',
            },
          );

          final config = flow.buildConfig(request);
          final raw = await context.pushNamed<List<dynamic>>(
            'qr-scan',
            extra: config,
          );

          final result = flow.normalize(request, raw);
          if (!context.mounted) return;

          if (result.addedCodes.isNotEmpty) {
            // 跳转到材料详情页
            final materialCode = result.addedCodes.first;
            await context.pushNamed(
              'material-detail',
              extra: {
                'codes': [materialCode],
              },
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('扫码识别失败: $e')));
          }
        }
      },
    );
  }
}
