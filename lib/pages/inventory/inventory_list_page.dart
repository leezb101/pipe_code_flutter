import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_event.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_state.dart';
import 'package:pipe_code_flutter/models/inventory/inventory_models.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;

class InventoryListPage extends StatefulWidget {
  const InventoryListPage({super.key});

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Data is now fetched from HomePage when storekeeper logs in.
    // We can add a refresh here if the list is empty.
    if (context.read<InventoryBloc>().state.inventoryList.isEmpty) {
      context.read<InventoryBloc>().add(
        const InventoryTasksFetched(isRefresh: true),
      );
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<InventoryBloc>().state;
      if (state.listStatus != DataStatus.loading && !state.hasReachedMax) {
        context.read<InventoryBloc>().add(const InventoryTasksFetched());
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    context.read<InventoryBloc>().add(
      const InventoryTasksFetched(isRefresh: true),
    );
  }

  void _onItemTap(InventoryListItemVO item) {
    context.push('/inventory-apply', extra: item.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('盘点任务'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          final isLoadingMore =
              state.listStatus == DataStatus.loading &&
              state.inventoryList.isNotEmpty;

          switch (state.listStatus) {
            case DataStatus.initial:
            case DataStatus.loading:
              if (state.inventoryList.isEmpty) {
                return const common.LoadingWidget(message: '正在加载任务...');
              }
              return _buildList(
                state,
                isLoading: false,
                isLoadingMore: isLoadingMore,
              );
            case DataStatus.failure:
              return state.inventoryList.isEmpty
                  ? common.ErrorWidget(
                      message: state.errorMessage ?? '加载失败，请稍后重试',
                      onRetry: _onRefresh,
                    )
                  : _buildList(state, hasError: true, isLoadingMore: false);
            case DataStatus.success:
              if (state.inventoryList.isEmpty) {
                return common.EmptyWidget(
                  message: '暂无盘点任务',
                  onRetry: _onRefresh,
                );
              }
              return _buildList(state, isLoadingMore: false);
          }
        },
      ),
    );
  }

  Widget _buildList(
    InventoryState state, {
    bool isLoading = false,
    bool hasError = false,
    bool isLoadingMore = false,
  }) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),
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
                    '数据加载失败，可能不是最新的',
                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              itemCount: state.inventoryList.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.inventoryList.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final item = state.inventoryList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 1.5,
                  child: ListTile(
                    title: Text(
                      item.name ?? '未命名任务',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('负责人: ${item.bindUserName ?? 'N/A'}'),
                        const SizedBox(height: 2),
                        Text('物料数量: ${item.materialNum}'),
                        const SizedBox(height: 2),
                        Text('创建时间: ${item.createdTime ?? 'N/A'}'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _onItemTap(item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
