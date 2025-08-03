/*
 * @Author: LeeZB
 * @Date: 2025-08-03 10:45:09
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 10:47:36
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/scrap/scrap_models.dart';

abstract class ScrapApiService {
  Future<Result<ScrapDetailVO>> getScrapDetail(int id);

  Future<Result<void>> doScrap(ScrapDetailVO request);
}
