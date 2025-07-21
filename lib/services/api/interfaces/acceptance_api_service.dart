/*
 * @Author: LeeZB
 * @Date: 2025-07-20 11:24:10
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-21 15:33:07
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/acceptance/acceptance_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/do_accept_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/do_accept_sign_in_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/accept_user_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/warehouse_user_info_vo.dart';
import 'package:pipe_code_flutter/models/records/record_list_response.dart';

abstract class AcceptanceApiService {
  /// 施工方验收单提交
  Future<Result<void>> submitAcceptance(DoAcceptVO request);

  /// 监理方、建设方、仓库验收确认
  Future<Result<void>> auditAcceptance(CommonDoBusinessAuditVO request);

  /// 获取验收详情
  Future<Result<AcceptanceInfoVO>> getAcceptanceDetail(int id);

  /// 获取验收列表
  Future<Result<RecordListResponse>> getAcceptanceList({
    int? projectId,
    int? userId,
    int? pageNum,
    int? pageSize,
  });

  /// 验收后入库
  Future<Result<void>> doAcceptanceSignIn(DoAcceptSignInVO request);

  /// 获取验收用户
  Future<Result<AcceptUserInfoVO>> getAcceptanceUsers({
    required int projectId,
    required int roleType,
  });

  /// 获取仓库用户
  Future<Result<WarehouseUserInfoVO>> getWarehouseUsers({
    required int warehouseId,
  });
}
