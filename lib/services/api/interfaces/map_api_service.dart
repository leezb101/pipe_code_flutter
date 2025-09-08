import 'package:pipe_code_flutter/models/common/result.dart';

abstract class MapApiService {
  Future<Result<List<dynamic>>> fetchMapWarehouses(
    double lat,
    double lng,
    double radius,
  );

  Future<Result<List<dynamic>>> fetchMapProjects(
    double lat,
    double lng,
    double radius,
  );

  Future<Result<Map<String, dynamic>>> fetchMapWarehouseDetail(int id);
}
