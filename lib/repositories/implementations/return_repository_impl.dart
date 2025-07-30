/*
 * @Author: LeeZB
 * @Date: 2025-07-30 16:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 16:05:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:pipe_code_flutter/models/return/do_return_req_vo.dart';
import 'package:pipe_code_flutter/models/return/return_detail_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/return_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/return_api_service.dart';
import 'package:pipe_code_flutter/utils/exceptions.dart';

class ReturnRepositoryImpl implements ReturnRepository {
  final ReturnApiService _apiService;

  ReturnRepositoryImpl(this._apiService);

  @override
  Future<ReturnDetailVo> getReturnDetail(int id) async {
    final result = await _apiService.getReturnDetail(id);

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw GetReturnDetailException(result.msg ?? '获取退库详情失败');
    }
  }

  @override
  Future<void> doReturn(DoReturnReqVo request) async {
    final result = await _apiService.doReturn(request);

    if (!result.isSuccess) {
      throw DoReturnException(result.msg ?? '执行退库操作失败');
    }
  }
}
