/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 19:35:35
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:dio/dio.dart';
import '../interfaces/project_api_service.dart';
import '../../../models/project/project_initiation.dart';
import '../../../models/common/result.dart';
import 'base_api_service.dart';

/// 项目API服务实现
/// 对接实际后端API
class ProjectApiServiceImpl extends BaseApiService
    implements ProjectApiService {
  ProjectApiServiceImpl(Dio dio) : super(dio);

  @override
  Future<Result<void>> addProject(ProjectInitiation project) async {
    try {
      final response = await dio.post('/project/add', data: project.toJson());
      return Result.safeFromJson(response.data, (json) => json, 'ProjectResponse');
    } on DioException catch (e) {
      return Result(
        code: e.response?.statusCode ?? 500,
        msg: handleError(e),
        data: null,
      );
    }
  }

  @override
  Future<Result<void>> updateProject(ProjectInitiation project) async {
    try {
      final response = await dio.post(
        '/project/update',
        data: project.toJson(),
      );
      return Result.safeFromJson(response.data, (json) => json, 'ProjectResponse');
    } on DioException catch (e) {
      return Result(
        code: e.response?.statusCode ?? 500,
        msg: handleError(e),
        data: null,
      );
    }
  }

  @override
  Future<Result<void>> commitProject(ProjectInitiation project) async {
    try {
      final response = await dio.post(
        '/project/commit',
        data: project.toJson(),
      );
      return Result.safeFromJson(response.data, (json) => json, 'ProjectResponse');
    } on DioException catch (e) {
      return Result(
        code: e.response?.statusCode ?? 500,
        msg: handleError(e),
        data: null,
      );
    }
  }

  @override
  Future<Result<void>> deleteProject(int id) async {
    try {
      final response = await dio.post('/project/delete', data: {'id': id});
      return Result.safeFromJson(response.data, (json) => json, 'ProjectResponse');
    } on DioException catch (e) {
      return Result(
        code: e.response?.statusCode ?? 500,
        msg: handleError(e),
        data: null,
      );
    }
  }

  @override
  Future<Result<List<ProjectListItem>>> getProjectList({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'pageNum': pageNum,
        'pageSize': pageSize,
      };

      if (projectName != null) {
        queryParams['projectName'] = projectName;
      }
      if (projectCode != null) {
        queryParams['projectCode'] = projectCode;
      }

      final response = await dio.get(
        '/project/init/list',
        queryParameters: queryParams,
      );
      final result = Result.safeFromJson(response.data, (json) => json, 'ProjectResponse');

      if (result.code == 0 && result.data != null) {
        final records = (result.data as Map)['records'] as List;
        final projects = records
            .map((json) => ProjectListItem.fromJson(json))
            .toList();
        return Result(code: result.code, msg: result.msg, data: projects);
      }

      return Result(code: result.code, msg: result.msg, data: null);
    } on DioException catch (e) {
      return Result(
        code: e.response?.statusCode ?? 500,
        msg: handleError(e),
        data: null,
      );
    }
  }

  @override
  Future<Result<ProjectDetail>> getProjectDetail(int id) async {
    try {
      final response = await dio.get(
        '/project/detail',
        queryParameters: {'id': id},
      );
      final result = Result.safeFromJson(response.data, (json) => json, 'ProjectResponse');

      if (result.code == 0 && result.data != null) {
        final detail = ProjectDetail.fromJson((result.data as Map)['project']);
        return Result(code: result.code, msg: result.msg, data: detail);
      }

      return Result(code: result.code, msg: result.msg, data: null);
    } on DioException catch (e) {
      return Result(
        code: e.response?.statusCode ?? 500,
        msg: handleError(e),
        data: null,
      );
    }
  }

  @override
  Future<Result<List<ProjectSupplier>>> getSupplierList() async {
    try {
      final response = await dio.get('/supplier/list');
      final result = Result.safeFromJson(response.data, (json) => json, 'ProjectResponse');

      if (result.code == 0 && result.data != null) {
        final suppliers = (result.data as List)
            .map((json) => ProjectSupplier.fromJson(json))
            .toList();
        return Result(code: result.code, msg: result.msg, data: suppliers);
      }

      return Result(code: result.code, msg: result.msg, data: null);
    } on DioException catch (e) {
      return Result(
        code: e.response?.statusCode ?? 500,
        msg: handleError(e),
        data: null,
      );
    }
  }

  @override
  Future<Result<List<MaterialType>>> getMaterialTypes() async {
    try {
      final response = await dio.get('/material/types');
      final result = Result.safeFromJson(response.data, (json) => json, 'ProjectResponse');

      if (result.code == 0 && result.data != null) {
        final types = (result.data as List)
            .map((json) => MaterialType.fromValue(json['value']))
            .toList();
        return Result(code: result.code, msg: result.msg, data: types);
      }

      return Result(code: result.code, msg: result.msg, data: null);
    } on DioException catch (e) {
      return Result(
        code: e.response?.statusCode ?? 500,
        msg: handleError(e),
        data: null,
      );
    }
  }

  @override
  Future<Result<List<ProjectUser>>> getUserList({
    String? roleType,
    String? orgCode,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (roleType != null) {
        queryParams['roleType'] = roleType;
      }
      if (orgCode != null) {
        queryParams['orgCode'] = orgCode;
      }

      final response = await dio.get(
        '/user/list',
        queryParameters: queryParams,
      );
      final result = Result.safeFromJson(response.data, (json) => json, 'ProjectResponse');

      if (result.code == 0 && result.data != null) {
        final users = (result.data as List)
            .map((json) => ProjectUser.fromJson(json))
            .toList();
        return Result(code: result.code, msg: result.msg, data: users);
      }

      return Result(code: result.code, msg: result.msg, data: null);
    } on DioException catch (e) {
      return Result(
        code: e.response?.statusCode ?? 500,
        msg: handleError(e),
        data: null,
      );
    }
  }
}
