import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../models/records/record_type.dart';
import '../../repositories/interfaces/records_repository.dart';
import '../../utils/logger.dart';
import 'records_event.dart';
import 'records_state.dart';

// 内部类：用于存储待刷新的参数
class _PendingRefreshParams {
  final RecordType recordType;
  final int? projectId;
  final int? userId;

  _PendingRefreshParams({
    required this.recordType,
    this.projectId,
    this.userId,
  });
}

class RecordsBloc extends Bloc<RecordsEvent, RecordsState> {
  final RecordsRepository _repository;
  // 为每个recordType维护独立的防抖timer和参数
  final Map<RecordType, Timer> _refreshDebounceTimers = {};
  final Map<RecordType, _PendingRefreshParams> _pendingRefreshParams = {};

  RecordsBloc(this._repository) : super(const RecordsInitial()) {
    on<LoadRecords>(_onLoadRecords);
    on<SwitchTab>(_onSwitchTab);
    on<RefreshRecords>(_onRefreshRecordsDebounced);
    on<DebouncedRefreshRecords>(_onRefreshRecords);
    on<LoadMoreRecords>(_onLoadMoreRecords);
    on<ClearRecordsCache>(_onClearRecordsCache);
  }

  Future<void> _onLoadRecords(
    LoadRecords event,
    Emitter<RecordsState> emit,
  ) async {
    try {
      final cachedRecords = _repository.getCachedRecords(
        event.recordType,
        userId: event.userId,
        projectId: event.projectId,
      );

      if (event.pageNum == 1) {
        emit(
          RecordsLoading(
            currentTab: event.recordType,
            cachedRecords: cachedRecords,
          ),
        );
      } else if (state is RecordsLoaded) {
        final currentState = state as RecordsLoaded;
        emit(currentState.copyWith(isLoadingMore: true));
      }

      final paged = await _repository.getRecordsWithMeta(
        recordType: event.recordType,
        projectId: event.projectId,
        userId: event.userId,
        pageNum: event.pageNum,
        pageSize: event.pageSize,
        forceRefresh: event.forceRefresh,
      );
      final records = paged.records;

      if (records.isEmpty && event.pageNum == 1) {
        emit(RecordsEmpty(event.recordType));
        return;
      }

      final hasMoreData = paged.meta.hasMore;

      if (event.pageNum == 1) {
        emit(
          RecordsLoaded(
            currentTab: event.recordType,
            records: records,
            hasMoreData: hasMoreData,
            currentPage: event.pageNum,
          ),
        );
      } else if (state is RecordsLoaded) {
        final currentState = state as RecordsLoaded;
        final allRecords = [...currentState.records, ...records];

        emit(
          RecordsLoaded(
            currentTab: event.recordType,
            records: allRecords,
            hasMoreData: hasMoreData,
            currentPage: event.pageNum,
            isLoadingMore: false,
          ),
        );
      }

      Logger.info(
        'Loaded ${records.length} records for ${event.recordType}',
        tag: 'RecordsBloc',
      );
    } catch (e) {
      Logger.error('Failed to load records: $e', tag: 'RecordsBloc');

      final cachedRecords = _repository.getCachedRecords(
        event.recordType,
        userId: event.userId,
        projectId: event.projectId,
      );

      if (event.pageNum == 1) {
        emit(
          RecordsError(
            currentTab: event.recordType,
            message: _getErrorMessage(e),
            cachedRecords: cachedRecords,
          ),
        );
      } else if (state is RecordsLoaded) {
        final currentState = state as RecordsLoaded;
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _onSwitchTab(SwitchTab event, Emitter<RecordsState> emit) async {
    Logger.info('Switching to tab: ${event.recordType}', tag: 'RecordsBloc');
    final cachedRecords = _repository.getCachedRecords(
      event.recordType,
      userId: event.userId,
      projectId: event.projectId,
    );
    final pageSize = 10; // 与LoadRecords默认pageSize保持一致
    if (cachedRecords != null && cachedRecords.isNotEmpty) {
      emit(
        RecordsLoaded(
          currentTab: event.recordType,
          records: cachedRecords,
          hasMoreData: cachedRecords.length >= pageSize,
          currentPage: 1,
        ),
      );
    } else {
      add(
        LoadRecords(
          recordType: event.recordType,
          userId: event.userId,
          projectId: event.projectId,
        ),
      );
    }
  }

  /// 去抖入口：1秒内多次RefreshRecords只触发一次，但不同recordType可以并发执行
  Future<void> _onRefreshRecordsDebounced(
    RefreshRecords event,
    Emitter<RecordsState> emit,
  ) async {
    final recordType = event.recordType;

    // 存储当前recordType的待刷新参数
    _pendingRefreshParams[recordType] = _PendingRefreshParams(
      recordType: recordType,
      projectId: event.projectId,
      userId: event.userId,
    );

    // 取消该recordType之前的定时器
    _refreshDebounceTimers[recordType]?.cancel();

    // 为当前recordType设置新的定时器
    _refreshDebounceTimers[recordType] = Timer(const Duration(seconds: 1), () {
      final params = _pendingRefreshParams[recordType];
      if (params != null) {
        add(
          DebouncedRefreshRecords(
            recordType: params.recordType,
            projectId: params.projectId,
            userId: params.userId,
          ),
        );
        // 清理该recordType的缓存参数
        _pendingRefreshParams.remove(recordType);
        _refreshDebounceTimers.remove(recordType);
      }
    });
  }

  Future<void> _onRefreshRecords(
    DebouncedRefreshRecords event,
    Emitter<RecordsState> emit,
  ) async {
    Logger.info(
      'Refreshing records for ${event.recordType}',
      tag: 'RecordsBloc',
    );

    _repository.clearCache(event.recordType);

    add(
      LoadRecords(
        recordType: event.recordType,
        projectId: event.projectId,
        userId: event.userId,
        forceRefresh: true,
      ),
    );
  }

  Future<void> _onLoadMoreRecords(
    LoadMoreRecords event,
    Emitter<RecordsState> emit,
  ) async {
    if (state is RecordsLoaded) {
      final currentState = state as RecordsLoaded;

      if (!currentState.hasMoreData || currentState.isLoadingMore) {
        return;
      }

      add(
        LoadRecords(
          recordType: event.recordType,
          projectId: event.projectId,
          userId: event.userId,
          pageNum: currentState.currentPage + 1,
          pageSize: event.pageSize,
        ),
      );
    }
  }

  Future<void> _onClearRecordsCache(
    ClearRecordsCache event,
    Emitter<RecordsState> emit,
  ) async {
    _repository.clearCache(event.recordType);
    Logger.info(
      'Cleared cache for ${event.recordType ?? 'all records'}',
      tag: 'RecordsBloc',
    );
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

  RecordType get currentTab {
    if (state is RecordsInitial) {
      return (state as RecordsInitial).currentTab;
    } else if (state is RecordsLoading) {
      return (state as RecordsLoading).currentTab;
    } else if (state is RecordsLoaded) {
      return (state as RecordsLoaded).currentTab;
    } else if (state is RecordsError) {
      return (state as RecordsError).currentTab;
    } else if (state is RecordsEmpty) {
      return (state as RecordsEmpty).currentTab;
    }
    return RecordType.todo;
  }

  bool get hasData {
    return state is RecordsLoaded &&
        (state as RecordsLoaded).records.isNotEmpty;
  }

  bool get isLoading {
    return state is RecordsLoading;
  }

  bool get isError {
    return state is RecordsError;
  }

  bool get isEmpty {
    return state is RecordsEmpty;
  }

  @override
  Future<void> close() {
    // 取消所有recordType的防抖定时器
    for (final timer in _refreshDebounceTimers.values) {
      timer.cancel();
    }
    _refreshDebounceTimers.clear();
    _pendingRefreshParams.clear();
    return super.close();
  }
}
