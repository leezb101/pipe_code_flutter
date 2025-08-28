import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/records/record_item.dart';
import 'package:pipe_code_flutter/models/user/wx_login_vo.dart';
import '../../bloc/session/session_bloc.dart';
import '../../bloc/session/session_state.dart';
import '../../bloc/session/session_event.dart';
import '../../bloc/records/records_bloc.dart';
import '../../bloc/records/records_event.dart';
import '../../bloc/records/records_state.dart';
import '../../models/records/record_type.dart';
import '../../widgets/scrollable_tab_bar.dart';
import '../../widgets/record_list_item.dart';
import '../../widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/services/notification/notification_center.dart';
import 'package:pipe_code_flutter/models/notification/notification_message_vo.dart';

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
        final ids = _resolveIds(context.read<SessionBloc>().state);
        context.read<RecordsBloc>().add(
          LoadRecords(
            recordType: _initialTab,
            userId: ids.$1,
            projectId: ids.$2,
          ),
        );
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
      // 追加其他所有tab，但排除仓管专用的tabs
      tabs.addAll(
        RecordType.values.where(
          (e) =>
              e != RecordType.todo &&
              e != RecordType.warehouseTodo &&
              e != RecordType.signinWarehouse &&
              e != RecordType.signoutWarehouse &&
              e != RecordType.inventory, // 盘点记录也只有仓管员可见
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
      final bloc = context.read<RecordsBloc>();
      if (bloc.state is RecordsLoaded) {
        final state = bloc.state as RecordsLoaded;
        if (state.hasMoreData && !state.isLoadingMore) {
          final ids = _resolveIds(context.read<SessionBloc>().state);
          bloc.add(
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
    context.read<RecordsBloc>().add(
      SwitchTab(recordType, userId: ids.$1, projectId: ids.$2),
    );
  }

  void _onRefresh() {
    final bloc = context.read<RecordsBloc>();
    final ids = _resolveIds(context.read<SessionBloc>().state);
    bloc.add(
      RefreshRecords(
        recordType: bloc.currentTab,
        userId: ids.$1,
        projectId: ids.$2,
      ),
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
        final rec = record as TodoRecordItem;
        handleGoTodoDetail(context, rec);
        break;
      default:
      // 其他列表的点击事件
    }
  }

  void handleGoTodoDetail(BuildContext context, TodoRecordItem rec) {
    // 根据待办的具体类型（type.name）或名称（todoName）导航
    if (rec.todo.type.name == '验收确认') {
      context.goNamed(
        'acceptance-confirmation',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    } else if (rec.todo.type.name == '验收后入库') {
      context.goNamed(
        'acceptance-after-signin',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    } else if (rec.todo.todoName == 'sign_out') {
      context.goNamed(
        'signout-audit',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    } else if (rec.todo.todoName == 'sign_out_install') {
      context.goNamed(
        'install',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    } else if (rec.todo.todoName == 'dispatch') {
      context.goNamed(
        'dispatch-confirmation',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    } else if (rec.todo.todoName == 'dispatch_sign_in') {
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
            setState(() {
              _setupTabsBySession(sessionState);
              // 重置 RecordsBloc 状态，并加载新身份下的默认Tab
              final ids = _resolveIds(sessionState);
              // 强制刷新以绕开缓存
              context.read<RecordsBloc>().add(
                RefreshRecords(
                  recordType: _initialTab,
                  userId: ids.$1,
                  projectId: ids.$2,
                ),
              );
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
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: Size.zero,
              child: Container(height: 1, color: Colors.grey[200]),
            ),
          ),
          body: Column(
            children: [
              BlocBuilder<RecordsBloc, RecordsState>(
                builder: (context, state) {
                  RecordType currentTab = _initialTab;
                  if (state is RecordsInitial) {
                    currentTab = state.currentTab;
                  } else if (state is RecordsLoading) {
                    currentTab = state.currentTab;
                  } else if (state is RecordsLoaded) {
                    currentTab = state.currentTab;
                  } else if (state is RecordsError) {
                    currentTab = state.currentTab;
                  } else if (state is RecordsEmpty) {
                    currentTab = state.currentTab;
                  }
                  return ScrollableTabBar(
                    selectedTab: currentTab,
                    onTabSelected: _onTabSelected,
                    allTabs: _allTabs,
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
      builder: (context, state) {
        if (state is RecordsInitial) {
          return const common.LoadingWidget(message: '加载中...');
        } else if (state is RecordsLoading) {
          if (state.cachedRecords != null && state.cachedRecords!.isNotEmpty) {
            return _buildRecordsList(state.cachedRecords!, isLoading: true);
          }
          return const common.LoadingWidget(message: '加载中...');
        } else if (state is RecordsLoaded) {
          return _buildRecordsList(
            state.records,
            hasMoreData: state.hasMoreData,
            isLoadingMore: state.isLoadingMore,
          );
        } else if (state is RecordsError) {
          if (state.cachedRecords != null && state.cachedRecords!.isNotEmpty) {
            return _buildRecordsList(state.cachedRecords!, hasError: true);
          }
          return common.ErrorWidget(
            message: state.message,
            onRetry: _onRefresh,
          );
        } else if (state is RecordsEmpty) {
          return common.EmptyWidget(
            message: '暂无${state.currentTab.displayName}',
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
