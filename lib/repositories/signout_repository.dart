/*
 * @Author: LeeZB
 * @Date: 2025-07-24 19:39:02
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 11:25:48
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/common/warehouse_user_info_vo.dart';
import 'package:pipe_code_flutter/models/common/warehouse_vo.dart';
import 'package:pipe_code_flutter/models/signout/do_signout_request_vo.dart';
import 'package:pipe_code_flutter/models/signout/signout_info_vo.dart';
import 'package:pipe_code_flutter/services/api/interfaces/common_query_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/signout_api_service.dart';

class SignoutRepository {
  final SignoutApiService _signoutApiService;
  final CommonQueryApiService _commonQueryApiService;

  SignoutRepository(this._signoutApiService, this._commonQueryApiService);

  /// 获取出库详情
  Future<Result<SignoutInfoVo>> getSignoutDetail(int id) async {
    try {
      final result = await _signoutApiService.getSignoutDetail(id);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '获取出库详情失败，请检查网络连接', data: null);
    }
  }

  /// 提交出库请求
  Future<Result<void>> doSignout(DoSignoutRequestVo request) async {
    try {
      final result = await _signoutApiService.doSignout(request);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '提交出库请求失败，请检查网络连接', data: null);
    }
  }

  /// 出库确认
  Future<Result<void>> auditSignout(CommonDoBusinessAuditVO request) async {
    try {
      final result = await _signoutApiService.auditSignout(request);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '提交出库确认失败，请检查网络连接');
    }
  }

  /// 获取仓库管理员列表
  Future<Result<WarehouseUserInfoVO>> getWarehouseUsers(int warehouseId) async {
    try {
      final result = await _commonQueryApiService.getWarehouseUsers(
        warehouseId,
      );
      return result;
    } catch (e) {
      return Result(code: -1, msg: '获取仓库管理员列表失败，请检查网络连接');
    }
  }

  Future<Result<WarehouseVO>> getWarehouseInfoByMaterialId(
    int materialId,
  ) async {
    try {
      final result = await _commonQueryApiService.getWarehouseByMaterial(
        materialId,
      );
      return result;
    } catch (e) {
      return Result(code: -1, msg: '获取仓库信息失败，请检查网络连接');
    }
  }
}
