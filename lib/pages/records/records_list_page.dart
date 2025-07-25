import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/project/project_bloc.dart';
import 'package:pipe_code_flutter/bloc/project/project_event.dart';
import 'package:pipe_code_flutter/bloc/project/project_state.dart';
import 'package:pipe_code_flutter/models/records/record_item.dart';
import 'package:pipe_code_flutter/repositories/enum_repository.dart';
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

class _RecordsListPageState extends State<RecordsListPage> {
  late ScrollController _scrollController;
  static const List<RecordType> _allTabs = RecordType.values;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
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

    // Navigate to specific detail page based on record type
    switch (currentTab) {
      case RecordType.accept:
        context.goNamed(
          'acceptance-detail',
          queryParameters: {'id': record.id.toString()},
        );
        break;
      // case RecordType.signin:
      case RecordType.signout:
      case RecordType.install:
      case RecordType.returnWarehouse:
      case RecordType.dispatch:
      case RecordType.waste:
      case RecordType.inventory:
      case RecordType.todo:
        final rec = record as TodoRecordItem;
        _handleSelectProject(context, rec.todo.projectId, rec);
        break;
      case RecordType.warehouseTodo:
        final rec = record as TodoRecordItem;
        handleGoTodoDetail(context, rec);
        break;
      default:
        // For other record types, show a placeholder message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${currentTab.displayName}详情页面待开发')),
        );
        break;
    }
  }

  void handleGoTodoDetail(BuildContext context, TodoRecordItem rec) {
    if (rec.todo.type.name == '验收确认') {
      context.goNamed(
        'acceptance-confirmation',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    }
    // 这里需要继续判断，当前item的todoType是什么
    if (rec.todo.type.name == '验收后入库') {
      context.goNamed(
        'acceptance-after-signin',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    }
    if (rec.todo.todoName == 'sign_out') {
      context.goNamed(
        'signout-audit',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    }
    if (rec.todo.todoName == 'sign_out_install') {
      context.goNamed(
        'install',
        queryParameters: {'id': rec.todo.businessId.toString()},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果是第一次进入页面，触发加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<RecordsBloc>();
      if (bloc.state is RecordsInitial) {
        bloc.add(LoadRecords(recordType: widget.initialTab ?? RecordType.todo));
      }
    });

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
              RecordType currentTab = RecordType.todo;
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
    final currentProject =
        context.read<ProjectBloc>().state as ProjectRoleInfoLoaded;
    final currentProjectId = currentProject.currentProject.projectId;
    if (currentProjectId != projectId) {
      // 弹出确认框提示用户
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('该操作需要切换项目'),
            content: const Text('该待办不属于当前项目，若确认查看详情，将自动切换到目标项目'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  context.read<ProjectBloc>().add(
                    ProjectSelectProject(projectId: projectId),
                  );
                  handleGoTodoDetail(context, record);
                },
                child: const Text('确认'),
              ),
            ],
          );
        },
      );
    } else {
      handleGoTodoDetail(context, record);
    }
  }
}
