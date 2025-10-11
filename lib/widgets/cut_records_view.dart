import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/cut_records/cut_records_bloc.dart';
import 'package:pipe_code_flutter/bloc/cut_records/cut_records_event.dart';
import 'package:pipe_code_flutter/bloc/cut_records/cut_records_state.dart';
import 'package:pipe_code_flutter/models/cut/cut_statistic_vo.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/cut_record_list_item.dart';

/// 截管记录视图
/// 包含粘性统计数据头和可滚动的列表
class CutRecordsView extends StatefulWidget {
  const CutRecordsView({super.key});

  @override
  State<CutRecordsView> createState() => _CutRecordsViewState();
}

class _CutRecordsViewState extends State<CutRecordsView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    // 首次加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CutRecordsBloc>().add(const LoadCutRecords());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<CutRecordsBloc>().add(const LoadMoreCutRecords());
    }
  }

  void _onRefresh() {
    context.read<CutRecordsBloc>().add(const RefreshCutRecords());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CutRecordsBloc, CutRecordsState>(
      builder: (context, state) {
        if (state is CutRecordsInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CutRecordsLoading && state.cachedRecords.isEmpty) {
          return Column(
            children: [
              if (state.statistics != null)
                _buildStatisticsHeader(state.statistics!),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          );
        }

        if (state is CutRecordsError && state.cachedRecords.isEmpty) {
          return Column(
            children: [
              if (state.statistics != null)
                _buildStatisticsHeader(state.statistics!),
              Expanded(
                child: common.ErrorWidget(
                  message: state.message,
                  onRetry: _onRefresh,
                ),
              ),
            ],
          );
        }

        if (state is CutRecordsEmpty) {
          return Column(
            children: [
              _buildStatisticsHeader(state.statistics),
              Expanded(child: common.EmptyWidget(message: '暂无截管记录')),
            ],
          );
        }

        if (state is CutRecordsLoaded) {
          return Column(
            children: [
              _buildStatisticsHeader(state.statistics),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _onRefresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount:
                        state.records.length + (state.hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.records.length) {
                        return _buildLoadingMoreIndicator(state.isLoadingMore);
                      }

                      final record = state.records[index];
                      return CutRecordListItem(
                        record: record,
                        onTap: () {
                          // TODO: 导航到详情页（如果需要）
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// 构建统计数据头（粘性）
  Widget _buildStatisticsHeader(CutStatisticVo statistics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatisticCard(
              label: '截断源管数',
              value: statistics.cutSourceNum.toString(),
              // icon: Icons.source,
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatisticCard(
              label: '截管次数',
              value: statistics.cutTimes.toString(),
              // icon: Icons.content_cut,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatisticCard(
              label: '新截出管数',
              value: statistics.newActivePipeNum.toString(),
              // icon: Icons.add_circle_outline,
              color: const Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个统计卡片
  Widget _buildStatisticCard({
    required String label,
    required String value,
    // required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建加载更多指示器
  Widget _buildLoadingMoreIndicator(bool isLoadingMore) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: isLoadingMore
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('加载更多...', style: TextStyle(color: Colors.grey)),
    );
  }
}
