import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_event.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_state.dart';
import '../../bloc/session/session_bloc.dart';
import '../../bloc/session/session_state.dart';
import '../../bloc/session/session_event.dart';
import '../../models/qr_scan/qr_scan_config.dart';
import '../../models/qr_scan/qr_scan_type.dart';
import '../../models/menu/menu_config.dart';
import '../../models/project/project_info.dart';
import '../../utils/toast_utils.dart';
import '../../constants/menu_actions.dart';
import '../../bloc/records/records_bloc.dart';
import '../../bloc/records/records_event.dart';
import '../../models/records/record_type.dart';

// 假设这是您在项目中定义的扩展
extension ColorValues on Color {
  Color withValues({double? alpha}) {
    if (alpha != null) {
      return withValues(alpha: alpha.clamp(0.0, 1.0));
    }
    return this;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isProjectHeaderExpanded = true; // 项目头部是否展开
  bool _showProjectSwitchingOverlay = false; // 是否显示项目切换overlay

  @override
  void initState() {
    super.initState();
    // The listener might miss the initial state if it's set before the widget
    // is built. This ensures the data is fetched when the page is first loaded
    // with the correct session state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sessionState = context.read<SessionBloc>().state;
      if (sessionState is SessionStorekeeperEstablished) {
        context.read<InventoryBloc>().add(
          const InventoryTasksFetched(isRefresh: true),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('建设一码通'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: BlocListener<SessionBloc, SessionState>(
        // 使用 listenWhen 提高效率，只在关心的状态变化时才触发 listener
        listenWhen: (previous, current) {
          // 触发时机：
          // 1. 首次进入仓管员模式
          if (previous is! SessionStorekeeperEstablished &&
              current is SessionStorekeeperEstablished) {
            return true;
          }
          // 2. isSwitching 状态在 SessionProjectEstablished 内部发生变化
          if (previous is SessionProjectEstablished &&
              current is SessionProjectEstablished) {
            return previous.isSwitching != current.isSwitching;
          }
          // 3. 状态类型发生了根本变化
          return previous.runtimeType != current.runtimeType;
        },
        listener: (context, state) {
          // 当会话状态变为独立仓管员时，触发盘点任务列表的加载
          if (state is SessionStorekeeperEstablished) {
            context.read<InventoryBloc>().add(
              const InventoryTasksFetched(isRefresh: true),
            );
          }

          // 监听会话状态变化，显示/隐藏项目切换overlay
          if (state is SessionProjectEstablished) {
            setState(() {
              _showProjectSwitchingOverlay = state.isSwitching;
            });
          } else {
            // 在其他任何状态下，确保遮罩层是隐藏的
            if (_showProjectSwitchingOverlay) {
              setState(() {
                _showProjectSwitchingOverlay = false;
              });
            }
          }
        },
        child: Stack(
          children: [
            // 主要内容
            BlocBuilder<SessionBloc, SessionState>(
              builder: (context, sessionState) {
                // 根据会话状态显示不同界面
                if (sessionState is SessionStorekeeperEstablished) {
                  return _buildStorekeeperHome(context, sessionState.user);
                }

                if (sessionState is SessionProjectEstablished) {
                  return _buildRoleBasedHome(context, sessionState);
                }

                if (sessionState is SessionProjectSelectionRequired) {
                  return _buildProjectSelectionView(context, sessionState);
                }

                if (sessionState is SessionError) {
                  return _buildErrorView(context, sessionState.message);
                }

                if (sessionState is SessionEmpty) {
                  return _buildEmptyProjectView(context, '暂无项目数据');
                }

                // 默认显示加载界面
                return const Center(child: CircularProgressIndicator());
              },
            ),
            // 项目切换overlay
            if (_showProjectSwitchingOverlay) _buildProjectSwitchingOverlay(),
          ],
        ),
      ),
    );
  }

  /// 构建项目切换时的loading overlay
  Widget _buildProjectSwitchingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '正在切换项目...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 根据角色构建首页内容
  Widget _buildRoleBasedHome(
    BuildContext context,
    SessionProjectEstablished state,
  ) {
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
  Widget _buildProjectHeader(
    BuildContext context,
    SessionProjectEstablished state,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[300]!, Colors.blue[500]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 主要内容区域
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 项目名称和切换按钮
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.business_center,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '当前项目',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.project.projectName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // 切换按钮
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextButton.icon(
                        onPressed: () => _showProjectSelector(context, state),
                        icon: const Icon(
                          Icons.swap_horiz,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: const Text(
                          '切换',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    ),
                  ],
                ),
                // 展开内容
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      const SizedBox(height: 16),
                      // 统计数据行
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              Icons.inventory,
                              '耗材总数',
                              _getMaterialCount(state.project).toString(),
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatItem(
                              Icons.check_circle,
                              '验收通过',
                              _getAcceptedMaterialCount(
                                state.project,
                              ).toString(),
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatItem(
                              Icons.cancel,
                              '验收退回',
                              _getRejectedMaterialCount(
                                state.project,
                              ).toString(),
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 详细信息
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              Icons.engineering,
                              '工程状态',
                              state.project.projectCode,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              Icons.person,
                              '负责人',
                              state.project.orgName ?? '未设置',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 工程周期
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatProjectDuration(state.project),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  crossFadeState: _isProjectHeaderExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
          // 展开/折叠按钮 - 位于底部中间
          SizedBox(
            width: double.infinity,
            child: Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isProjectHeaderExpanded = !_isProjectHeaderExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isProjectHeaderExpanded ? '收起' : '展开详情',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _isProjectHeaderExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 构建详细信息行
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 获取耗材总数（模拟数据，实际应从项目数据中获取）
  int _getMaterialCount(ProjectInfo project) {
    // 这里应该从实际的项目数据或API获取耗材总数
    // 暂时返回模拟数据
    return 62;
  }

  /// 获取验收通过耗材数（模拟数据）
  int _getAcceptedMaterialCount(ProjectInfo project) {
    // 这里应该从实际的项目数据或API获取验收通过的耗材数
    // 暂时返回模拟数据
    return 59;
  }

  /// 获取验收退回耗材数（模拟数据）
  int _getRejectedMaterialCount(ProjectInfo project) {
    // 这里应该从实际的项目数据或API获取验收退回的耗材数
    // 暂时返回模拟数据
    return 3;
  }

  /// 格式化工程周期
  String _formatProjectDuration(ProjectInfo project) {
    // ProjectInfo 不包含日期信息，返回项目基本信息
    return '${project.projectName} - ${project.orgName}';
  }

  /// 显示项目选择器
  void _showProjectSelector(
    BuildContext context,
    SessionProjectEstablished state,
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
            const Text(
              '选择工程',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...state.availableProjects.map((project) {
              final isCurrentProject =
                  project.projectId == state.project.projectId;
              return ListTile(
                leading: Icon(
                  isCurrentProject ? Icons.check_circle : Icons.business,
                  color: isCurrentProject ? Colors.green : Colors.grey,
                ),
                title: Text(
                  project.projectName,
                  style: TextStyle(
                    fontWeight: isCurrentProject
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(project.orgName ?? '无组织信息'),
                trailing: isCurrentProject
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '当前',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : null,
                onTap: isCurrentProject
                    ? null
                    : () {
                        Navigator.pop(context);
                        context.read<SessionBloc>().add(
                          SessionSelectProject(projectId: project.projectId),
                        );
                      },
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建菜单功能区域
  Widget _buildMenuSection(
    BuildContext context,
    SessionProjectEstablished state,
  ) {
    // 对菜单项进行排序：启用的菜单项在前，禁用的菜单项在后
    final sortedMenuItems = [...state.menuItems]
      ..sort((a, b) {
        if (a.isEnabled && !b.isEnabled) return -1;
        if (!a.isEnabled && b.isEnabled) return 1;
        return 0;
      });

    if (sortedMenuItems.isEmpty) {
      return _buildEmptyMenuView(context);
    }

    // 使用 GridView.builder 和响应式 delegate 来防止在不同屏幕尺寸上发生溢出。
    // SliverGridDelegateWithMaxCrossAxisExtent 会自动调整列数。
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 8), // 在网格顶部添加一些内边距
        physics: const BouncingScrollPhysics(), // 使用更美观的滚动效果
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 100.0, // 每个项目的最大宽度
          mainAxisSpacing: 10.0, // 行间距
          crossAxisSpacing: 10.0, // 列间距
          childAspectRatio: 1.0, // 确保项目为正方形以适应圆形设计
        ),
        itemCount: sortedMenuItems.length,
        itemBuilder: (context, index) {
          final menuItem = sortedMenuItems[index];
          return _buildMenuCard(context, menuItem, state);
        },
      ),
    );
  }

  /// 构建菜单卡片
  Widget _buildMenuCard(
    BuildContext context,
    MenuItem menuItem,
    SessionProjectEstablished state,
  ) {
    return Opacity(
      opacity: menuItem.isEnabled ? 1.0 : 0.6,
      child: Card(
        elevation: 4.0, // 您喜欢的立体阴影效果
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias, // 保证圆形裁切和水波纹效果
        child: InkWell(
          onTap: menuItem.isEnabled
              ? () => _handleMenuTap(context, menuItem, state)
              : () => _showDisabledMenuAlert(context),
          child: Container(
            padding: const EdgeInsets.all(8.0), // 优化的内边距
            decoration: BoxDecoration(
              // 背景渐变
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
                  size: 30, // 统一图标大小
                  color: menuItem.isEnabled
                      ? _getMenuColor(menuItem)
                      : Colors.grey[700],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      menuItem.title,
                      style: TextStyle(
                        fontSize: 13, // 统一字体大小防止溢出
                        fontWeight: FontWeight.bold,
                        color: menuItem.isEnabled
                            ? Colors.black87
                            : Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建项目选择界面
  Widget _buildProjectSelectionView(
    BuildContext context,
    SessionProjectSelectionRequired state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息展示
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      state.wxLoginVO.name.isNotEmpty
                          ? state.wxLoginVO.name[0]
                          : '用',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.wxLoginVO.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.wxLoginVO.orgName ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 项目选择标题
          Text(
            '请选择要进入的项目：',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          // 项目列表
          Expanded(
            child: ListView.builder(
              itemCount: state.availableProjects.length,
              itemBuilder: (context, index) {
                final project = state.availableProjects[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.business, color: Colors.blue[600]),
                    ),
                    title: Text(
                      project.projectName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.orgName ?? '有关部门'),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '角色: ${project.projectRoleType}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // 提取项目ID（从项目编码中解析）
                      final projectId = project.projectId;

                      context.read<SessionBloc>().add(
                        SessionSelectProject(projectId: projectId),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
              // 重新加载会话
              context.read<SessionBloc>().add(const SessionReloadRequested());
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

  /// 获取菜单项对应的颜色
  Color _getMenuColor(MenuItem menuItem) {
    // 根据菜单ID返回不同颜色
    switch (menuItem.id) {
      // QR扫码相关
      // case 'qr_scan_inbound':
      case 'qr_scan_signout':
      case 'qr_scan_transfer':
      case 'qr_scan_inventory':
      case 'qr_scan_pipe_copy':
      case 'qr_operations':
      case 'qr_identify':
        return Colors.green;
      // 质检相关
      case 'quality_inspection':
      case 'quality_control':
        return Colors.red;
      // 施工相关
      case 'construction_tasks':
      case 'material_management':
      case 'builder':
      case 'spare_code':
      case 'cut_pipe':
      case 'scrap':
      case 'temporary_auth':
        return Colors.purple;
      // 监理和巡检相关
      case 'inspection_tasks':
      case 'progress_monitoring':
      case 'supervisor':
        return Colors.blue;
      // 库存管理相关
      case 'inventory':
      // case 'inbound':
      case 'signout':
      case 'return':
      case 'transfer':
        return Colors.orange;
      // 项目管理相关
      case 'project_create':
      case 'construction':
        return Colors.indigo;
      default:
        return Colors.teal;
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
      // 新增的菜单图标
      'add_business': Icons.add_business,
      'swap_horiz': Icons.swap_horiz,
      'keyboard_return': Icons.keyboard_return,
      'code': Icons.code,
      'input': Icons.input,
      'output': Icons.output,
      'content_cut': Icons.content_cut,
      'delete_forever': Icons.delete_forever,
      'admin_panel_settings': Icons.admin_panel_settings,
      'qr_code_scanner': Icons.qr_code_scanner,
    };
    return iconMap[iconName] ?? Icons.apps;
  }

  /// 处理菜单点击事件
  Future<void> _handleMenuTap(
    BuildContext context,
    MenuItem menuItem,
    SessionProjectEstablished state,
  ) async {
    if (!context.mounted) return;

    // --- 新增截管菜单处理逻辑 ---
    if (menuItem.id == 'cut_pipe') {
      context.pushNamed('cut');
      return;
    }
    // --- 结束新增逻辑 ---

    if (menuItem.isPageMenu && menuItem.route != null) {
      final result = await context.push(menuItem.route!);
      if (result == true) {
        final recordsBloc = context.read<RecordsBloc>();
        // 刷新待办
        recordsBloc.add(RefreshRecords(recordType: RecordType.todo));
        // 菜单 id 到 RecordType 的映射
        final type = _menuIdToRecordType(menuItem.id);
        if (type != null) {
          recordsBloc.add(RefreshRecords(recordType: type));
        }
      }
    } else if (menuItem.isActionMenu && menuItem.action != null) {
      // 执行操作
      _executeAction(context, menuItem.action!, state);
    } else if (menuItem.hasChildren) {
      // 显示子菜单
      _showSubMenu(context, menuItem, state);
    }
  }

  RecordType? _menuIdToRecordType(String id) {
    switch (id) {
      case 'accept':
        return RecordType.accept;
      case 'signout':
        return RecordType.signout;
      case 'install':
        return RecordType.install;
      case 'dispatch':
        return RecordType.dispatch;
      case 'return':
        return RecordType.returnWarehouse;
      case 'waste':
        return RecordType.waste;
      case 'inventory':
        return RecordType.inventory;
      default:
        return null;
    }
  }

  /// 执行操作
  void _executeAction(
    BuildContext context,
    String action,
    SessionProjectEstablished state,
  ) {
    // 验证action是否有效
    if (!MenuActions.isValidAction(action)) {
      context.showErrorToast('无效的操作: $action');
      return;
    }

    switch (action) {
      // case MenuActions.qrScanInbound:
      //   _showScanModeSelection(context, QrScanType.inbound);
      //   break;
      case MenuActions.qrScanSignout:
        _navigateToScan(
          context,
          const QrScanConfig(
            scanType: QrScanType.signout,
            scanMode: QrScanMode.batch,
          ),
        );
        break;
      case MenuActions.qrScanTransfer:
        // _showScanModeSelection(context, QrScanType.transfer);
        _navigateToScan(
          context,
          const QrScanConfig(
            scanType: QrScanType.transfer,
            scanMode: QrScanMode.batch,
          ),
        );
        break;

      case MenuActions.qrScanReturnMaterial:
        _navigateToScan(
          context,
          const QrScanConfig(
            scanType: QrScanType.returnMaterial,
            scanMode: QrScanMode.batch,
          ),
        );
        break;
      case MenuActions.qrScanInventory:
        _showScanModeSelection(context, QrScanType.inventory);
        break;
      case MenuActions.qrScanAcceptance:
        _showScanModeSelection(context, QrScanType.acceptance);
        break;
      case MenuActions.qrScanPipeCopy:
        _navigateToScan(
          context,
          const QrScanConfig(scanType: QrScanType.pipeCopy),
        );
        break;
      case MenuActions.qrIdentify:
        _navigateToScan(
          context,
          const QrScanConfig(scanType: QrScanType.identification),
        );
        break;
      case MenuActions.delegateHarvest:
      case MenuActions.delegateAccept:
        context.showInfoToast('${MenuActions.getDisplayName(action)}: 功能开发中');
        break;
      default:
        context.showInfoToast('${MenuActions.getDisplayName(action)}: 功能开发中');
    }
  }

  /// 显示子菜单
  void _showSubMenu(
    BuildContext context,
    MenuItem menuItem,
    SessionProjectEstablished state,
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

  /// 显示禁用菜单项的提示
  void _showDisabledMenuAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('授权已过期'),
        content: const Text('您在该项目的授权已过期，如有疑问请联系项目管理员'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示扫码模式选择对话框
  void _showScanModeSelection(BuildContext context, QrScanType scanType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('选择$scanType模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.blue),
              title: _getScanModeTitle(scanType, QrScanMode.single),
              subtitle: _getScanModeSubtitle(scanType, QrScanMode.single),
              onTap: () {
                Navigator.pop(context);
                _navigateToScan(
                  context,
                  QrScanConfig(scanType: scanType, scanMode: QrScanMode.single),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Colors.green),
              title: _getScanModeTitle(scanType, QrScanMode.batch),
              subtitle: _getScanModeSubtitle(scanType, QrScanMode.batch),
              onTap: () {
                Navigator.pop(context);
                _navigateToScan(
                  context,
                  QrScanConfig(scanType: scanType, scanMode: QrScanMode.batch),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 获取扫码模式标题
  Widget _getScanModeTitle(QrScanType scanType, QrScanMode scanMode) {
    String title;
    switch (scanType) {
      // case QrScanType.inbound:
      //   title = scanMode == QrScanMode.single ? '单码入库' : '批量入库';
      //   break;
      case QrScanType.signout:
        title = scanMode == QrScanMode.single ? '单个物料出库' : '批量物料出库';
        break;
      case QrScanType.transfer:
        title = scanMode == QrScanMode.single ? '单个物料调拨' : '批量物料调拨';
        break;
      case QrScanType.inventory:
        title = scanMode == QrScanMode.single ? '单个物料盘点' : '批量物料盘点';
        break;
      case QrScanType.acceptance:
        title = scanMode == QrScanMode.single ? '单个物料验收' : '批量物料验收';
        break;
      default:
        title = scanMode.toString();
    }
    return Text(title, style: const TextStyle(fontWeight: FontWeight.w500));
  }

  /// 获取扫码模式副标题
  Widget _getScanModeSubtitle(QrScanType scanType, QrScanMode scanMode) {
    String subtitle;
    switch (scanType) {
      // case QrScanType.inbound:
      //   subtitle = scanMode == QrScanMode.single
      //       ? '扫描单个二维码进行入库操作'
      //       : '连续扫描多个物料码，手动结束后统一处理';
      //   break;
      case QrScanType.signout:
        subtitle = scanMode == QrScanMode.single
            ? '扫描单个物料进行出库操作'
            : '连续扫描多个物料进行批量出库';
        break;
      case QrScanType.transfer:
        subtitle = scanMode == QrScanMode.single
            ? '扫描单个物料进行调拨操作'
            : '连续扫描多个物料进行批量调拨';
        break;
      case QrScanType.inventory:
        subtitle = scanMode == QrScanMode.single
            ? '扫描单个物料进行盘点检查'
            : '连续扫描多个物料进行批量盘点';
        break;
      case QrScanType.acceptance:
        subtitle = scanMode == QrScanMode.single
            ? '扫描单个物料进行验收操作'
            : '连续扫描多个物料进行批量验收';
        break;
      default:
        subtitle = '选择扫码模式';
    }
    return Text(
      subtitle,
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
    );
  }

  /// 导航到扫码页面（使用GoRouter）
  void _navigateToScan(BuildContext context, QrScanConfig config) async {
    final result = await context.pushNamed('qr-scan', extra: config);
    if (result != null && context.mounted) {
      _showScanResult(context, result, config);
    }
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

  /// 构建仓管员主页
  Widget _buildStorekeeperHome(BuildContext context, dynamic wxLoginVO) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 欢迎信息
          _buildStorekeeperWelcomeCard(context, wxLoginVO),
          const SizedBox(height: 24),

          // 快捷操作
          _buildStorekeeperQuickActions(context),
          const SizedBox(height: 24),

          // 功能模块（预留）
          _buildStorekeeperFunctionModules(context),
          const SizedBox(height: 24),

          // 统计概览（预留）
          _buildStorekeeperStatisticsOverview(context),
        ],
      ),
    );
  }

  Widget _buildStorekeeperWelcomeCard(BuildContext context, dynamic wxLoginVO) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '欢迎回来，${wxLoginVO.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '独立仓管员模式',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '您正在使用独立仓管员模式，专注于库存管理和物料操作。',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildStorekeeperQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快捷操作',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStorekeeperActionCard(
                context: context,
                title: '入库',
                icon: Icons.add_box,
                color: const Color(0xFF27AE60),
                onTap: () => _showComingSoon(context, '入库功能'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStorekeeperActionCard(
                context: context,
                title: '出库',
                icon: Icons.remove_circle,
                color: const Color(0xFFE74C3C),
                onTap: () => _showComingSoon(context, '出库功能'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStorekeeperActionCard(
                context: context,
                title: '调拨',
                icon: Icons.swap_horiz,
                color: const Color(0xFF3498DB),
                onTap: () => _showComingSoon(context, '调拨功能'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStorekeeperActionCard(
                context: context,
                title: '盘点',
                icon: Icons.inventory,
                color: const Color(0xFFf39C12),
                onTap: () => context.pushNamed('inventory-list'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStorekeeperActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    if (title != '盘点') {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  state.totalTasks > 0
                      ? Badge(
                          offset: const Offset(8, -8),
                          backgroundColor: Colors.red,
                          label: Text(
                            state.totalTasks.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          child: Icon(icon, size: 28, color: color),
                        )
                      : Icon(icon, size: 28, color: color),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildStorekeeperFunctionModules(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '功能模块',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
          child: const Column(
            children: [
              Icon(Icons.build_circle, size: 48, color: Color(0xFF95A5A6)),
              SizedBox(height: 16),
              Text(
                '功能开发中',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '库存查询、报表统计等功能正在开发中',
                style: TextStyle(fontSize: 14, color: Color(0xFF95A5A6)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStorekeeperStatisticsOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '数据概览',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
          child: const Column(
            children: [
              Icon(Icons.analytics, size: 48, color: Color(0xFF95A5A6)),
              SizedBox(height: 16),
              Text(
                '统计功能开发中',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '库存统计、出入库报表等功能正在开发中',
                style: TextStyle(fontSize: 14, color: Color(0xFF95A5A6)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 正在开发中，敬请期待'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
