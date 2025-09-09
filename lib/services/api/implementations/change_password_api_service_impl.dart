import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';

import '../interfaces/chanage_password_api_service.dart';

class ChangePasswordApiServiceImpl extends BaseApiService
    implements ChangePasswordApiService {
  ChangePasswordApiServiceImpl(super.dio);

  @override
  Future<Result<Map<String, dynamic>>> getChangePasswordSmsCode() async {
    try {
      final response = await dio.get('/mu/sms');
      if (response.data != null) {
        final headers = response.headers;
        final smsCode = headers['sms_code']?.first;
        if (response.data['code'] == 0 && smsCode != null) {
          return Result(
            code: response.data['code'],
            data: {'smsCode': smsCode},
            msg: 'success',
          );
        } else {
          return Result(
            code: response.data['code'],
            msg: response.data['msg'] ?? '获取短信验证码失败',
          );
        }
      }
      throw Exception('服务错误，请稍后重试');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Result<void>> submitChangePassword(
    String password,
    String code,
    String smsCode,
  ) {
    try {
      return dio
          .post(
            '/mu/edit',
            data: {'password': password, 'code': code},
            options: Options(headers: {'sms_code': smsCode}),
          )
          .then((response) {
            if (response.data != null) {
              if (response.data['code'] == 0) {
                return Result<void>(code: response.data['code'], msg: '密码修改成功');
              } else {
                return Result<void>(
                  code: response.data['code'],
                  msg: response.data['msg'] ?? '密码修改失败',
                );
              }
            }
            throw Exception('服务错误，请稍后重试');
          });
    } catch (e) {
      rethrow;
    }
  }
}
