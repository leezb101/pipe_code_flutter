import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/bloc/session/session_bloc.dart';
import 'package:pipe_code_flutter/bloc/session/session_state.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/cut/cut_records_item_vo.dart';
import 'package:pipe_code_flutter/models/cut/cut_statistic_vo.dart';
import 'package:pipe_code_flutter/models/records/paged_records.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/cut_records_api_service.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

class CutRecordsApiServiceImpl extends BaseApiService
    implements CutRecordsApiService {
  CutRecordsApiServiceImpl(super.dio);

  int? _getCurrentProjectId() {
    final sessionBloc = getIt<SessionBloc>();
    final sessionState = sessionBloc.state;

    if (sessionState is SessionProjectEstablished) {
      return sessionState.project.projectId;
    }
    return null;
  }

  @override
  Future<PagedRecords<CutRecordsItemVO>> fetchCutRecords({
    required int page,
    required int pageSize,
  }) async {
    try {
      final projectId = _getCurrentProjectId();
      if (projectId == null) {
        throw Exception('当前不在项目参与方会话中');
      }

      Logger.debug(
        'Fetching cut records: projectId=$projectId, page=$page, pageSize=$pageSize',
        tag: 'CutRecordsApiService',
      );

      final response = await dio.get(
        '/cut/source/cut/his/$projectId',
        queryParameters: {'pageNum': page, 'pageSize': pageSize},
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final records = (data['records'] as List)
          .map((e) => CutRecordsItemVO.fromJson(e as Map<String, dynamic>))
          .toList();

      final total = data['total'] as int? ?? 0;

      return PagedRecords(
        records: records,
        meta: PageMeta(total: total, size: pageSize, current: page),
      );
    } on DioException catch (e) {
      Logger.error(
        'Failed to fetch cut records: $e',
        tag: 'CutRecordsApiService',
      );
      throw Exception(handleError(e));
    } catch (e) {
      Logger.error(
        'Unexpected error fetching cut records: $e',
        tag: 'CutRecordsApiService',
      );
      throw Exception('获取截管记录失败');
    }
  }

  @override
  Future<Result<CutStatisticVo>> fetchCutStatistics() async {
    try {
      final projectId = _getCurrentProjectId();
      if (projectId == null) {
        throw Exception('当前不在项目参与方会话中');
      }

      Logger.debug(
        'Fetching cut statistics: projectId=$projectId',
        tag: 'CutRecordsApiService',
      );

      final response = await dio.get('/cut/statistic/$projectId');

      return Result.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CutStatisticVo.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      Logger.error(
        'Failed to fetch cut statistics: $e',
        tag: 'CutRecordsApiService',
      );
      throw Exception(handleError(e));
    } catch (e) {
      Logger.error(
        'Unexpected error fetching cut statistics: $e',
        tag: 'CutRecordsApiService',
      );
      throw Exception('获取截管统计失败');
    }
  }
}
