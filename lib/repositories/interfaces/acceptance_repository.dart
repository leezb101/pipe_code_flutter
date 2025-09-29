/*
 * @Author: LeeZB
 * @Date: 2025-07-22 08:53:08
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-24 19:44:10
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/acceptance/acceptance_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/do_accept_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/do_accept_sign_in_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/jsf_accept_vo.dart';
import 'package:pipe_code_flutter/models/common/accept_user_info_vo.dart';
import 'package:pipe_code_flutter/models/common/warehouse_user_info_vo.dart';
import 'package:pipe_code_flutter/models/records/record_list_response.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/common/warehouse_vo.dart';

abstract class AcceptanceRepository {
  Future<Result<void>> submitAcceptance(DoAcceptVO request);
  Future<Result<void>> auditAcceptance(CommonDoBusinessAuditVO request);
  Future<Result<AcceptanceInfoVO>> getAcceptanceDetail(int id);
  Future<Result<RecordListResponse>> getAcceptanceList({
    int? projectId,
    int? userId,
    int pageNum = 1,
    int pageSize = 10,
  });
  Future<Result<void>> doAcceptanceSignIn(DoAcceptSignInVO request);
  Future<Result<AcceptUserInfoVO>> getAcceptanceUsers({required int projectId});
  Future<Result<WarehouseUserInfoVO>> getWarehouseUsers({
    required int warehouseId,
  });
  Future<Result<List<WarehouseVO>>> getWarehouseList();
  Future<Result<void>> submitJsfAcceptance(JsfAcceptVO request);
}
