/*
 * @Author: LeeZB
 * @Date: 2025-07-27 11:16:06
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-27 11:21:56
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/dispatch/dispatch_detail_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_apply_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_sign_in_vo.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/dispatch_api_service.dart';

class DispatchApiServiceImpl extends BaseApiService
    implements DispatchApiService {
  DispatchApiServiceImpl(super.dio);

  @override
  Future<Result<DispatchDetailVo>> getDispatchDetail(int id) async {
    final response = await dio.get(
      '/dispatch/detail',
      queryParameters: {'id': id},
    );
    if (response.statusCode == 200) {
      final result = Result.safeFromJson(
        response.data,
        (json) => json,
        'DispatchDetailVo',
      );

      if (result.isSuccess && result.data != null) {
        final dispatchDetail = DispatchDetailVo.fromJson(
          result.data as Map<String, dynamic>,
        );
        return Result(code: result.code, data: dispatchDetail, msg: 'success');
      } else {
        return Result(
          code: result.code,
          msg: result.msg ?? '获取调拨详情失败',
          data: null,
        );
      }
    } else {
      return Result(code: -1, msg: '获取调拨详情失败，请重试', data: null);
    }
  }

  @override
  Future<Result<void>> doDispatch(DoDispatchApplyVo request) async {
    final response = await dio.post('/dispatch/do', data: request);

    if (response.statusCode == 200) {
      final result = Result.safeFromJson(
        response.data,
        (json) => json,
        'DoDispatch',
      );

      if (result.isSuccess) {
        return Result(code: result.code, msg: 'success');
      } else {
        return Result(code: result.code, msg: result.msg ?? '调拨失败');
      }
    } else {
      return Result(code: -1, msg: '调拨失败，请重试');
    }
  }

  @override
  Future<Result<void>> doDispatchSignin(DoDispatchSignInVo request) async {
    final response = await dio.post(
      '/dispatch/dispatch/receive',
      data: request,
    );
    if (response.statusCode == 200) {
      final result = Result.safeFromJson(
        response.data,
        (json) => json,
        'DoDispatchSignin',
      );

      if (result.isSuccess) {
        return Result(code: result.code, msg: 'success');
      } else {
        return Result(code: result.code, msg: result.msg ?? '签到失败');
      }
    } else {
      return Result(code: -1, msg: '签到失败，请重试');
    }
  }

  @override
  Future<Result<void>> auditDispatch(CommonDoBusinessAuditVO request) async {
    final response = await dio.post('/dispatch/dispatch/audit', data: request);
    if (response.statusCode == 200) {
      final result = Result.safeFromJson(
        response.data,
        (json) => json,
        'AuditDispatch',
      );

      if (result.isSuccess) {
        return Result(code: result.code, msg: 'success');
      } else {
        return Result(code: result.code, msg: result.msg ?? '审核失败');
      }
    } else {
      return Result(code: -1, msg: '审核失败，请重试');
    }
  }
}
