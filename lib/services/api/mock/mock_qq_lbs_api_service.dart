import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/services/api/interfaces/qq_lbs_api_service.dart';

class MockQQLbsApiService implements QQLbsApiService {
  @override
  Future<Result<String>> getKey() {
    return Future.value(const Result(code: 200, msg: '获取成功', data: 'mock_key'));
  }

  @override
  Future<Result<Map<String, dynamic>>> getSig({
    required Map<String, dynamic> params,
  }) {
    return Future.value(
      const Result(
        code: 200,
        msg: '获取成功',
        data: {'s': 'mock_sig', 'k': 'sssss'},
      ),
    );
  }
}
