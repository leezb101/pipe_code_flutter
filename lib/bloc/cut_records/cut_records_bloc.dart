import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/cut/cut_records_item_vo.dart';
import 'package:pipe_code_flutter/models/cut/cut_statistic_vo.dart';
import 'package:pipe_code_flutter/services/api/interfaces/cut_records_api_service.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'cut_records_event.dart';
import 'cut_records_state.dart';

class CutRecordsBloc extends Bloc<CutRecordsEvent, CutRecordsState> {
  final CutRecordsApiService _apiService;

  // 缓存数据
  List<CutRecordsItemVO> _cachedRecords = [];
  CutStatisticVo? _cachedStatistics;
  int _currentPage = 1;
  static const int _pageSize = 10;

  CutRecordsBloc(this._apiService) : super(const CutRecordsInitial()) {
    on<LoadCutRecords>(_onLoadCutRecords);
    on<RefreshCutRecords>(_onRefreshCutRecords);
    on<LoadMoreCutRecords>(_onLoadMoreCutRecords);
    on<ClearCutRecordsCache>(_onClearCutRecordsCache);
  }

  Future<void> _onLoadCutRecords(
    LoadCutRecords event,
    Emitter<CutRecordsState> emit,
  ) async {
    try {
      // 如果是第一页，显示加载状态
      if (event.pageNum == 1) {
        emit(
          CutRecordsLoading(
            statistics: _cachedStatistics,
            cachedRecords: _cachedRecords,
          ),
        );
      } else if (state is CutRecordsLoaded) {
        // 加载更多时，显示底部加载指示器
        final currentState = state as CutRecordsLoaded;
        emit(currentState.copyWith(isLoadingMore: true));
      }

      // 并行加载统计数据和列表数据
      final results = await Future.wait([
        event.pageNum == 1 || _cachedStatistics == null
            ? _apiService.fetchCutStatistics()
            : Future.value(null),
        _apiService.fetchCutRecords(page: event.pageNum, pageSize: _pageSize),
      ]);

      // 处理统计数据
      if (results[0] != null) {
        final statisticsResult = results[0] as dynamic;
        if (statisticsResult.success && statisticsResult.data != null) {
          _cachedStatistics = statisticsResult.data as CutStatisticVo;
        }
      }

      // 处理列表数据
      final pagedRecords = results[1] as dynamic;
      final records = pagedRecords.records as List<CutRecordsItemVO>;
      final hasMore = pagedRecords.meta.hasMore as bool;

      if (event.pageNum == 1) {
        _cachedRecords = records;
        _currentPage = 1;
      } else {
        _cachedRecords.addAll(records);
        _currentPage = event.pageNum;
      }

      if (_cachedStatistics == null) {
        emit(const CutRecordsError(message: '加载统计数据失败'));
        return;
      }

      if (_cachedRecords.isEmpty && event.pageNum == 1) {
        emit(CutRecordsEmpty(statistics: _cachedStatistics!));
      } else {
        emit(
          CutRecordsLoaded(
            statistics: _cachedStatistics!,
            records: List.from(_cachedRecords),
            hasMoreData: hasMore,
            currentPage: _currentPage,
          ),
        );
      }

      Logger.info(
        'Loaded cut records: page=$_currentPage, count=${records.length}, total=${_cachedRecords.length}',
        tag: 'CutRecordsBloc',
      );
    } catch (e) {
      Logger.error('Failed to load cut records: $e', tag: 'CutRecordsBloc');

      if (event.pageNum == 1) {
        emit(
          CutRecordsError(
            message: _getErrorMessage(e),
            statistics: _cachedStatistics,
            cachedRecords: _cachedRecords,
          ),
        );
      } else if (state is CutRecordsLoaded) {
        // 加载更多失败时，恢复之前的状态
        final currentState = state as CutRecordsLoaded;
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _onRefreshCutRecords(
    RefreshCutRecords event,
    Emitter<CutRecordsState> emit,
  ) async {
    Logger.info('Refreshing cut records', tag: 'CutRecordsBloc');
    _clearCache();
    add(const LoadCutRecords(pageNum: 1, forceRefresh: true));
  }

  Future<void> _onLoadMoreCutRecords(
    LoadMoreCutRecords event,
    Emitter<CutRecordsState> emit,
  ) async {
    if (state is CutRecordsLoaded) {
      final currentState = state as CutRecordsLoaded;

      if (!currentState.hasMoreData || currentState.isLoadingMore) {
        return;
      }

      add(LoadCutRecords(pageNum: _currentPage + 1));
    }
  }

  Future<void> _onClearCutRecordsCache(
    ClearCutRecordsCache event,
    Emitter<CutRecordsState> emit,
  ) async {
    _clearCache();
    Logger.info('Cleared cut records cache', tag: 'CutRecordsBloc');
  }

  void _clearCache() {
    _cachedRecords = [];
    _cachedStatistics = null;
    _currentPage = 1;
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('Exception:')) {
        return message.replaceFirst('Exception: ', '');
      }
      return message;
    }
    return '获取数据失败，请稍后重试';
  }

  bool get hasData => state is CutRecordsLoaded;
  bool get isLoading => state is CutRecordsLoading;
  bool get isError => state is CutRecordsError;
  bool get isEmpty => state is CutRecordsEmpty;
}
