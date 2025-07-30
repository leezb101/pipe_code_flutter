/*
 * @Author: LeeZB
 * @Date: 2025-07-30 10:00:26
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 10:20:22
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/return/do_return_req_vo.dart';
import 'package:pipe_code_flutter/models/return/return_detail_vo.dart';

abstract class ReturnApiService {
  /// 获取退货详情
  Future<Result<ReturnDetailVo>> getReturnDetail(int id);

  /// 发起退货
  Future<Result<void>> doReturn(DoReturnReqVo request);
}
