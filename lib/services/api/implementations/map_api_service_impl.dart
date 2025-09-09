import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_base.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_material_statistic_item.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_statistic.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_user.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/map_api_service.dart';

class MapApiServiceImpl extends BaseApiService implements MapApiService {
  MapApiServiceImpl(super.dio);

  @override
  Future<Result<List>> fetchMapWarehouses(
    double lat,
    double lng,
    double radius,
  ) async {
    final response = await dio.post(
      '/warehouse/map/list',
      data: {'lat': lat, 'lng': lng, 'radius': radius},
    );
    if (response.data != null) {
      final result = Result.safeFromJson(
        response.data,
        (json) => (json as List).cast<Map<String, dynamic>>(),
        'List<Map<String, dynamic>>',
      );
      if (result.isSuccess && result.data != null) {
        return Result(code: 0, msg: 'success', data: result.data as List);
      } else {
        return Result(code: result.code, msg: result.msg, data: null);
      }
    } else {
      return Result(code: -1, msg: '获取仓库列表失败，请重试', data: null);
    }
  }

  @override
  Future<Result<List>> fetchMapProjects(
    double lat,
    double lng,
    double radius,
  ) async {
    final response = await dio.post(
      '/project/list/map',
      data: {'lat': lat, 'lng': lng, 'radius': radius},
    );
    if (response.data != null) {
      final result = Result.safeFromJson(
        response.data,
        (json) => (json as List).cast<Map<String, dynamic>>(),
        'List<Map<String, dynamic>>',
      );
      if (result.isSuccess && result.data != null) {
        return Result(code: 0, msg: 'success', data: result.data as List);
      } else {
        return Result(code: result.code, msg: result.msg, data: null);
      }
    } else {
      return Result(code: -1, msg: '获取项目列表失败，请重试', data: null);
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> fetchMapWarehouseDetail(int id) async {
    final response = await dio.get(
      '/warehouse/detail',
      queryParameters: {'id': id},
    );
    if (response.data != null) {
      final result = Result.safeFromJson(
        response.data,
        (json) => (json as Map<String, dynamic>),
        'Map<String, dynamic>',
      );
      if (result.isSuccess && result.data != null) {
        return Result(
          code: 0,
          msg: 'success',
          data: result.data as Map<String, dynamic>,
        );
      } else {
        return Result(code: result.code, msg: result.msg, data: null);
      }
    } else {
      return Result(code: -1, msg: '获取仓库详情失败，请重试', data: null);
    }
  }

  @override
  Future<Result<MapProjectBase>> fetchMapProjectBase(int id) async {
    final response = await dio.get('/project/statistic/$id/base');
    if (response.data != null) {
      final result = Result.safeFromJson(
        response.data,
        (json) => MapProjectBase.fromJson(json as Map<String, dynamic>),
        'MapProjectBase',
      );
      if (result.isSuccess && result.data != null) {
        return Result(
          code: 0,
          msg: 'success',
          data: result.data as MapProjectBase,
        );
      } else {
        return Result(code: result.code, msg: result.msg, data: null);
      }
    } else {
      return Result(code: -1, msg: '获取项目基础信息失败，请重试', data: null);
    }
  }

  @override
  Future<Result<MapProjectStatistic>> fetchMapProjectStatistic(int id) async {
    final response = await dio.get('/project/statistic/$id');
    if (response.data != null) {
      final result = Result.safeFromJson(
        response.data,
        (json) => MapProjectStatistic.fromJson(json as Map<String, dynamic>),
        'MapProjectStatistic',
      );
      if (result.isSuccess && result.data != null) {
        return Result(
          code: 0,
          msg: 'success',
          data: result.data as MapProjectStatistic,
        );
      } else {
        return Result(code: result.code, msg: result.msg, data: null);
      }
    } else {
      return Result(code: -1, msg: '获取项目统计信息失败，请重试', data: null);
    }
  }

  @override
  Future<Result<List<MapProjectMaterialStatisticItem>>>
  fetchMapProjectMaterialStatistics(int id) async {
    final response = await dio.get('/project/statistic/$id/detail');
    if (response.data != null) {
      final result = Result.safeFromJson(
        response.data,
        (json) => (json as List)
            .map(
              (item) => MapProjectMaterialStatisticItem.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),
        'List<MapProjectMaterialStatisticItem>',
      );
      if (result.isSuccess && result.data != null) {
        return Result(
          code: 0,
          msg: 'success',
          data: result.data as List<MapProjectMaterialStatisticItem>,
        );
      } else {
        return Result(code: result.code, msg: result.msg, data: null);
      }
    } else {
      return Result(code: -1, msg: '获取项目材料统计信息失败，请重试', data: null);
    }
  }

  @override
  Future<Result<List<MapProjectUser>>> fetchMapProjectUsers(
    int id,
    String code,
  ) async {
    final response = await dio.get('/project/statistic/$id/detail/$code');
    if (response.data != null) {
      final result = Result.safeFromJson(
        response.data,
        (json) => (json as List)
            .map(
              (item) => MapProjectUser.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        'List<MapProjectUser>',
      );
      if (result.isSuccess && result.data != null) {
        return Result(
          code: 0,
          msg: 'success',
          data: result.data as List<MapProjectUser>,
        );
      } else {
        return Result(code: result.code, msg: result.msg, data: null);
      }
    } else {
      return Result(code: -1, msg: '获取项目用户信息失败，请重试', data: null);
    }
  }
}
