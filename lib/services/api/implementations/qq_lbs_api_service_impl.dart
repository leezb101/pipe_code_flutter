import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/qq_lbs_api_service.dart';

class QQLbsApiServiceImpl extends BaseApiService implements QQLbsApiService {
  QQLbsApiServiceImpl(super.dio);

  @override
  Future<Result<String>> getKey() async {
    try {
      final response = await dio.get('/map/key');
      if (response.data != null) {
        return Result(
          code: 200,
          msg: '获取成功',
          data: response.data['data'] as String,
        );
      } else {
        return const Result(code: 500, msg: '获取失败', data: null);
      }
    } catch (e) {
      return const Result(code: 500, msg: '获取失败', data: null);
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getSig({
    required Map<String, dynamic> params,
  }) async {
    try {
      final response = await dio.post('/map/sign', data: params);
      if (response.data != null) {
        return Result(
          code: 200,
          msg: '获取成功',
          data: response.data as Map<String, dynamic>,
        );
      } else {
        return const Result(code: 500, msg: '获取失败', data: null);
      }
    } catch (e) {
      return const Result(code: 500, msg: '获取失败', data: null);
    }
  }
}
