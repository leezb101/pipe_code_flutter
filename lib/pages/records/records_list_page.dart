import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/constants/app_theme.dart';
import 'package:pipe_code_flutter/models/records/record_item.dart';
import 'package:pipe_code_flutter/models/user/user_role.dart';
import 'package:pipe_code_flutter/models/user/wx_login_vo.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import '../../bloc/session/session_bloc.dart';
import '../../bloc/session/session_state.dart';
import '../../bloc/session/session_event.dart';
import '../../bloc/records/records_bloc.dart';
import '../../bloc/records/records_event.dart';
import '../../bloc/records/records_state.dart';
import '../../models/records/record_type.dart';
import '../../widgets/scrollable_tab_bar.dart';
import '../../widgets/record_list_item.dart';
import '../../widgets/inventory_record_list_item.dart';
import '../../widgets/common_state_widgets.dart' as common;
import '../../services/tracing/tracing_context.dart';
import 'package:pipe_code_flutter/services/notification/notification_center.dart';
import 'package:pipe_code_flutter/models/notification/notification_message_vo.dart';
import '../../bloc/inventory/inventory_bloc.dart';
import '../../bloc/inventory/inventory_state.dart';
import '../../bloc/inventory/inventory_event.dart';
import '../../repositories/interfaces/records_repository.dart';

class RecordsListPage extends StatefulWidget {
  final RecordType? initialTab;

  const RecordsListPage({super.key, this.initialTab});

  @override
  State<RecordsListPage> createState() => _RecordsListPageState();
}

