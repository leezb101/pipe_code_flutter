import 'package:pipe_code_flutter/models/common/result.dart';
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
}
