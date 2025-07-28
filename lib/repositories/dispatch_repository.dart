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

import '../models/common/result.dart';
import '../models/dispatch/dispatch_detail_vo.dart';
import '../services/api/interfaces/dispatch_api_service.dart';

class DispatchRepository {
  final DispatchApiService _dispatchApiService;

  DispatchRepository(this._dispatchApiService);

  /// 获取调拨详情
  Future<Result<DispatchDetailVo>> getDispatchDetail(int id) async {
    try {
      final result = await _dispatchApiService.getDispatchDetail(id);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '获取调拨详情失败，请检查网络连接', data: null);
    }
  }

  /// 提交调拨请求
  /// @param request 调拨请求对象
  /// @return 调拨结果
  Future<Result<void>> doDispatch(DoDispatchApplyVo request) async {
    try {
      final result = await _dispatchApiService.doDispatch(request);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '提交调拨请求失败，请检查网络连接', data: null);
    }
  }

  /// 审核确认调拨
  /// @param id 调拨ID
  /// @param pass 是否通过
  Future<Result<void>> auditDispatch(CommonDoBusinessAuditVO request) async {
    try {
      final result = await _dispatchApiService.auditDispatch(request);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '审核确认调拨失败，请检查网络连接', data: null);
    }
  }

  /// 调拨后请求入库
  Future<Result<void>> doDispatchSignin(DoDispatchSignInVo request) async {
    try {
      final result = await _dispatchApiService.doDispatchSignin(request);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '调拨后入库请求失败，请检查网络连接', data: null);
    }
  }
}
