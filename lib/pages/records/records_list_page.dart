import 'package:flutter/material.dart';
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
import '../../widgets/expandable_tab_bar.dart';
import '../../widgets/record_list_item.dart';
import '../../widgets/common_state_widgets.dart' as common;

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

    // 首次进入时自动加载默认tab（如待办）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RecordsBloc>().add(LoadRecords(recordType: _initialTab));
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
    if (isStoreKeeper) {
      // 仓管员身份，展示"待办"和"仓管待办"
      tabs = [RecordType.todo, RecordType.warehouseTodo];
    } else {
      // 普通项目参与方，只展示"待办"
      tabs = [RecordType.todo];
    }
    // 追加其他所有tab，且仅当isStoreKeeper为true时才包含inventory
    tabs.addAll(
      RecordType.values.where(
        (e) =>
            e != RecordType.todo &&
            e != RecordType.warehouseTodo &&
            (e != RecordType.inventory || isStoreKeeper),
      ),
    );
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
          bloc.add(LoadMoreRecords(recordType: state.currentTab));
        }
      }
    }
  }

  void _onTabSelected(RecordType recordType) {
    context.read<RecordsBloc>().add(SwitchTab(recordType));
  }

  void _onRefresh() {
    final bloc = context.read<RecordsBloc>();
    bloc.add(RefreshRecords(recordType: bloc.currentTab));
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

        // 处理会话身份切换，这需要重置Tabs并重新加载记录
        if (_lastSessionState?.runtimeType != sessionState.runtimeType) {
          if (mounted) {
            setState(() {
              _setupTabsBySession(sessionState);
              // 重置 RecordsBloc 状态，并加载新身份下的默认Tab
              context.read<RecordsBloc>().add(
                LoadRecords(recordType: _initialTab),
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
                  return ExpandableTabBar(
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
