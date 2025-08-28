import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/models/acceptance/sign_in_info_vo.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/signin_api_service.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

class SigninApiServiceImpl extends BaseApiService implements SigninApiService {
  SigninApiServiceImpl(super.dio);

  @override
  Future<Result<SignInInfoVO>> getSigninDetail(int id) async {
    try {
      final response = await dio.get(
        '/signin/detail',
        queryParameters: {'id': id},
      );

      if (response.data != null) {
        return Result.safeFromJson(
          response.data,
          (json) => SignInInfoVO.fromJson(json as Map<String, dynamic>),
          'SignInInfoVO',
        );
      } else {
        throw Exception('获取入库信息失败，返回数据为空');
      }
    } on DioException catch (e) {
      Logger.api('获取入库信息失败 - ${e.type}: ${e.message}');
      rethrow;
    } catch (e) {
      throw Exception('数据解析失败或未知错误：${e.toString()}');
    }
  }
}
