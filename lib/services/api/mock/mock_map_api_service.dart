import 'package:pipe_code_flutter/models/common/result.dart';
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
}
