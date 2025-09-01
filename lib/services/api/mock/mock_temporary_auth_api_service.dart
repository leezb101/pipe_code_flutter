import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/services/api/interfaces/temporary_auth_api_service.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

class MockTemporaryAuthApiService implements TemporaryAuthApiService {
  @override
  Future<Result<void>> submitTemporaryLaborAuth({
    required String name,
    required String phone,
    required int interval,
  }) async {
    Logger.api('提交临时劳动授权 - 姓名: $name, 电话: $phone, 时间间隔: $interval');
    return Result(code: 0, msg: 'success', data: null);
  }

  @override
  Future<Result<void>> submitTemporarySubAuth({
    required String name,
    required String phone,
  }) async {
    Logger.api('提交临时辅助授权 - 姓名: $name, 电话: $phone');
    return Result(code: 0, msg: 'success', data: null);
  }
}
