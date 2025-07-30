/*
 * @Author: LeeZB
 * @Date: 2025-07-30 16:02:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 16:02:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:pipe_code_flutter/models/return/do_return_req_vo.dart';
import 'package:pipe_code_flutter/models/return/return_detail_vo.dart';
import 'package:pipe_code_flutter/utils/exceptions.dart';

/// 退库功能的数据仓库接口
///
/// 负责处理退库模块的数据操作和核心业务逻辑。
/// 调用者（如 BLoC）通过此接口与数据层交互。
/// 成功时返回所需数据模型，失败时抛出具体的业务异常。
abstract class ReturnRepository {
  /// 根据ID获取退库详情。
  ///
  /// 成功时返回 [ReturnDetailVo]。
  /// 失败时将抛出 [GetReturnDetailException]。
  Future<ReturnDetailVo> getReturnDetail(int id);

  /// 执行退库操作。
  ///
  /// 成功时正常返回。
  /// 失败时将抛出 [DoReturnException]。
  Future<void> doReturn(DoReturnReqVo request);
}
