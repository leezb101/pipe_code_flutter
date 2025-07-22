import 'package:dio/dio.dart';
import '../interfaces/enum_api_service.dart';
import 'package:pipe_code_flutter/models/common/common_enum_vo.dart';
import '../../../models/common/org_models.dart'; // SimpleOrg, OrgType等
import 'package:pipe_code_flutter/models/common/result.dart';

class EnumApiServiceImpl implements EnumApiService {
  final Dio dio;

  EnumApiServiceImpl(this.dio);

  @override
  Future<Result<List<TodoType>>> getTodoTypes() async {
    final response = await dio.get('/enum/todo/type');
    return Result<List<TodoType>>.fromJson(
      response.data,
      (data) => (data as List).map((e) => TodoType.fromJson(e)).toList(),
    );
  }

  @override
  Future<Result<List<MaterialGroup>>> getMaterialGroups() async {
    final response = await dio.get('/enum/material/group');
    return Result<List<MaterialGroup>>.fromJson(
      response.data,
      (data) => (data as List).map((e) => MaterialGroup.fromJson(e)).toList(),
    );
  }

  @override
  Future<Result<List<MaterialType>>> getMaterialTypes() async {
    final response = await dio.get('/enum/material/type');
    return Result<List<MaterialType>>.fromJson(
      response.data,
      (data) => (data as List).map((e) => MaterialType.fromJson(e)).toList(),
    );
  }

  @override
  Future<Result<List<OrgType>>> getOrgTypes() async {
    final response = await dio.get('/enum/org/type');
    return Result<List<OrgType>>.fromJson(
      response.data,
      (data) => (data as List).map((e) => OrgType.fromJson(e)).toList(),
    );
  }

  @override
  Future<Result<List<SimpleOrg>>> getOrgs({String? name, int? type}) async {
    final response = await dio.get(
      '/enum/orgs',
      queryParameters: {
        if (name != null) 'name': name,
        if (type != null) 'type': type,
      },
    );
    return Result<List<SimpleOrg>>.fromJson(
      response.data,
      (data) => (data as List).map((e) => SimpleOrg.fromJson(e)).toList(),
    );
  }

  @override
  Future<Result<List<AcceptStatus>>> getAcceptStatuses() async {
    final response = await dio.get('/enum/accept/status');
    return Result<List<AcceptStatus>>.fromJson(
      response.data,
      (data) => (data as List).map((e) => AcceptStatus.fromJson(e)).toList(),
    );
  }

  @override
  Future<Result<List<BusinessType>>> getBusinessTypes() async {
    final response = await dio.get('/enum/business/type');
    return Result<List<BusinessType>>.fromJson(
      response.data,
      (data) => (data as List).map((e) => BusinessType.fromJson(e)).toList(),
    );
  }

  @override
  Future<Result<List<ProjectStatus>>> getProjectStatuses() async {
    final response = await dio.get('/enum/project/status');
    return Result<List<ProjectStatus>>.fromJson(
      response.data,
      (data) => (data as List).map((e) => ProjectStatus.fromJson(e)).toList(),
    );
  }

  @override
  Future<Result<List<ProjectSupplyType>>> getProjectSupplyTypes() async {
    final response = await dio.get('/enum/projectsupply/type');
    return Result<List<ProjectSupplyType>>.fromJson(
      response.data,
      (data) =>
          (data as List).map((e) => ProjectSupplyType.fromJson(e)).toList(),
    );
  }

  @override
  Future<Result<List<ProjectType>>> getProjectTypes() async {
    final response = await dio.get('/enum/project/type');
    return Result<List<ProjectType>>.fromJson(
      response.data,
      (data) => (data as List).map((e) => ProjectType.fromJson(e)).toList(),
    );
  }

  @override
  Future<Result<List<ReturnType>>> getReturnTypes() async {
    final response = await dio.get('/enum/return/type');
    return Result<List<ReturnType>>.fromJson(
      response.data,
      (data) => (data as List).map((e) => ReturnType.fromJson(e)).toList(),
    );
  }
}
