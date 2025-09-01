import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/temporary_auth_api_service.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

class TemporaryAuthApiServiceImpl extends BaseApiService
    implements TemporaryAuthApiService {
  TemporaryAuthApiServiceImpl(super.dio);

  @override
  Future<Result<void>> submitTemporarySubAuth({
    required String name,
    required String phone,
  }) async {
    try {
      final response = await dio.post(
        '/b/authorize/do/sub',
        data: {'name': name, 'phone': phone},
      );
      if (response.data == null) {
        throw Exception('授权失败，服务器未返回数据');
      }
      return Result(
        code: response.data['code'],
        msg: response.data['msg'],
        data: null,
      );
    } on DioException catch (e) {
      Logger.api('提交临时授权失败 - ${e.type}: ${e.message}');
      rethrow;
    } catch (e) {
      throw Exception('数据解析失败或未知错误:${e.toString()}');
    }
  }

  @override
  Future<Result<void>> submitTemporaryLaborAuth({
    required String name,
    required String phone,
    required int interval,
  }) async {
    try {
      final response = await dio.post(
        '/b/authorize/do/temp',
        data: {'name': name, 'phone': phone, 'interval': interval},
      );
      if (response.data == null) {
        throw Exception('授权失败，服务器未返回数据');
      }
      return Result(
        code: response.data['code'],
        msg: response.data['msg'],
        data: null,
      );
    } on DioException catch (e) {
      Logger.api('提交临时授权失败 - ${e.type}: ${e.message}');
      rethrow;
    } catch (e) {
      throw Exception('数据解析失败或未知错误:${e.toString()}');
    }
  }
}
