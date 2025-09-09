import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_base.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_material_statistic_item.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_statistic.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_user.dart';
import 'package:pipe_code_flutter/services/api/interfaces/map_api_service.dart';

class MockMapApiService implements MapApiService {
  @override
  Future<Result<List>> fetchMapWarehouses(
    double lat,
    double lng,
    double radius,
  ) {
    // TODO: implement fetchMapWarehouses
    throw UnimplementedError();
  }

  @override
  Future<Result<List>> fetchMapProjects(double lat, double lng, double radius) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, dynamic>>> fetchMapWarehouseDetail(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Result<MapProjectBase>> fetchMapProjectBase(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<MapProjectMaterialStatisticItem>>>
  fetchMapProjectMaterialStatistics(int id) {
    // TODO: implement fetchMapProjectMaterialStatistics
    throw UnimplementedError();
  }

  @override
  Future<Result<MapProjectStatistic>> fetchMapProjectStatistic(int id) {
    // TODO: implement fetchMapProjectStatistic
    throw UnimplementedError();
  }

  @override
  Future<Result<List<MapProjectUser>>> fetchMapProjectUsers(
    int id,
    String code,
  ) {
    // TODO: implement fetchMapProjectUsers
    throw UnimplementedError();
  }
}
