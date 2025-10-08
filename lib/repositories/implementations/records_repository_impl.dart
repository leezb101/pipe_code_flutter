import 'package:pipe_code_flutter/models/records/record_item.dart';
import 'package:pipe_code_flutter/models/records/record_type.dart';
import 'package:pipe_code_flutter/services/api/interfaces/records_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/todo_api_service.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/repositories/interfaces/records_repository.dart';
import 'package:pipe_code_flutter/models/records/paged_records.dart';
import 'package:get_it/get_it.dart';
import '../../services/tracing/improved_tracing_manager.dart';

class RecordsRepositoryImpl implements RecordsRepository {
  final RecordsApiService _apiService;
  final TodoApiService _todoApiService;
  // Composite cache scoped by userId + projectId + recordType
  final Map<String, List<RecordItem>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, PageMeta> _cacheMeta = {};
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
    final res = await getRecordsWithMeta(
      recordType: recordType,
      projectId: projectId,
      userId: userId,
      pageNum: pageNum,
      pageSize: pageSize,
      forceRefresh: forceRefresh,
    );
    return res.records;
  }

  @override
  Future<PagedRecords<RecordItem>> getRecordsWithMeta({
    required RecordType recordType,
    int? projectId,
    int? userId,
    int pageNum = 1,
    int pageSize = 10,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = _makeCacheKey(
        recordType,
        userId: userId,
        projectId: projectId,
      );
      if (!forceRefresh && _isCacheValidByKey(cacheKey) && pageNum == 1) {
        Logger.info(
          'Returning cached records for $recordType',
          tag: 'RecordsRepository',
        );
        final cached = _cache[cacheKey] ?? [];
        // use cached meta if present; otherwise synthesize minimal meta
        final meta =
            _cacheMeta[cacheKey] ??
            PageMeta(total: cached.length, size: pageSize, current: 1);
        return PagedRecords(records: cached, meta: meta);
      }

      Logger.info(
        'Fetching records for type: $recordType, page: $pageNum',
        tag: 'RecordsRepository',
      );

      List<RecordItem> records;
      PageMeta meta;

      if (recordType == RecordType.todo) {
        final page = await _getTodoRecords(
          projectId: projectId,
          userId: userId,
          pageNum: pageNum,
          pageSize: pageSize,
        );
        records = page.records;
        meta = page.meta;
      } else if (recordType == RecordType.warehouseTodo ||
          recordType == RecordType.siteTodo) {
        final page = await _getWarehouseTodoRecords(
          pageNum: pageNum,
          pageSize: pageSize,
        );
        records = page.records;
        meta = page.meta;
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

        records = response.data!.records.map((record) {
          if (recordType == RecordType.signoutWarehouse ||
              recordType == RecordType.signinWarehouse) {
            return StorekeeperBusinessRecordItem(record, record.materialNum);
          }
          return BusinessRecordItem(record);
        }).toList();
        meta = PageMeta(
          total: response.data!.total,
          size: response.data!.size,
          current: response.data!.current,
          // pages may exist in other models; compute if absent
        );
      }

      if (pageNum == 1) {
        _cache[cacheKey] = records;
        _cacheTimestamps[cacheKey] = DateTime.now();
        _cacheMeta[cacheKey] = meta;
      }

      Logger.info(
        'Successfully fetched ${records.length} records for $recordType',
        tag: 'RecordsRepository',
      );
      return PagedRecords(records: records, meta: meta);
    } catch (e) {
      Logger.error(
        'Failed to fetch records for $recordType: $e',
        tag: 'RecordsRepository',
      );

      final cacheKey = _makeCacheKey(
        recordType,
        userId: userId,
        projectId: projectId,
      );
      if (pageNum == 1 && _cache.containsKey(cacheKey)) {
        Logger.info(
          'Returning cached records due to error',
          tag: 'RecordsRepository',
        );
        final cached = _cache[cacheKey] ?? [];
        final meta =
            _cacheMeta[cacheKey] ??
            PageMeta(total: cached.length, size: pageSize, current: 1);
        return PagedRecords(records: cached, meta: meta);
      }

      rethrow;
    }
  }

  Future<PagedRecords<RecordItem>> _getTodoRecords({
    int? projectId,
    int? userId,
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    final response = await GetIt.instance<ImprovedTracingManager>()
        .scopeActionWithTitle('加载待办列表', () async {
          return await _todoApiService.getTodoList(
            pageNum: pageNum,
            pageSize: pageSize,
          );
        });

    if (!response.isSuccess) {
      throw Exception(response.msg.isNotEmpty ? response.msg : '获取待办任务失败');
    }

    final page = response.data!;
    final items = page.records.map((todo) => TodoRecordItem(todo)).toList();
    return PagedRecords(
      records: items,
      meta: PageMeta(total: page.total, size: page.size, current: page.current),
    );
  }

  Future<PagedRecords<RecordItem>> _getWarehouseTodoRecords({
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

    final page = response.data!;
    final items = page.records.map((todo) => TodoRecordItem(todo)).toList();
    return PagedRecords(
      records: items,
      meta: PageMeta(total: page.total, size: page.size, current: page.current),
    );
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

  String _makeCacheKey(RecordType recordType, {int? userId, int? projectId}) {
    final uid = userId?.toString() ?? 'u0';
    final pid = projectId?.toString() ?? 'p0';
    return '$uid@$pid#${recordType.name}';
  }

  @override
  void clearCache([RecordType? recordType]) {
    if (recordType != null) {
      // Remove all keys matching the recordType regardless of user/project
      final keysToRemove = _cache.keys
          .where((k) => k.endsWith('#${recordType.name}'))
          .toList();
      for (final k in keysToRemove) {
        _cache.remove(k);
        _cacheTimestamps.remove(k);
        _cacheMeta.remove(k);
      }
      Logger.info('Cleared cache for $recordType', tag: 'RecordsRepository');
    } else {
      _cache.clear();
      _cacheTimestamps.clear();
      _cacheMeta.clear();
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
  bool hasCachedData(RecordType recordType, {int? userId, int? projectId}) {
    final key = _makeCacheKey(recordType, userId: userId, projectId: projectId);
    return _isCacheValidByKey(key) && _cache.containsKey(key);
  }

  @override
  PageMeta? getCachedMeta(
    RecordType recordType, {
    int? userId,
    int? projectId,
  }) {
    final key = _makeCacheKey(recordType, userId: userId, projectId: projectId);
    if (_isCacheValidByKey(key)) {
      return _cacheMeta[key];
    }
    return null;
  }
}