class _RecordsListPageState extends State<RecordsListPage>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;
  late List<RecordType> _allTabs;
  late RecordType _initialTab;
  SessionState? _lastSessionState;
  StreamSubscription<List<NotificationMessageVO>>? _todoStreamSub;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    // 使用当前 SessionState 初始化 Tabs 和 lastSessionState
    final sessionState = context.read<SessionBloc>().state;
    _setupTabsBySession(sessionState);
    _lastSessionState = sessionState;

    // 订阅全局待办通知：聚合后的批量事件到来时刷新当前tab（若是待办类）
    _todoStreamSub = NotificationCenter.instance.todoStream.listen((batch) {
      if (!mounted || batch.isEmpty) return;
      final bloc = context.read<RecordsBloc>();
      final currentTab = bloc.currentTab;
      if (currentTab == RecordType.todo ||
          currentTab == RecordType.warehouseTodo) {
        final ids = _resolveIds(context.read<SessionBloc>().state);
        bloc.add(
          RefreshRecords(
            recordType: currentTab,
            userId: ids.$1,
            projectId: ids.$2,
          ),
        );
      }
    });

    // 首次进入时自动加载默认tab（如待办）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 如果初始tab是盘点任务，加载InventoryBloc
        if (_initialTab == RecordType.builderInventory) {
          context.read<InventoryBloc>().add(
            const InventoryTasksFetched(isRefresh: true),
          );
        } else {
          // 否则加载RecordsBloc
          final ids = _resolveIds(context.read<SessionBloc>().state);
          context.read<RecordsBloc>().add(
            LoadRecords(
              recordType: _initialTab,
              userId: ids.$1,
              projectId: ids.$2,
              tracingContext: TracingContext(
                source: 'records_list_page',
                action: 'initial_load',
                description: '初始加载${_initialTab.displayName}',
              ),
            ),
          );
        }
      }
    });
  }

  void _setupTabsBySession(SessionState sessionState) {
    // 根据会话状态确定tabs
    bool isStoreKeeper = false;

    if (sessionState is SessionStorekeeperEstablished ||
        sessionState is SessionProjectEstablished) {
      isStoreKeeper = (sessionState.user as WxLoginVO).storekeeper;
    }

    List<RecordType> tabs = [];
    if (isStoreKeeper && sessionState is SessionStorekeeperEstablished) {
      // 仓管员身份，展示专用的4个tab："仓管待办"、"待办"、"入库记录"、"出库记录"
      tabs = [
        RecordType.warehouseTodo,
        RecordType.todo,
        RecordType.signinWarehouse,
        RecordType.signoutWarehouse,
      ];
    } else {
      // 普通项目参与方，只展示"待办"
      tabs = [RecordType.todo];

      // 如果是项目参与方中的施工方，则还要增加"现场待办"tab和"盘点任务"tab
      if (sessionState is SessionProjectEstablished &&
          (sessionState.currentUserRoleInfo.projectRoleType ==
                  UserRole.builder ||
              sessionState.currentUserRoleInfo.projectRoleType ==
                  UserRole.builderSub ||
              sessionState.currentUserRoleInfo.projectRoleType ==
                  UserRole.laborer)) {
        tabs.add(RecordType.siteTodo);
        // 只有 builder 和 builderSub 才显示盘点任务
        if (sessionState.currentUserRoleInfo.projectRoleType ==
                UserRole.builder ||
            sessionState.currentUserRoleInfo.projectRoleType ==
                UserRole.builderSub) {
          tabs.add(RecordType.builderInventory);
        }
      }
      // 追加其他所有tab，但排除仓管专用的tabs和builderInventory
      tabs.addAll(
        RecordType.values.where(
          (e) =>
              e != RecordType.todo &&
              e != RecordType.siteTodo &&
              e != RecordType.warehouseTodo &&
              e != RecordType.signinWarehouse &&
              e != RecordType.signoutWarehouse &&
              e != RecordType.inventory && // 盘点记录也只有仓管员可见
              e != RecordType.builderInventory, // 盘点任务已单独添加
        ),
      );
    }
    _allTabs = tabs;

    // 根据最终的会话身份设置默认选中的tab
    if (sessionState is SessionStorekeeperEstablished && isStoreKeeper) {
      // 独立库管员身份，默认"仓管待办"优先
      _initialTab = RecordType.warehouseTodo;
    } else {
      // 其他身份，默认"待办"优先
      _initialTab = RecordType.todo;
    }
  }

  @override
  void dispose() {
    _todoStreamSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final recordsBloc = context.read<RecordsBloc>();
      final currentTab = recordsBloc.currentTab;

      // 如果是盘点任务tab，加载更多InventoryBloc数据
      if (currentTab == RecordType.builderInventory) {
        final inventoryBloc = context.read<InventoryBloc>();
        final inventoryState = inventoryBloc.state;
        if (!inventoryState.hasReachedMax &&
            inventoryState.listStatus != DataStatus.loading) {
          inventoryBloc.add(const InventoryTasksFetched());
        }
        return;
      }

      // 其他tab加载更多RecordsBloc数据
      if (recordsBloc.state is RecordsLoaded) {
        final state = recordsBloc.state as RecordsLoaded;
        if (state.hasMoreData && !state.isLoadingMore) {
          final ids = _resolveIds(context.read<SessionBloc>().state);
          recordsBloc.add(
            LoadMoreRecords(
              recordType: state.currentTab,
              userId: ids.$1,
              projectId: ids.$2,
            ),
          );
        }
      }
    }
  }

  void _onTabSelected(RecordType recordType) {
    final ids = _resolveIds(context.read<SessionBloc>().state);

    // 如果切换到盘点任务tab，触发InventoryBloc加载数据
    if (recordType == RecordType.builderInventory) {
      context.read<InventoryBloc>().add(const InventoryTasksFetched());
    }

    // 直接使用简化的追踪上下文，避免嵌套的追踪操作
    context.read<RecordsBloc>().add(
      SwitchTab(
        recordType,
        userId: ids.$1,
        projectId: ids.$2,
        tracingContext: TracingContext(
          source: 'records_list_page',
          action: 'switch_tab',
          description: '切换到${recordType.displayName}',
        ),
      ),
    );

    Logger.debug(
      'Tab selected: ${recordType.displayName}',
      tag: 'RecordsListPage',
    );
  }

  void _onRefresh() {
    final bloc = context.read<RecordsBloc>();
    final currentTab = bloc.currentTab;

    // 如果是盘点任务tab，刷新InventoryBloc
    if (currentTab == RecordType.builderInventory) {
      context.read<InventoryBloc>().add(
        const InventoryTasksFetched(isRefresh: true),
      );
      return;
    }

    // 其他tab刷新RecordsBloc
    final ids = _resolveIds(context.read<SessionBloc>().state);
    bloc.add(
      RefreshRecords(recordType: currentTab, userId: ids.$1, projectId: ids.$2),
    );
  }

  void _onRecordTap(BuildContext context, RecordItem record) {
    final bloc = context.read<RecordsBloc>();
    final currentTab = bloc.currentTab;

    // 根据记录类型导航到不同的详情页
    switch (currentTab) {
      case RecordType.accept:
        context.goNamed(
          'acceptance-detail',
          queryParameters: {'id': record.id.toString()},
        );
        break;
      case RecordType.returnWarehouse:
        context.goNamed(
          'return-detail',
          queryParameters: {'id': record.id.toString()},
        );
        break;
      case RecordType.dispatch:
        context.goNamed(
          'dispatch-detail',
          queryParameters: {'id': record.id.toString()},
        );
        break;
      case RecordType.install:
        context.goNamed(
          'install-detail',
          queryParameters: {'id': record.id.toString()},
        );
      case RecordType.waste:
        context.goNamed(
          'scrap-detail',
          queryParameters: {'id': record.id.toString()},
        );
        break;
      case RecordType.inventory:
        context.goNamed(
          'inventory-detail',
          queryParameters: {'id': record.id.toString()},
        );
        break;
      case RecordType.signout:
      case RecordType.signoutWarehouse:
        // 出库记录和仓管出库记录都导航到同一个详情页
        context.goNamed(
          'signout-detail',
          queryParameters: {'id': record.id.toString()},
        );
        break;
      case RecordType.signin:
      case RecordType.signinWarehouse:
        // 仓管入库记录导航到入库详情页（假设有这个页面）
        context.goNamed(
          'signin-detail',
          queryParameters: {'id': record.id.toString()},
        );
        break;
      case RecordType.todo:
        final rec = record as TodoRecordItem;
        _handleSelectProject(context, rec.todo.projectId, rec);
        break;
      case RecordType.warehouseTodo:
      case RecordType.siteTodo:
        final rec = record as TodoRecordItem;
        handleGoTodoDetail(context, rec);
        break;
      case RecordType.builderInventory:
        // 盘点任务导航到盘点详情页
        context.goNamed('inventory-apply', extra: record.id);
        break;
    }
  }

  void handleGoTodoDetail(BuildContext context, TodoRecordItem rec) {
    // 根据待办的具体类型（type.name）或名称（todoName）导航
    if (rec.todo.type.value == 1) {
      context.goNamed(
        'acceptance-confirmation',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    } else if (rec.todo.type.value == 2) {
      context.goNamed(
        'acceptance-after-signin',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    } else if (rec.todo.type.value == 3) {
      context.goNamed(
        'signout-audit',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    } else if (rec.todo.type.value == 4) {
      context.goNamed(
        'install',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    } else if (rec.todo.type.value == 5) {
      context.goNamed(
        'dispatch-confirmation',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    } else if (rec.todo.type.value == 6) {
      context.goNamed(
        'dispatch-after-signin',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 保持页面状态所必需
    return BlocConsumer<SessionBloc, SessionState>(
      // `listenWhen` 精确控制 `listener` 的触发时机，避免不必要的回调
      listenWhen: (previous, current) {
        // 条件一：当导航事件出现时触发 (从无到有)
        if (current is SessionProjectEstablished) {
          final prevRecord = (previous is SessionProjectEstablished)
              ? previous.pendingTodoRecord
              : null;
          if (prevRecord == null && current.pendingTodoRecord != null) {
            return true;
          }
        }
        // 条件二：当会话的身份类型发生本质变化时触发 (用于刷新Tabs)
        if (previous.runtimeType != current.runtimeType) {
          return true;
        }
        // 条件三：同类型会话下，项目发生切换时触发（例如从项目A切到项目B）
        if (previous is SessionProjectEstablished &&
            current is SessionProjectEstablished) {
          if (previous.project.projectId != current.project.projectId) {
            return true;
          }
        }
        return false;
      },
      // `listener` 专门用于处理副作用，如导航、弹窗、刷新其他Bloc等
      listener: (context, sessionState) {
        // 处理一次性的导航事件
        if (sessionState is SessionProjectEstablished &&
            sessionState.pendingTodoRecord != null) {
          // 使用 addPostFrameCallback 确保在 build 流程结束后再执行导航
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              handleGoTodoDetail(context, sessionState.pendingTodoRecord!);
              // **关键**：导航逻辑触发后，立即发送事件“消费”掉这个导航信息
              context.read<SessionBloc>().add(
                const SessionClearPendingNavigation(),
              );
            }
          });
        }

        // 处理会话身份切换或项目切换，这需要重置Tabs并重新加载记录
        final last = _lastSessionState;
        final typeChanged = last?.runtimeType != sessionState.runtimeType;
        final projectChanged =
            last is SessionProjectEstablished &&
            sessionState is SessionProjectEstablished &&
            last.project.projectId != sessionState.project.projectId;
        if (typeChanged || projectChanged) {
          if (mounted) {
            // 🎯 关键修复：项目切换时清空缓存，避免旧项目数据干扰
            if (projectChanged) {
              try {
                getIt<RecordsRepository>().clearCache();
              } catch (_) {}
            }

            setState(() {
              _setupTabsBySession(sessionState);
              // 重置 RecordsBloc 状态，并加载新身份下的默认Tab
              final ids = _resolveIds(sessionState);

              // 🎯 关键修复：预加载所有需要显示 badge 的 tab 数据
              // 注意：_preloadTabBadgeCounts 会处理当前 tab，所以这里不需要再单独加载
              _preloadTabBadgeCounts(sessionState, ids.$1, ids.$2);
            });
          }
        }
        // 更新上一次的会话状态，用于下一次比较
        _lastSessionState = sessionState;
      },
      // `builder` 只负责根据当前状态构建UI，不包含任何业务逻辑
      builder: (context, sessionState) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('工作记录'),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: Size.zero,
              child: Container(height: 1, color: Colors.grey[200]),
            ),
          ),
          body: Column(
            children: [
              BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, inventoryState) {
                  return BlocBuilder<RecordsBloc, RecordsState>(
                    builder: (context, recordsState) {
                      RecordType currentTab = _initialTab;
                      if (recordsState is RecordsInitial) {
                        currentTab = recordsState.currentTab;
                      } else if (recordsState is RecordsLoading) {
                        currentTab = recordsState.currentTab;
                      } else if (recordsState is RecordsLoaded) {
                        currentTab = recordsState.currentTab;
                      } else if (recordsState is RecordsError) {
                        currentTab = recordsState.currentTab;
                      } else if (recordsState is RecordsEmpty) {
                        currentTab = recordsState.currentTab;
                      }

                      // 计算每个 tab 的 badge 数量
                      final badgeCounts = _computeTabBadgeCounts(
                        sessionState,
                        inventoryState,
                      );

                      return ScrollableTabBar(
                        selectedTab: currentTab,
                        onTabSelected: _onTabSelected,
                        allTabs: _allTabs,
                        badgeCounts: badgeCounts,
                      );
                    },
                  );
                },
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return BlocBuilder<RecordsBloc, RecordsState>(
      builder: (context, recordsState) {
        // 获取当前选中的 tab
        RecordType currentTab = RecordType.todo;
        if (recordsState is RecordsInitial) {
          currentTab = recordsState.currentTab;
        } else if (recordsState is RecordsLoading) {
          currentTab = recordsState.currentTab;
        } else if (recordsState is RecordsLoaded) {
          currentTab = recordsState.currentTab;
        } else if (recordsState is RecordsError) {
          currentTab = recordsState.currentTab;
        } else if (recordsState is RecordsEmpty) {
          currentTab = recordsState.currentTab;
        }

        // 如果是盘点任务tab，使用InventoryBloc的数据
        if (currentTab == RecordType.builderInventory) {
          return BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, inventoryState) {
              if (inventoryState.listStatus == DataStatus.loading) {
                return const common.LoadingWidget(message: '加载中...');
              } else if (inventoryState.listStatus == DataStatus.success) {
                // 将 InventoryListItemVO 转换为 InventoryRecordItem
                final records = inventoryState.inventoryList
                    .map((item) => InventoryRecordItem(item))
                    .toList();

                return _buildRecordsList(
                  records,
                  hasMoreData: !inventoryState.hasReachedMax,
                  isLoadingMore: false,
                );
              } else if (inventoryState.listStatus == DataStatus.failure) {
                return common.ErrorWidget(
                  message: inventoryState.errorMessage ?? '获取盘点任务失败',
                  onRetry: () {
                    context.read<InventoryBloc>().add(
                      const InventoryTasksFetched(isRefresh: true),
                    );
                  },
                );
              } else if (inventoryState.listStatus == DataStatus.initial &&
                  inventoryState.inventoryList.isEmpty) {
                return common.EmptyWidget(
                  message: '暂无盘点任务',
                  onRetry: () {
                    context.read<InventoryBloc>().add(
                      const InventoryTasksFetched(isRefresh: true),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          );
        }

        // 其他tab使用RecordsBloc的数据
        if (recordsState is RecordsInitial) {
          return const common.LoadingWidget(message: '加载中...');
        } else if (recordsState is RecordsLoading) {
          if (recordsState.cachedRecords != null &&
              recordsState.cachedRecords!.isNotEmpty) {
            return _buildRecordsList(
              recordsState.cachedRecords!,
              isLoading: true,
            );
          }
          return const common.LoadingWidget(message: '加载中...');
        } else if (recordsState is RecordsLoaded) {
          return _buildRecordsList(
            recordsState.records,
            hasMoreData: recordsState.hasMoreData,
            isLoadingMore: recordsState.isLoadingMore,
          );
        } else if (recordsState is RecordsError) {
          if (recordsState.cachedRecords != null &&
              recordsState.cachedRecords!.isNotEmpty) {
            return _buildRecordsList(
              recordsState.cachedRecords!,
              hasError: true,
            );
          }
          return common.ErrorWidget(
            message: recordsState.message,
            onRetry: _onRefresh,
          );
        } else if (recordsState is RecordsEmpty) {
          return common.EmptyWidget(
            message: '暂无${recordsState.currentTab.displayName}',
            onRetry: _onRefresh,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// 解析当前会话中的 userId (int?) 和 projectId (int?)
  (int?, int?) _resolveIds(SessionState sessionState) {
    int? uid;
    int? pid;
    if (sessionState is SessionProjectEstablished) {
      // WxLoginVO.id is String per model, convert to int if numeric
      uid = int.tryParse(sessionState.user.id);
      pid = sessionState.project.projectId;
    } else if (sessionState is SessionStorekeeperEstablished) {
      uid = int.tryParse(sessionState.user.id);
    }
    return (uid, pid);
  }

  /// 预加载需要显示 badge 的 tab 数据（项目切换时调用）
  void _preloadTabBadgeCounts(SessionState sessionState, int? uid, int? pid) {
    // 🎯 关键：对于当前激活的tab，使用pageSize=10加载完整列表
    // 对于其他需要badge的tab，使用pageSize=1仅获取total

    // 仓管员需要预加载仓库待办
    if (sessionState is SessionStorekeeperEstablished) {
      final isCurrentTab = _initialTab == RecordType.warehouseTodo;
      context.read<RecordsBloc>().add(
        LoadRecords(
          recordType: RecordType.warehouseTodo,
          userId: uid,
          projectId: pid,
          pageNum: 1,
          pageSize: isCurrentTab ? 10 : 1, // 当前tab用10，其他用1
          tracingContext: TracingContext(
            source: 'records_list_page',
            action: isCurrentTab ? 'load_current_tab' : 'preload_badge_count',
            description: isCurrentTab ? '加载仓库待办列表' : '预加载仓库待办数量',
          ),
        ),
      );

      // 预加载普通待办（仓管员也有）
      final isTodoCurrentTab = _initialTab == RecordType.todo;
      context.read<RecordsBloc>().add(
        LoadRecords(
          recordType: RecordType.todo,
          userId: uid,
          projectId: pid,
          pageNum: 1,
          pageSize: isTodoCurrentTab ? 10 : 1,
          tracingContext: TracingContext(
            source: 'records_list_page',
            action: isTodoCurrentTab
                ? 'load_current_tab'
                : 'preload_badge_count',
            description: isTodoCurrentTab ? '加载待办列表' : '预加载待办数量',
          ),
        ),
      );
    }

    // 施工方需要预加载 todo、siteTodo
    if (sessionState is SessionProjectEstablished) {
      final role = sessionState.currentUserRoleInfo.projectRoleType;

      // 所有项目参与方都需要 todo
      final isTodoCurrentTab = _initialTab == RecordType.todo;
      context.read<RecordsBloc>().add(
        LoadRecords(
          recordType: RecordType.todo,
          userId: uid,
          projectId: pid,
          pageNum: 1,
          pageSize: isTodoCurrentTab ? 10 : 1, // 当前tab用10，其他用1
          tracingContext: TracingContext(
            source: 'records_list_page',
            action: isTodoCurrentTab
                ? 'load_current_tab'
                : 'preload_badge_count',
            description: isTodoCurrentTab ? '加载待办列表' : '预加载待办数量',
          ),
        ),
      );

      // builder、builderSub、laborer 需要 siteTodo
      if (role == UserRole.builder ||
          role == UserRole.builderSub ||
          role == UserRole.laborer) {
        final isSiteTodoCurrentTab = _initialTab == RecordType.siteTodo;
        context.read<RecordsBloc>().add(
          LoadRecords(
            recordType: RecordType.siteTodo,
            userId: uid,
            projectId: pid,
            pageNum: 1,
            pageSize: isSiteTodoCurrentTab ? 10 : 1,
            tracingContext: TracingContext(
              source: 'records_list_page',
              action: isSiteTodoCurrentTab
                  ? 'load_current_tab'
                  : 'preload_badge_count',
              description: isSiteTodoCurrentTab ? '加载现场待办列表' : '预加载现场待办数量',
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

  /// 计算需要显示 badge 的 tab 的数量
  /// 只计算 todo、siteTodo、builderInventory、warehouseTodo
  Map<RecordType, int> _computeTabBadgeCounts(
    SessionState sessionState,
    InventoryState inventoryState,
  ) {
    final badgeCounts = <RecordType, int>{};
    final ids = _resolveIds(sessionState);
    final int? uid = ids.$1;
    final int? pid = ids.$2;

    try {
      final repo = getIt<RecordsRepository>();

      // 1. todo（所有角色都有）
      final todoMeta = repo.getCachedMeta(
        RecordType.todo,
        userId: uid,
        projectId: pid,
      );
      final todoCount = todoMeta?.total ?? 0;
      if (todoCount > 0) {
        badgeCounts[RecordType.todo] = todoCount;
      }

      // 2. warehouseTodo（仓管员）
      if (sessionState is SessionStorekeeperEstablished) {
        final whMeta = repo.getCachedMeta(
          RecordType.warehouseTodo,
          userId: uid,
          projectId: pid,
        );
        final whCount = whMeta?.total ?? 0;
        if (whCount > 0) {
          badgeCounts[RecordType.warehouseTodo] = whCount;
        }
      }

      // 3. siteTodo（builder、builderSub、laborer）
      if (sessionState is SessionProjectEstablished) {
        final role = sessionState.currentUserRoleInfo.projectRoleType;
        if (role == UserRole.builder ||
            role == UserRole.builderSub ||
            role == UserRole.laborer) {
          final siteTodoMeta = repo.getCachedMeta(
            RecordType.siteTodo,
            userId: uid,
            projectId: pid,
          );
          final siteTodoCount = siteTodoMeta?.total ?? 0;
          if (siteTodoCount > 0) {
            badgeCounts[RecordType.siteTodo] = siteTodoCount;
          }
        }

        // 4. builderInventory（builder、builderSub）
        if (role == UserRole.builder || role == UserRole.builderSub) {
          final inventoryCount = inventoryState.totalTasks;
          if (inventoryCount > 0) {
            badgeCounts[RecordType.builderInventory] = inventoryCount;
          }
        }
      }
    } catch (_) {
      // ignore cache failures
    }

    return badgeCounts;
  }

  Widget _buildRecordsList(
    List records, {
    bool hasMoreData = false,
    bool isLoadingMore = false,
    bool isLoading = false,
    bool hasError = false,
  }) {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: Column(
        children: [
          if (isLoading)
            const SizedBox(height: 2, child: LinearProgressIndicator()),
          if (hasError)
            Container(
              width: double.infinity,
              color: Colors.orange[50],
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.orange[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '数据可能不是最新的，请下拉刷新',
                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: records.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == records.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final record = records[index];

                // 盘点任务使用专用的列表项组件
                if (record is InventoryRecordItem) {
                  return InventoryRecordListItem(
                    record: record,
                    onTap: () => _onRecordTap(context, record),
                  );
                }

                // 其他类型使用通用的列表项组件
                return RecordListItem(
                  record: record,
                  onTap: () => _onRecordTap(context, record),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleSelectProject(
    BuildContext context,
    int projectId,
    TodoRecordItem record,
  ) {
    final sessionState = context.read<SessionBloc>().state;
    int? currentProjectId;
    bool isProjectEstablished = false;

    if (sessionState is SessionProjectEstablished) {
      currentProjectId = sessionState.project.projectId;
      isProjectEstablished = true;
    }

    if (isProjectEstablished && currentProjectId == projectId) {
      handleGoTodoDetail(context, record);
      return;
    }

    final isParticipant = sessionState is SessionProjectEstablished;
    final dialogTitle = isParticipant ? '该操作需要切换项目' : '该操作需要切换至项目参与方';
    final dialogContent = isParticipant
        ? '该待办不属于当前项目，若确认查看详情，将自动切换到目标项目'
        : '当前身份为库管员，若继续该操作，将自动切换至项目参与方并选中该项目';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: Text(dialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (!isParticipant) {
                  context.read<SessionBloc>().add(
                    SessionSelectProjectParticipant(
                      pendingProjectId: projectId,
                      pendingTodoRecord: record,
                    ),
                  );
                } else {
                  context.read<SessionBloc>().add(
                    SessionSelectProjectWithPendingNavigation(
                      projectId: projectId,
                      pendingTodoRecord: record,
                    ),
                  );
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }
}
