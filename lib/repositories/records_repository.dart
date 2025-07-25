import '../models/records/record_item.dart';
import '../models/records/record_type.dart';
import '../services/api/interfaces/records_api_service.dart';
import '../services/api/interfaces/todo_api_service.dart';
import '../utils/logger.dart';

class RecordsRepository {
  final RecordsApiService _apiService;
  final TodoApiService _todoApiService;
  final Map<RecordType, List<RecordItem>> _cache = {};
  final Map<RecordType, DateTime> _cacheTimestamps = {};
  final Duration _cacheTimeout = const Duration(minutes: 5);

  RecordsRepository(this._apiService, this._todoApiService);

  Future<List<RecordItem>> getRecords({
    required RecordType recordType,
    int? projectId,
    int? userId,
    int pageNum = 1,
    int pageSize = 10,
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _isCacheValid(recordType) && pageNum == 1) {
        Logger.info(
          'Returning cached records for $recordType',
          tag: 'RecordsRepository',
        );
        return _cache[recordType] ?? [];
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
      } else if (recordType == RecordType.inventory) {
        records = await _getProjectInitRecords(
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
        _cache[recordType] = records;
        _cacheTimestamps[recordType] = DateTime.now();
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

      if (pageNum == 1 && _cache.containsKey(recordType)) {
        Logger.info(
          'Returning cached records due to error',
          tag: 'RecordsRepository',
        );
        return _cache[recordType] ?? [];
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

  Future<List<RecordItem>> _getProjectInitRecords({
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    final response = await _apiService.getProjectInitRecords(
      pageNum: pageNum,
      pageSize: pageSize,
    );

    if (!response.isSuccess) {
      throw Exception(response.msg.isNotEmpty ? response.msg : '获取项目列表失败');
    }

    return response.data!.records
        .map((record) => ProjectRecordItem(record))
        .toList();
  }

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

  bool _isCacheValid(RecordType recordType) {
    final timestamp = _cacheTimestamps[recordType];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheTimeout;
  }

  void clearCache([RecordType? recordType]) {
    if (recordType != null) {
      _cache.remove(recordType);
      _cacheTimestamps.remove(recordType);
      Logger.info('Cleared cache for $recordType', tag: 'RecordsRepository');
    } else {
      _cache.clear();
      _cacheTimestamps.clear();
      Logger.info('Cleared all records cache', tag: 'RecordsRepository');
    }
  }

  void updateCache(RecordType recordType, List<RecordItem> records) {
    _cache[recordType] = records;
    _cacheTimestamps[recordType] = DateTime.now();
    Logger.info(
      'Updated cache for $recordType with ${records.length} records',
      tag: 'RecordsRepository',
    );
  }

  List<RecordItem>? getCachedRecords(RecordType recordType) {
    if (_isCacheValid(recordType)) {
      return _cache[recordType];
    }
    return null;
  }

  bool hasCachedData(RecordType recordType) {
    return _isCacheValid(recordType) && _cache.containsKey(recordType);
  }
}
