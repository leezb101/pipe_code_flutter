import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/records/record_type.dart';
import '../../repositories/records_repository.dart';
import '../../utils/logger.dart';
import 'records_event.dart';
import 'records_state.dart';

class RecordsBloc extends Bloc<RecordsEvent, RecordsState> {
  final RecordsRepository _repository;

  RecordsBloc(this._repository) : super(const RecordsInitial()) {
    on<LoadRecords>(_onLoadRecords);
    on<SwitchTab>(_onSwitchTab);
    on<RefreshRecords>(_onRefreshRecords);
    on<LoadMoreRecords>(_onLoadMoreRecords);
    on<ClearRecordsCache>(_onClearRecordsCache);
  }

  Future<void> _onLoadRecords(
    LoadRecords event,
    Emitter<RecordsState> emit,
  ) async {
    try {
      final cachedRecords = _repository.getCachedRecords(event.recordType);
      
      if (event.pageNum == 1) {
        emit(RecordsLoading(
          currentTab: event.recordType,
          cachedRecords: cachedRecords,
        ));
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
        emit(RecordsLoaded(
          currentTab: event.recordType,
          records: records,
          hasMoreData: hasMoreData,
          currentPage: event.pageNum,
        ));
      } else if (state is RecordsLoaded) {
        final currentState = state as RecordsLoaded;
        final allRecords = [...currentState.records, ...records];
        
        emit(RecordsLoaded(
          currentTab: event.recordType,
          records: allRecords,
          hasMoreData: hasMoreData,
          currentPage: event.pageNum,
          isLoadingMore: false,
        ));
      }

      Logger.info(
        'Loaded ${records.length} records for ${event.recordType}',
        tag: 'RecordsBloc',
      );
    } catch (e) {
      Logger.error('Failed to load records: $e', tag: 'RecordsBloc');
      
      final cachedRecords = _repository.getCachedRecords(event.recordType);
      
      if (event.pageNum == 1) {
        emit(RecordsError(
          currentTab: event.recordType,
          message: _getErrorMessage(e),
          cachedRecords: cachedRecords,
        ));
      } else if (state is RecordsLoaded) {
        final currentState = state as RecordsLoaded;
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _onSwitchTab(
    SwitchTab event,
    Emitter<RecordsState> emit,
  ) async {
    Logger.info('Switching to tab: ${event.recordType}', tag: 'RecordsBloc');

    final cachedRecords = _repository.getCachedRecords(event.recordType);
    
    if (cachedRecords != null && cachedRecords.isNotEmpty) {
      emit(RecordsLoaded(
        currentTab: event.recordType,
        records: cachedRecords,
        hasMoreData: true,
        currentPage: 1,
      ));
    } else {
      add(LoadRecords(recordType: event.recordType));
    }
  }

  Future<void> _onRefreshRecords(
    RefreshRecords event,
    Emitter<RecordsState> emit,
  ) async {
    Logger.info('Refreshing records for ${event.recordType}', tag: 'RecordsBloc');
    
    _repository.clearCache(event.recordType);
    
    add(LoadRecords(
      recordType: event.recordType,
      projectId: event.projectId,
      userId: event.userId,
      forceRefresh: true,
    ));
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

      add(LoadRecords(
        recordType: event.recordType,
        projectId: event.projectId,
        userId: event.userId,
        pageNum: currentState.currentPage + 1,
        pageSize: event.pageSize,
      ));
    }
  }

  Future<void> _onClearRecordsCache(
    ClearRecordsCache event,
    Emitter<RecordsState> emit,
  ) async {
    _repository.clearCache(event.recordType);
    Logger.info('Cleared cache for ${event.recordType ?? 'all records'}', tag: 'RecordsBloc');
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
    return RecordType.pending;
  }

  bool get hasData {
    return state is RecordsLoaded && (state as RecordsLoaded).records.isNotEmpty;
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
}