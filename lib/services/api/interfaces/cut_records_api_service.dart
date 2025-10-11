import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/cut/cut_records_item_vo.dart';
import 'package:pipe_code_flutter/models/cut/cut_statistic_vo.dart';
import 'package:pipe_code_flutter/models/records/paged_records.dart';

abstract class CutRecordsApiService {
  Future<Result<CutStatisticVo>> fetchCutStatistics();

  Future<PagedRecords<CutRecordsItemVO>> fetchCutRecords({
    required int page,
    required int pageSize,
  });
}
