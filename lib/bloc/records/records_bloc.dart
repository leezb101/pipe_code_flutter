import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../models/records/record_type.dart';
import '../../repositories/interfaces/records_repository.dart';
import '../../utils/logger.dart';
import 'records_event.dart';
import 'records_state.dart';

class RecordsBloc extends Bloc<RecordsEvent, RecordsState> {
  final RecordsRepository _repository;
  Timer? _refreshDebounceTimer;
  RecordType? _pendingRefreshTab;
  int? _pendingProjectId;
  int? _pendingUserId;

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

  final records = await _repository.getRecords(
        recordType: event.recordType,
        projectId: event.projectId,
        userId: event.userId,
        pageNum: event.pageNum,
        pageSize: event.pageSize,
        forceRefresh: event.forceRefresh,
      );

      if (records.isEmpty && event.pageNum == 1) {
        emit(RecordsEmpty(event.recordType));
        return;
      }

      final hasMoreData = records.length >= event.pageSize;

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

  /// 去抖入口：1秒内多次RefreshRecords只触发一次
  Future<void> _onRefreshRecordsDebounced(
    RefreshRecords event,
    Emitter<RecordsState> emit,
  ) async {
    // 记录最新一次的请求参数
    _pendingRefreshTab = event.recordType;
    _pendingProjectId = event.projectId;
    _pendingUserId = event.userId;

    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = Timer(const Duration(seconds: 1), () {
      final tab = _pendingRefreshTab;
      if (tab == null) return;
      add(
        DebouncedRefreshRecords(
          recordType: tab,
          projectId: _pendingProjectId,
          userId: _pendingUserId,
        ),
      );
      _pendingRefreshTab = null;
      _pendingProjectId = null;
      _pendingUserId = null;
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
    _refreshDebounceTimer?.cancel();
    return super.close();
  }
}
