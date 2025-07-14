import '../../../models/records/record_list_response.dart';
import '../../../models/records/record_type.dart';

abstract class RecordsApiService {
  Future<BusinessRecordListResponse> getBusinessRecords({
    required RecordType recordType,
    int? projectId,
    int? userId,
    int pageNum = 1,
    int pageSize = 10,
  });

  Future<ProjectRecordListResponse> getProjectInitRecords({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  });

  Future<ProjectRecordListResponse> getProjectAuditRecords({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  });
}