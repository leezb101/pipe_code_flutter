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
}
