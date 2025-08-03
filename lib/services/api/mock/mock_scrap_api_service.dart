/*
 * @Author: LeeZB
 * @Date: 2025-08-03 11:10:13
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 11:10:42
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/scrap/scrap_models.dart';
import 'package:pipe_code_flutter/services/api/interfaces/scrap_api_service.dart';

class MockScrapApiService implements ScrapApiService {
  @override
  Future<Result<void>> doScrap(ScrapDetailVO request) {
    // TODO: implement doScrap
    throw UnimplementedError();
  }

  @override
  Future<Result<ScrapDetailVO>> getScrapDetail(int id) {
    // TODO: implement getScrapDetail
    throw UnimplementedError();
  }
}
