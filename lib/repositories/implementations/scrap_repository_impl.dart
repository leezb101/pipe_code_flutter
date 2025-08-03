/*
 * @Author: LeeZB
 * @Date: 2025-08-03
 * @LastEditors: LeeZB
 * @LastEditTime: 2025-08-03
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/scrap/scrap_models.dart';
import 'package:pipe_code_flutter/services/api/interfaces/scrap_api_service.dart';
import 'package:pipe_code_flutter/repositories/interfaces/scrap_repository.dart';

class ScrapRepositoryImpl implements ScrapRepository {
  final ScrapApiService _scrapApiService;

  ScrapRepositoryImpl(this._scrapApiService);

  @override
  Future<Result<ScrapDetailVO>> getScrapDetail(int id) {
    return _scrapApiService.getScrapDetail(id);
  }

  @override
  Future<Result<void>> submitScrap(ScrapDetailVO request) {
    return _scrapApiService.doScrap(request);
  }
}
