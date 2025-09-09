import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_base.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_material_statistic_item.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_statistic.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_user.dart';

abstract class MapApiService {
  /// 获取地图上的仓库列表
  Future<Result<List<dynamic>>> fetchMapWarehouses(
    double lat,
    double lng,
    double radius,
  );

  /// 获取地图上的项目列表
  Future<Result<List<dynamic>>> fetchMapProjects(
    double lat,
    double lng,
    double radius,
  );

  /// 获取单个仓库的详细信息
  Future<Result<Map<String, dynamic>>> fetchMapWarehouseDetail(int id);

  /// 获取地图单个项目的基础属性信息
  Future<Result<MapProjectBase>> fetchMapProjectBase(int id);

  /// 获取地图单个项目的操作统计信息
  Future<Result<MapProjectStatistic>> fetchMapProjectStatistic(int id);

  /// 获取地图单个项目的具体材料统计信息
  Future<Result<List<MapProjectMaterialStatisticItem>>>
  fetchMapProjectMaterialStatistics(int id);

  /// 获取地图单个项目对应公司的人员信息
  Future<Result<List<MapProjectUser>>> fetchMapProjectUsers(
    int id,
    String code,
  );
}
