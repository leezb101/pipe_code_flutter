/*
 * @Author: LeeZB
 * @Date: 2025-07-24 19:22:20
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-24 19:33:16
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/signout/do_signout_request_vo.dart';
import 'package:pipe_code_flutter/models/signout/signout_info_vo.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/signout_api_service.dart';

class SignoutApiServiceImpl extends BaseApiService
    implements SignoutApiService {
  SignoutApiServiceImpl(super.dio);

  @override
  Future<Result<SignoutInfoVo>> getSignoutDetail(int id) async {
    try {
      final response = await dio.get(
        '/signout/detail',
        queryParameters: {'id': id},
      );
      if (response.statusCode == 200) {
        final result = Result.safeFromJson(
          response.data,
          (json) => json,
          'SignoutInfoVo',
        );
        if (result.isSuccess && result.data != null) {
          final signoutInfo = SignoutInfoVo.fromJson(
            result.data as Map<String, dynamic>,
          );
          return Result(code: 0, msg: 'success', data: signoutInfo);
        } else {
          return Result(
            code: result.code,
            msg: result.msg ?? '获取详失败败',
            data: null,
          );
        }
      } else {
        return Result(code: -1, msg: '获取详情失败，请重试', data: null);
      }
    } on DioException catch (e) {
      return Result(
        code: -1,
        msg: handleErrorForEndpoint(e, '/signout/detail'),
        data: null,
      );
    } catch (e) {
      return Result(code: -1, msg: '获取出库详情失败，请检查网络连接', data: null);
    }
  }

  @override
  Future<Result<void>> doSignout(DoSignoutRequestVo request) async {
    try {
      final response = await dio.post('/signout/do', data: request);

      if (response.statusCode == 200) {
        final result = Result.safeFromJson(
          response.data,
          (json) => json,
          'DoSignout',
        );
        if (result.isSuccess) {
          return Result(code: 0, msg: 'success', data: null);
        } else {
          return Result(
            code: result.code,
            msg: result.msg ?? '出库失败',
            data: null,
          );
        }
      } else {
        return Result(code: -1, msg: '提交失败，请重试');
      }
    } on DioException catch (e) {
      return Result(
        code: -1,
        msg: handleErrorForEndpoint(e, '/signout/do'),
        data: null,
      );
    } catch (e) {
      return Result(code: -1, msg: '出库失败，请检查网络连接', data: null);
    }
  }

  @override
  Future<Result<void>> auditSignout(CommonDoBusinessAuditVO request) async {
    try {
      final response = await dio.post('/signout/audit', data: request.toJson());

      if (response.statusCode == 200) {
        final result = Result.safeFromJson(
          response.data,
          (json) => json,
          'AuditSignoutResponse',
        );
        if (result.isSuccess) {
          return Result(code: 0, msg: 'success', data: null);
        } else {
          return Result(
            code: result.code,
            msg: result.msg ?? '确认提交失败',
            data: null,
          );
        }
      } else {
        return Result(code: -1, msg: '确认提交失败，请重试', data: null);
      }
    } on DioException catch (e) {
      return Result(
        code: -1,
        msg: handleErrorForEndpoint(e, '/signout/audit'),
        data: null,
      );
    } catch (e) {
      return Result(code: -1, msg: '确认提交失败，请检查网络连接', data: null);
    }
  }
}
