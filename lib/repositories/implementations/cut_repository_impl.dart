/*
 * @Author: LeeZB
 * @Date: 2025-07-30 19:02:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 19:02:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:pipe_code_flutter/models/cut/cut_request_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/cut_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/cut_api_service.dart';
import 'package:pipe_code_flutter/utils/exceptions.dart';

class CutRepositoryImpl implements CutRepository {
  final CutApiService _apiService;

  CutRepositoryImpl(this._apiService);

  @override
  Future<String> getTipsForCutting(CutRequestVo request) async {
    final result = await _apiService.getTipsForCutting(request);

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw GetCutTipsException(result.msg ?? '获取切割提示失败');
    }
  }

  @override
  Future<void> doCut(CutRequestVo request) async {
    final result = await _apiService.doCut(request);

    if (!result.isSuccess) {
      throw DoCutException(result.msg ?? '执行切割操作失败');
    }
  }
}
