/*
 * @Author: LeeZB
 * @Date: 2025-07-24 18:54:12
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-24 19:34:43
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/signout/do_install_vo.dart';
import 'package:pipe_code_flutter/models/signout/do_signout_request_vo.dart';
import 'package:pipe_code_flutter/models/signout/signout_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';

abstract class SignoutApiService {
  /// 查看出库操作详情
  Future<Result<SignoutInfoVo>> getSignoutDetail(int id);

  /// 安装责任人发起出库
  Future<Result<void>> doSignout(DoSignoutRequestVo request);

  /// 出库方库管确认
  Future<Result<void>> auditSignout(CommonDoBusinessAuditVO request);
}
