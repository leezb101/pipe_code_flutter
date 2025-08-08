import 'package:pipe_code_flutter/models/records/record_item.dart';
import 'package:pipe_code_flutter/models/records/record_type.dart';

abstract class RecordsRepository {
  Future<List<RecordItem>> getRecords({
    required RecordType recordType,
    int? projectId,
    int? userId,
    int pageNum = 1,
    int pageSize = 10,
    bool forceRefresh = false,
  });

  Future<List<RecordItem>> getProjectAuditRecords({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  });

  void clearCache([RecordType? recordType]);

  void updateCache(RecordType recordType, List<RecordItem> records);

  /// Get cached records scoped by account and project for a given type.
  List<RecordItem>? getCachedRecords(
    RecordType recordType, {
    int? userId,
    int? projectId,
  });

  /// Check if scoped cache exists and is valid for the given composite key.
  bool hasCachedData(
    RecordType recordType, {
    int? userId,
    int? projectId,
  });
}
