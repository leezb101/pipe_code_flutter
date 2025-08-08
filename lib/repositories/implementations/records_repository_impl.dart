import 'package:pipe_code_flutter/models/records/record_item.dart';
import 'package:pipe_code_flutter/models/records/record_type.dart';
import 'package:pipe_code_flutter/services/api/interfaces/records_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/todo_api_service.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/repositories/interfaces/records_repository.dart';

class RecordsRepositoryImpl implements RecordsRepository {
  final RecordsApiService _apiService;
  final TodoApiService _todoApiService;
  // Composite cache scoped by userId + projectId + recordType
  final Map<String, List<RecordItem>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheTimeout = const Duration(minutes: 5);

  RecordsRepositoryImpl(this._apiService, this._todoApiService);

  @override
  Future<List<RecordItem>> getRecords({
    required RecordType recordType,
    int? projectId,
    int? userId,
    int pageNum = 1,
    int pageSize = 10,
    bool forceRefresh = false,
  }) async {
    try {
  final cacheKey = _makeCacheKey(recordType, userId: userId, projectId: projectId);
  if (!forceRefresh && _isCacheValidByKey(cacheKey) && pageNum == 1) {
        Logger.info(
          'Returning cached records for $recordType',
          tag: 'RecordsRepository',
        );
        return _cache[cacheKey] ?? [];
      }

      Logger.info(
        'Fetching records for type: $recordType, page: $pageNum',
        tag: 'RecordsRepository',
      );

      List<RecordItem> records;

      if (recordType == RecordType.todo) {
        records = await _getTodoRecords(
          projectId: projectId,
          userId: userId,
          pageNum: pageNum,
          pageSize: pageSize,
        );
      } else if (recordType == RecordType.warehouseTodo) {
        records = await _getWarehouseTodoRecords(
          pageNum: pageNum,
          pageSize: pageSize,
        );
      } else {
        final response = await _apiService.getBusinessRecords(
          recordType: recordType,
          projectId: projectId,
          userId: userId,
          pageNum: pageNum,
          pageSize: pageSize,
        );

        if (!response.isSuccess) {
          throw Exception(response.msg.isNotEmpty ? response.msg : '获取数据失败');
        }

        records = response.data!.records
            .map((record) => BusinessRecordItem(record))
            .toList();
      }

      if (pageNum == 1) {
        _cache[cacheKey] = records;
        _cacheTimestamps[cacheKey] = DateTime.now();
      }

      Logger.info(
        'Successfully fetched ${records.length} records for $recordType',
        tag: 'RecordsRepository',
      );
      return records;
    } catch (e) {
      Logger.error(
        'Failed to fetch records for $recordType: $e',
        tag: 'RecordsRepository',
      );

  final cacheKey = _makeCacheKey(recordType, userId: userId, projectId: projectId);
  if (pageNum == 1 && _cache.containsKey(cacheKey)) {
        Logger.info(
          'Returning cached records due to error',
          tag: 'RecordsRepository',
        );
        return _cache[cacheKey] ?? [];
      }

      rethrow;
    }
  }

  Future<List<RecordItem>> _getTodoRecords({
    int? projectId,
    int? userId,
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    final response = await _todoApiService.getTodoList(
      pageNum: pageNum,
      pageSize: pageSize,
    );

    if (!response.isSuccess) {
      throw Exception(response.msg.isNotEmpty ? response.msg : '获取待办任务失败');
    }

    final todoTasks = response.data!.records;
    return todoTasks.map((todo) => TodoRecordItem(todo)).toList();
  }

  Future<List<RecordItem>> _getWarehouseTodoRecords({
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    final response = await _todoApiService.getWarehouseTodoList(
      pageNum: pageNum,
      pageSize: pageSize,
    );

    if (!response.isSuccess) {
      throw Exception(response.msg.isNotEmpty ? response.msg : '获取仓库待办任务失败');
    }

    return response.data!.records.map((todo) => TodoRecordItem(todo)).toList();
  }

  @override
  Future<List<RecordItem>> getProjectAuditRecords({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  }) async {
    try {
      final response = await _apiService.getProjectAuditRecords(
        pageNum: pageNum,
        pageSize: pageSize,
        projectName: projectName,
        projectCode: projectCode,
      );

      if (!response.isSuccess) {
        throw Exception(response.msg.isNotEmpty ? response.msg : '获取审核列表失败');
      }

      return response.data!.records
          .map((record) => ProjectRecordItem(record))
          .toList();
    } catch (e) {
      Logger.error(
        'Failed to fetch audit records: $e',
        tag: 'RecordsRepository',
      );
      rethrow;
    }
  }

  bool _isCacheValidByKey(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheTimeout;
  }

  String _makeCacheKey(
    RecordType recordType, {
    int? userId,
    int? projectId,
  }) {
    final uid = userId?.toString() ?? 'u0';
    final pid = projectId?.toString() ?? 'p0';
    return '$uid@$pid#${recordType.name}';
  }

  @override
  void clearCache([RecordType? recordType]) {
    if (recordType != null) {
      // Remove all keys matching the recordType regardless of user/project
      final keysToRemove = _cache.keys.where((k) => k.endsWith('#${recordType.name}')).toList();
      for (final k in keysToRemove) {
        _cache.remove(k);
        _cacheTimestamps.remove(k);
      }
      Logger.info('Cleared cache for $recordType', tag: 'RecordsRepository');
    } else {
      _cache.clear();
      _cacheTimestamps.clear();
      Logger.info('Cleared all records cache', tag: 'RecordsRepository');
    }
  }

  @override
  void updateCache(RecordType recordType, List<RecordItem> records) {
    // Without user/project context, update cannot determine scope; do nothing.
    // Prefer using getRecords which writes cache with full key.
    Logger.info(
      'Updated cache for $recordType with ${records.length} records',
      tag: 'RecordsRepository',
    );
  }

  @override
  List<RecordItem>? getCachedRecords(
    RecordType recordType, {
    int? userId,
    int? projectId,
  }) {
    final key = _makeCacheKey(recordType, userId: userId, projectId: projectId);
  if (_isCacheValidByKey(key)) {
      return _cache[key];
    }
    return null;
  }

  @override
  bool hasCachedData(
    RecordType recordType, {
    int? userId,
    int? projectId,
  }) {
    final key = _makeCacheKey(recordType, userId: userId, projectId: projectId);
  return _isCacheValidByKey(key) && _cache.containsKey(key);
  }
}
