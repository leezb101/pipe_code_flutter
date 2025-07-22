import 'package:dio/dio.dart';
import '../../../models/common/result.dart';
import '../../../models/todo/page_todo_task.dart';
import '../interfaces/todo_api_service.dart';

class ApiTodoService implements TodoApiService {
  final Dio _dio;

  ApiTodoService(this._dio);

  @override
  Future<Result<PageTodoTask>> getTodoList({
    int? pageNum,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (pageNum != null) queryParams['pageNum'] = pageNum;
      if (pageSize != null) queryParams['pageSize'] = pageSize;

      final response = await _dio.get(
        '/todo/list',
        queryParameters: queryParams,
      );

      final result = Result<PageTodoTask>.fromJson(
        response.data,
        (data) => PageTodoTask.fromJson(data as Map<String, dynamic>),
      );

      return result;
    } on DioException catch (e) {
      return Result.failure(
        code: e.response?.statusCode ?? -1,
        message: e.message ?? '网络请求失败',
      );
    } catch (e) {
      return Result.failure(
        code: -1,
        message: '获取待办列表失败: ${e.toString()}',
      );
    }
  }
}