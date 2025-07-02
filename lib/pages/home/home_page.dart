/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:25:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-01 20:51:57
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_state.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/qr_scan/qr_scan_bloc.dart';
import '../../models/qr_scan/qr_scan_config.dart';
import '../../models/qr_scan/qr_scan_type.dart';
import '../../models/menu/menu_config.dart';
import '../../models/user/user_role.dart';
import '../../pages/qr_scan/qr_scan_page.dart';
import '../../services/qr_scan_service.dart';
import '../../config/service_locator.dart';
import '../../utils/toast_utils.dart';
import '../toast_demo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 只有当当前项目状态不是已加载状态时，才触发加载
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智慧水务'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          // 项目切换按钮
          BlocBuilder<ProjectBloc, ProjectState>(
            builder: (context, state) {
              if (state is ProjectContextLoaded) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.switch_account),
                  onSelected: (projectId) {
                    if (projectId != state.currentProject.id) {
                      context.read<ProjectBloc>().add(
                        ProjectSwitchProject(projectId: projectId),
                      );
                    }
                  },
                  itemBuilder: (context) {
                    return state.availableProjects.map((project) {
                      final isCurrentProject =
                          project.id == state.currentProject.id;
                      return PopupMenuItem<String>(
                        value: project.id,
                        child: Row(
                          children: [
                            Icon(
                              isCurrentProject
                                  ? Icons.check_circle
                                  : Icons.business,
                              color: isCurrentProject
                                  ? Colors.green
                                  : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    project.name,
                                    style: TextStyle(
                                      fontWeight: isCurrentProject
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isCurrentProject)
                                    Text(
                                      state.currentRole.role.displayName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is UserLoaded) {
                // 项目上下文加载完成后，触发用户上下文加载
                context.read<ProjectBloc>().add(
                  ProjectLoadUserContext(userId: state.user.id),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, projectState) {
            if (projectState is ProjectLoading ||
                projectState is ProjectSwitching) {
              return const Center(child: CircularProgressIndicator());
            }

            if (projectState is ProjectContextLoaded) {
              return _buildRoleBasedHome(context, projectState);
            }

            if (projectState is ProjectError) {
              return _buildErrorView(context, projectState.error);
            }

            if (projectState is ProjectEmpty) {
              return _buildEmptyProjectView(context, projectState.message);
            }

            // 检查用户状态
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                if (userState is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userState is UserLoaded) {
                  return _buildLoadingProjectView(context);
                }

                return _buildEmptyView(context);
              },
            );
          },
        ),
      ),
    );
  }

  /// 根据角色构建首页内容
  Widget _buildRoleBasedHome(BuildContext context, ProjectContextLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 项目和角色信息
          _buildProjectHeader(context, state),
          const SizedBox(height: 20),

          // 菜单功能区域
          _buildMenuSection(context, state),
        ],
      ),
    );
  }

  /// 构建项目头部信息
  Widget _buildProjectHeader(BuildContext context, ProjectContextLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.blue[100]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.currentProject.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(state.currentRole.role),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.currentRole.role.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.location_on, color: Colors.grey[600], size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  state.currentProject.location ?? '位置未设置',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建菜单功能区域
  Widget _buildMenuSection(BuildContext context, ProjectContextLoaded state) {
    final menuItems = state.menuItems;

    if (menuItems.isEmpty) {
      return _buildEmptyMenuView(context);
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '功能菜单',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ToastDemoPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications, size: 16),
                label: const Text('Toast 演示'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final menuItem = menuItems[index];
                return _buildMenuCard(context, menuItem, state);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建菜单卡片
  Widget _buildMenuCard(
    BuildContext context,
    MenuItem menuItem,
    ProjectContextLoaded state,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: menuItem.isEnabled
            ? () => _handleMenuTap(context, menuItem, state)
            : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getMenuColor(menuItem).withValues(alpha: 0.1),
                _getMenuColor(menuItem).withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getMenuIcon(menuItem),
                size: 48,
                color: menuItem.isEnabled
                    ? _getMenuColor(menuItem)
                    : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                menuItem.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: menuItem.isEnabled
                      ? _getMenuColor(menuItem).withValues(alpha: 0.8)
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (menuItem.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  menuItem.description!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (menuItem.badge != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    menuItem.badge!,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建空菜单视图
  Widget _buildEmptyMenuView(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '当前角色没有可用功能',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final userState = context.read<UserBloc>().state;
              if (userState is UserLoaded) {
                context.read<ProjectBloc>().add(
                  ProjectLoadUserContext(userId: userState.user.id),
                );
              }
            },
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  /// 构建空项目视图
  Widget _buildEmptyProjectView(BuildContext context, String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message ?? '您还没有被分配到任何项目',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建项目加载中视图
  Widget _buildLoadingProjectView(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在加载项目信息...'),
        ],
      ),
    );
  }

  /// 构建空视图
  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '请先登录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取角色对应的颜色
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.suppliers:
        return Colors.orange;
      case UserRole.construction:
        return Colors.blue;
      case UserRole.supervisor:
        return Colors.green;
      case UserRole.builder:
        return Colors.purple;
      case UserRole.check:
        return Colors.red;
      case UserRole.builderSub:
        return Colors.indigo;
      case UserRole.laborer:
        return Colors.brown;
      case UserRole.playgoer:
        return Colors.grey;
    }
  }

  /// 获取菜单项对应的颜色
  Color _getMenuColor(MenuItem menuItem) {
    // 根据菜单ID返回不同颜色
    switch (menuItem.id) {
      case 'qr_scan_install':
      case 'qr_scan_accept':
      case 'qr_operations':
        return Colors.green;
      case 'quality_inspection':
      case 'quality_control':
        return Colors.red;
      case 'construction_tasks':
      case 'material_management':
        return Colors.purple;
      case 'inspection_tasks':
      case 'progress_monitoring':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  /// 获取菜单项对应的图标
  IconData _getMenuIcon(MenuItem menuItem) {
    if (menuItem.icon != null) {
      // 这里可以实现一个从字符串到图标的映射
      return _stringToIcon(menuItem.icon!);
    }
    return Icons.apps;
  }

  /// 字符串到图标的映射
  IconData _stringToIcon(String iconName) {
    final iconMap = {
      'inventory': Icons.inventory,
      'assignment': Icons.assignment,
      'local_shipping': Icons.local_shipping,
      'dashboard': Icons.dashboard,
      'description': Icons.description,
      'timeline': Icons.timeline,
      'verified': Icons.verified,
      'search': Icons.search,
      'assessment': Icons.assessment,
      'check_circle': Icons.check_circle,
      'build': Icons.build,
      'inventory_2': Icons.inventory_2,
      'security': Icons.security,
      'qr_code': Icons.qr_code,
      'fact_check': Icons.fact_check,
      'lab_profile': Icons.science,
      'assignment_ind': Icons.assignment_ind,
      'groups': Icons.groups,
      'work': Icons.work,
      'support_agent': Icons.support_agent,
      'info': Icons.info,
      'feedback': Icons.feedback,
    };
    return iconMap[iconName] ?? Icons.apps;
  }

  /// 处理菜单点击事件
  void _handleMenuTap(
    BuildContext context,
    MenuItem menuItem,
    ProjectContextLoaded state,
  ) {
    if (menuItem.isPageMenu && menuItem.route != null) {
      // 导航到页面
      _navigateToPage(context, menuItem.route!);
    } else if (menuItem.isActionMenu && menuItem.action != null) {
      // 执行操作
      _executeAction(context, menuItem.action!, state);
    } else if (menuItem.hasChildren) {
      // 显示子菜单
      _showSubMenu(context, menuItem, state);
    }
  }

  /// 导航到页面
  void _navigateToPage(BuildContext context, String route) {
    // 这里可以实现路由导航逻辑
    context.showInfoToast('导航到: $route');
  }

  /// 执行操作
  void _executeAction(
    BuildContext context,
    String action,
    ProjectContextLoaded state,
  ) {
    switch (action) {
      case 'qr_scan_install':
        _navigateToScan(
          context,
          const QrScanConfig(scanType: QrScanType.verification),
        );
        break;
      case 'qr_scan_accept':
        _navigateToScan(
          context,
          const QrScanConfig(
            scanType: QrScanType.acceptance,
            acceptanceType: AcceptanceType.single,
          ),
        );
        break;
      case 'delegate_harvest':
      case 'delegate_accept':
        context.showInfoToast('$action: 功能开发中');
        break;
      default:
        context.showInfoToast('$action: 功能开发中');
    }
  }

  /// 显示子菜单
  void _showSubMenu(
    BuildContext context,
    MenuItem menuItem,
    ProjectContextLoaded state,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              menuItem.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...menuItem.children!.map(
              (child) => ListTile(
                leading: Icon(_getMenuIcon(child)),
                title: Text(child.title),
                subtitle: child.description != null
                    ? Text(child.description!)
                    : null,
                enabled: child.isEnabled,
                onTap: child.isEnabled
                    ? () {
                        Navigator.pop(context);
                        _handleMenuTap(context, child, state);
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 导航到扫码页面（保持原有的扫码功能）
  void _navigateToScan(BuildContext context, QrScanConfig config) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) =>
                  QrScanBloc(qrScanService: getIt<QrScanService>()),
              child: QrScanPage(config: config),
            ),
          ),
        )
        .then((result) {
          if (result != null && context.mounted) {
            _showScanResult(context, result, config);
          }
        });
  }

  void _showScanResult(
    BuildContext context,
    dynamic result,
    QrScanConfig config,
  ) {
    String message;
    if (result is List) {
      message = '${config.displayTitle}: 成功处理 ${result.length} 个二维码';
    } else {
      message = '${config.displayTitle}: 扫码完成';
    }

    context.showSuccessToast(message);
  }
}
