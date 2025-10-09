/*
 * @Author: LeeZB
 * @Date: 2025-07-29 19:58:49
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-01 18:50:25
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_state.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/config/tracing_route_mappings.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/services/tracing/tracing_context.dart';
import 'package:pipe_code_flutter/services/tracing/improved_tracing_manager.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/models/records/record_type.dart';
import 'package:pipe_code_flutter/models/user/user_role.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/session/session_bloc.dart';
import '../bloc/session/session_state.dart';
import '../bloc/inventory/inventory_bloc.dart';
import '../bloc/inventory/inventory_state.dart';
import '../bloc/inventory/inventory_event.dart';
import '../bloc/records/records_event.dart';
import '../pages/home/home_page.dart';
import '../pages/records/records_list_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/admin/admin_home_page.dart';
import '../widgets/session_guard.dart';
import '../bloc/records/records_bloc.dart';
import '../repositories/interfaces/records_repository.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  static const platform = MethodChannel('com.zzwater.pipe_code_trace');

  int _currentIndex = 0;
  final ImprovedTracingManager _tracingManager =
      getIt<ImprovedTracingManager>();
  List<String> _routeNames = [];
  bool _isUiInitialized = false;
  bool _isBadgeDataReady = false; // 🎯 追踪 badge 数据是否准备好
  int? _lastProjectId; // 🎯 追踪当前项目ID，用于检测项目切换
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Widget> _pages = [];
  // 页面集合（根据身份动态配置）

  Future<void> _moveToBack() async {
    try {
      await platform.invokeMethod('moveTaskToBack');
    } on PlatformException catch (e) {
      Logger.error("Failed to move task to back: '${e.message}'.");
    }
  }

  @override
  void initState() {
    super.initState();
    // _initializePagesAndNavigation();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  //（移除旧初始化方法，统一使用 _setupTabsForRole）

  @override
  void dispose() {
    _animationController.dispose();
    _tracingManager.popPageContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _moveToBack();
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // 用户未认证，跳转到登录页面
            context.goNamed('login');
          }
        },
        child: SessionGuard(child: _buildMainInterface()),
      ),
    );
  }

  /// 构建主界面
  Widget _buildMainInterface() {
    return BlocConsumer<SessionBloc, SessionState>(
      listener: (context, state) {
        // 检测是否是首次初始化或项目切换
        bool isFirstInit = !_isUiInitialized;
        bool isProjectSwitch = false;

        if (state is SessionProjectEstablished) {
          final currentProjectId = state.project.projectId;
          if (_lastProjectId != null && _lastProjectId != currentProjectId) {
            isProjectSwitch = true; // 项目发生了切换
          }
          _lastProjectId = currentProjectId;
        } else if (state is SessionStorekeeperEstablished) {
          // 仓管员没有项目ID，切换身份时也需要重新加载
          if (_lastProjectId != null) {
            isProjectSwitch = true;
          }
          _lastProjectId = null;
        }

        // 首次初始化或项目切换时，都需要预加载 badge 数据
        if ((state is SessionAdminEstablished ||
                state is SessionProjectEstablished ||
                state is SessionStorekeeperEstablished) &&
            (isFirstInit || isProjectSwitch)) {
          // 根据用户角色初始化标签页和导航
          bool isAdmin = state is SessionAdminEstablished;
          _setupTabsForRole(isAdmin);

          // 🎯 关键修复：项目切换时清空缓存并重置 badge 数据准备状态
          if (isProjectSwitch) {
            setState(() {
              _isBadgeDataReady = false;
            });
            // 清空所有记录缓存，避免旧项目的缓存干扰新项目的数据加载
            try {
              getIt<RecordsRepository>().clearCache();
            } catch (_) {}
          }

          // 预加载 badge 计数所需的数据
          _preloadBadgeCounts(state);

          if (isFirstInit) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _updateTabContext(0, isInitial: true);
              }
            });
            setState(() {
              _isUiInitialized = true;
            });
          }
        }
      },
      builder: (context, sessionState) {
        // 首次挂载后可能错过已建立状态的变更（例如仓管员场景不会有后续状态刷新），
        // 因此在 builder 中检测一次并进行初始化，确保 UI 能正确展示。
        if (!_isUiInitialized &&
            (sessionState is SessionAdminEstablished ||
                sessionState is SessionProjectEstablished ||
                sessionState is SessionStorekeeperEstablished)) {
          final bool isAdmin = sessionState is SessionAdminEstablished;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _isUiInitialized) return;
            _setupTabsForRole(isAdmin);

            // 预加载 badge 计数所需的数据
            _preloadBadgeCounts(sessionState);

            _updateTabContext(0, isInitial: true);
            setState(() {
              _isUiInitialized = true;
            });
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!_isUiInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
          bottomNavigationBar: BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, inventoryState) {
              return BlocBuilder<RecordsBloc, RecordsState>(
                builder: (context, recordsState) {
                  final isAdmin = sessionState is SessionAdminEstablished;
                  final todoCount = _computeTodoBadgeCount(
                    recordsState,
                    sessionState,
                    inventoryState,
                  );
                  final items = _buildNavItemsWithBadge(todoCount, isAdmin);
                  return BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      if (index != _currentIndex) {
                        _animationController.reset();
                        setState(() {
                          _currentIndex = index;
                        });
                        _animationController.forward();
                        _updateTabContext(index);
                      }
                    },
                    items: items,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// 根据会话状态更新页面和追踪配置
  void _setupTabsForRole(bool isAdmin) {
    if (isAdmin) {
      _pages = [const AdminHomePage(), const ProfilePage()];
      _routeNames = [adminHomeTabRouteName, profileTabRouteName];
    } else {
      // 普通用户：首页、记录、我的
      _pages = [const HomePage(), const RecordsListPage(), const ProfilePage()];
      _routeNames = [
        homeTabRouteName,
        recordsTabRouteName,
        profileTabRouteName,
      ];
    }
  }

  /// Tracing 方法：更新当前 Tab 的上下文
  void _updateTabContext(int index, {bool isInitial = false}) {
    // 对于非首次加载（即用户手动切换 Tab），先弹出上一个 Tab 的上下文。
    if (!isInitial) {
      _tracingManager.popPageContext();
    }

    // 确保索引在安全范围内
    if (index < _routeNames.length) {
      final routeName = _routeNames[index];
      final tracingInfo = tracingRouteMappings[routeName];

      if (tracingInfo != null) {
        final context = TracingContext(
          source: tracingInfo.source,
          action: isInitial
              ? '进入${tracingInfo.description}'
              : index == 0
              ? '首页'
              : index == 1
              ? '记录'
              : '我的',
          description: tracingInfo.description,
        );
        _tracingManager.pushPageContext(context);
      }
    }
  }

  ///（已移除）旧的基于会话状态的页面更新逻辑由 _setupTabsForRole 统一处理

  /// 预加载 badge 计数所需的数据（只获取 meta，不加载完整列表）
  void _preloadBadgeCounts(SessionState sessionState) {
    final ids = _resolveIds(sessionState);
    final int? uid = ids.$1;
    final int? pid = ids.$2;

    // 仓管员需要预加载仓库待办
    if (sessionState is SessionStorekeeperEstablished) {
      context.read<RecordsBloc>().add(
        LoadRecords(
          recordType: RecordType.warehouseTodo,
          userId: uid,
          projectId: pid,
          pageNum: 1,
          pageSize: 1, // 只需要获取 total，所以只请求 1 条数据
          tracingContext: TracingContext(
            source: 'main_page',
            action: 'preload_badge_count',
            description: '预加载仓库待办数量',
          ),
        ),
      );
    }

    // 施工方需要预加载 todo、siteTodo
    if (sessionState is SessionProjectEstablished) {
      final role = sessionState.currentUserRoleInfo.projectRoleType;

      // 所有项目参与方都需要 todo
      context.read<RecordsBloc>().add(
        LoadRecords(
          recordType: RecordType.todo,
          userId: uid,
          projectId: pid,
          pageNum: 1,
          pageSize: 1,
          tracingContext: TracingContext(
            source: 'main_page',
            action: 'preload_badge_count',
            description: '预加载待办数量',
          ),
        ),
      );

      // builder、builderSub、laborer 需要 siteTodo
      if (role == UserRole.builder ||
          role == UserRole.builderSub ||
          role == UserRole.laborer) {
        context.read<RecordsBloc>().add(
          LoadRecords(
            recordType: RecordType.siteTodo,
            userId: uid,
            projectId: pid,
            pageNum: 1,
            pageSize: 1,
            tracingContext: TracingContext(
              source: 'main_page',
              action: 'preload_badge_count',
              description: '预加载现场待办数量',
            ),
          ),
        );
      }

      // builder、builderSub 需要预加载盘点任务
      if (role == UserRole.builder || role == UserRole.builderSub) {
        context.read<InventoryBloc>().add(
          const InventoryTasksFetched(isRefresh: true),
        );
      }
    }
  }

  // ==== Helpers for badge/count ====
  int _computeTodoBadgeCount(
    RecordsState recordsState,
    SessionState sessionState,
    InventoryState inventoryState,
  ) {
    final ids = _resolveIds(sessionState);
    final int? uid = ids.$1;
    final int? pid = ids.$2;

    // 判断用户角色类型
    final bool isStorekeeper = sessionState is SessionStorekeeperEstablished;
    final bool isBuilder =
        sessionState is SessionProjectEstablished &&
        (sessionState.currentUserRoleInfo.projectRoleType == UserRole.builder ||
            sessionState.currentUserRoleInfo.projectRoleType ==
                UserRole.builderSub);
    final bool isLaborer =
        sessionState is SessionProjectEstablished &&
        sessionState.currentUserRoleInfo.projectRoleType == UserRole.laborer;

    int totalCount = 0;
    bool allDataReady = true; // 追踪是否所有需要的数据都已加载

    try {
      final repo = getIt<RecordsRepository>();

      // 1. 获取普通待办数量（所有角色都有）
      final todoMeta = repo.getCachedMeta(
        RecordType.todo,
        userId: uid,
        projectId: pid,
      );
      if (todoMeta == null) {
        allDataReady = false; // 数据还未加载
      } else {
        totalCount += todoMeta.total;
      }

      // 2. 仓管员：加上仓库待办
      if (isStorekeeper) {
        final whMeta = repo.getCachedMeta(
          RecordType.warehouseTodo,
          userId: uid,
          projectId: pid,
        );
        if (whMeta == null) {
          allDataReady = false;
        } else {
          totalCount += whMeta.total;
        }
      }

      // 3. 施工方（builder、builderSub、laborer）：加上现场待办
      if (isBuilder || isLaborer) {
        final siteTodoMeta = repo.getCachedMeta(
          RecordType.siteTodo,
          userId: uid,
          projectId: pid,
        );
        if (siteTodoMeta == null) {
          allDataReady = false;
        } else {
          totalCount += siteTodoMeta.total;
        }
      }

      // 4. builder、builderSub：加上盘点任务
      if (isBuilder) {
        // 检查 InventoryBloc 是否已加载完成
        if (inventoryState.listStatus == DataStatus.initial ||
            inventoryState.listStatus == DataStatus.loading) {
          allDataReady = false;
        } else {
          totalCount += inventoryState.totalTasks;
        }
      }
    } catch (_) {
      // ignore cache failures
      allDataReady = false;
    }

    // 🎯 关键：只有当所有数据都准备好时才显示 badge
    // 否则返回 0，这样就不会显示 badge（因为有 if (todoCount > 0) 的判断）
    if (!allDataReady) {
      // 如果还有数据未加载完成，延迟更新状态标志
      if (_isBadgeDataReady) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isBadgeDataReady = false;
            });
          }
        });
      }
      return 0; // 不显示 badge
    }

    // 所有数据都准备好了，更新状态标志
    if (!_isBadgeDataReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isBadgeDataReady = true;
          });
        }
      });
    }

    return totalCount;
  }

  List<BottomNavigationBarItem> _buildNavItemsWithBadge(
    int todoCount,
    bool isAdmin,
  ) {
    if (isAdmin) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: '管理',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '我的',
        ),
      ];
    }

    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: '首页',
      ),
      BottomNavigationBarItem(
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.list_alt_outlined),
            if (todoCount > 0)
              Positioned(right: -6, top: -3, child: _Badge(count: todoCount)),
          ],
        ),
        activeIcon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.list_alt),
            if (todoCount > 0)
              Positioned(right: -6, top: -3, child: _Badge(count: todoCount)),
          ],
        ),
        label: '记录',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: '我的',
      ),
    ];
  }

  // Copy of resolve from records_list_page for consistency
  (int?, int?) _resolveIds(SessionState sessionState) {
    int? uid;
    int? pid;
    if (sessionState is SessionProjectEstablished) {
      uid = int.tryParse(sessionState.user.id);
      pid = sessionState.project.projectId;
    } else if (sessionState is SessionStorekeeperEstablished) {
      uid = int.tryParse(sessionState.user.id);
    }
    return (uid, pid);
  }
}

// Simple badge widget used in BottomNavigationBar icons
class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final String text = count > 99 ? '99+' : count.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 16),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
