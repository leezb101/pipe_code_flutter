import 'package:dio/dio.dart';
import '../../../models/records/record_list_response.dart';
import '../../../models/records/record_type.dart';
import '../../../models/common/result.dart';
import '../interfaces/records_api_service.dart';

class RealRecordsApiService implements RecordsApiService {
  final Dio _dio;

  RealRecordsApiService(this._dio);

  @override
  Future<Result<BusinessRecordPageData>> getBusinessRecords({
    required RecordType recordType,
    int? projectId,
    int? userId,
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        recordType.apiEndpoint,
        queryParameters: {
          if (projectId != null) 'projectId': projectId,
          if (userId != null) 'userId': userId,
          'pageNum': pageNum,
          'pageSize': pageSize,
        },
      );

      return Result.safeFromJson(
        response.data,
        (json) => BusinessRecordPageData.fromJson(json as Map<String, dynamic>),
        'BusinessRecordPageData',
      );
    } on DioException catch (e) {
      final errorMsg = _getErrorMessage(e);
      return Result(
        code: e.response?.statusCode ?? -1,
        msg: errorMsg,
        data: null,
      );
    }
  }

  @override
  Future<Result<ProjectRecordPageData>> getProjectInitRecords({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  }) async {
    try {
      final response = await _dio.get(
        '/project/init/list',
        queryParameters: {
          'pageNum': pageNum,
          'pageSize': pageSize,
          if (projectName != null && projectName.isNotEmpty) 'projectName': projectName,
          if (projectCode != null && projectCode.isNotEmpty) 'projectCode': projectCode,
        },
      );

      return Result.safeFromJson(
        response.data,
        (json) => ProjectRecordPageData.fromJson(json as Map<String, dynamic>),
        'ProjectRecordPageData',
      );
    } on DioException catch (e) {
      final errorMsg = _getErrorMessage(e);
      return Result(
        code: e.response?.statusCode ?? -1,
        msg: errorMsg,
        data: null,
      );
    }
  }

  @override
  Future<Result<ProjectRecordPageData>> getProjectAuditRecords({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  }) async {
    try {
      final response = await _dio.get(
        '/project/audit/list',
        queryParameters: {
          'pageNum': pageNum,
          'pageSize': pageSize,
          if (projectName != null && projectName.isNotEmpty) 'projectName': projectName,
          if (projectCode != null && projectCode.isNotEmpty) 'projectCode': projectCode,
        },
      );

      return Result.safeFromJson(
        response.data,
        (json) => ProjectRecordPageData.fromJson(json as Map<String, dynamic>),
        'ProjectRecordPageData',
      );
    } on DioException catch (e) {
      final errorMsg = _getErrorMessage(e);
      return Result(
        code: e.response?.statusCode ?? -1,
        msg: errorMsg,
        data: null,
      );
    }
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络连接超时，请检查网络设置';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return '登录已过期，请重新登录';
        } else if (statusCode == 403) {
          return '权限不足，无法访问此功能';
        } else if (statusCode == 404) {
          return '请求的资源不存在';
        } else if (statusCode == 500) {
          return '服务器内部错误，请稍后重试';
        } else {
          return '网络请求失败(${statusCode})';
        }
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      case DioExceptionType.badCertificate:
        return '证书验证失败';
      case DioExceptionType.unknown:
      default:
        return '网络请求失败: ${e.message}';
    }
  }
}