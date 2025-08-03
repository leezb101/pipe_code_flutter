/*
 * @Author: LeeZB
 * @Date: 2025-08-03
 * @LastEditors: LeeZB
 * @LastEditTime: 2025-08-03
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/scrap/scrap_models.dart';

abstract class ScrapRepository {
  /// 查询报废详情
  Future<Result<ScrapDetailVO>> getScrapDetail(int id);

  /// 提交报废
  Future<Result<void>> submitScrap(ScrapDetailVO request);
}
