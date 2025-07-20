import '../../../models/records/record_list_response.dart';
import '../../../models/records/record_type.dart';
import '../../../models/common/result.dart';

abstract class RecordsApiService {
  Future<Result<BusinessRecordPageData>> getBusinessRecords({
    required RecordType recordType,
    int? projectId,
    int? userId,
    int pageNum = 1,
    int pageSize = 10,
  });

  Future<Result<ProjectRecordPageData>> getProjectInitRecords({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  });

  Future<Result<ProjectRecordPageData>> getProjectAuditRecords({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  });
}