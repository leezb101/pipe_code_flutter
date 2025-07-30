/*
 * @Author: LeeZB
 * @Date: 2025-07-27 11:26:37
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-28 15:56:10
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_apply_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_sign_in_vo.dart';

import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/dispatch/dispatch_detail_vo.dart';
import 'package:pipe_code_flutter/services/api/interfaces/dispatch_api_service.dart';
import 'package:pipe_code_flutter/repositories/interfaces/dispatch_repository.dart';

class DispatchRepositoryImpl implements DispatchRepository {
  final DispatchApiService _dispatchApiService;

  DispatchRepositoryImpl(this._dispatchApiService);

  @override
  Future<Result<DispatchDetailVo>> getDispatchDetail(int id) async {
    try {
      final result = await _dispatchApiService.getDispatchDetail(id);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '获取调拨详情失败，请检查网络连接', data: null);
    }
  }

  @override
  Future<Result<void>> doDispatch(DoDispatchApplyVo request) async {
    try {
      final result = await _dispatchApiService.doDispatch(request);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '提交调拨请求失败，请检查网络连接', data: null);
    }
  }

  @override
  Future<Result<void>> auditDispatch(CommonDoBusinessAuditVO request) async {
    try {
      final result = await _dispatchApiService.auditDispatch(request);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '审核确认调拨失败，请检查网络连接', data: null);
    }
  }

  @override
  Future<Result<void>> doDispatchSignin(DoDispatchSignInVo request) async {
    try {
      final result = await _dispatchApiService.doDispatchSignin(request);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '调拨后入库请求失败，请检查网络连接', data: null);
    }
  }
}
