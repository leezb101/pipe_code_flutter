import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_event.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_state.dart';
import 'package:pipe_code_flutter/models/inventory/inventory_models.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

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
    context.goNamed('inventory-apply', extra: item.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('盘点任务'),
        backgroundColor: AppTheme.getBusinessColor('inventory'),
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
                return UnifiedCard(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  businessType: 'inventory',
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.getBusinessColorLight(
                        'inventory',
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: AppTheme.getBusinessColor('inventory'),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.name ?? '未命名任务',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        InfoRow(
                          label: '负责人',
                          value: item.bindUserName ?? 'N/A',
                          spacing: AppTheme.spacingXSmall,
                        ),
                        const SizedBox(height: 2),
                        InfoRow(
                          label: '物料数量',
                          value: '${item.materialNum}',
                          spacing: AppTheme.spacingXSmall,
                        ),
                        const SizedBox(height: 2),
                        InfoRow(
                          label: '创建时间',
                          value: item.createdTime?.toString() ?? 'N/A',
                          spacing: AppTheme.spacingXSmall,
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppTheme.getBusinessColor('inventory'),
                    ),
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
