/*
 * @Author: LeeZB
 * @Date: 2025-07-22 11:07:25
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 16:43:38
 * @copyright: Copyright © 2025 高新供水.
 */
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
      return Result<PageTodoTask>(
        code: e.response?.statusCode ?? -1,
        msg: e.message ?? '网络请求失败',
      );
    } catch (e) {
      return Result<PageTodoTask>(code: -1, msg: '获取待办列表失败: ${e.toString()}');
    }
  }

  @override
  Future<Result<PageTodoTask>> getWarehouseTodoList({
    int? pageNum,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (pageNum != null) queryParams['pageNum'] = pageNum;
      if (pageSize != null) queryParams['pageSize'] = pageSize;

      final response = await _dio.get(
        '/todo/warehouse/list',
        queryParameters: queryParams,
      );

      final result = Result<PageTodoTask>.fromJson(
        response.data,
        (data) => PageTodoTask.fromJson(data as Map<String, dynamic>),
      );

      return result;
    } on DioException catch (e) {
      return Result<PageTodoTask>(
        code: e.response?.statusCode ?? -1,
        msg: e.message ?? '网络请求失败',
      );
    } catch (e) {
      return Result<PageTodoTask>(code: -1, msg: '获取待办列表失败: ${e.toString()}');
    }
  }
}
