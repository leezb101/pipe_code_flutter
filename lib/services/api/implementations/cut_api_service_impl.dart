/*
 * @Author: LeeZB
 * @Date: 2025-07-30 18:47:16
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 18:51:55
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/cut_api_service.dart';

import '../../../models/common/result.dart';
import '../../../models/cut/cut_request_vo.dart';

class CutApiServiceImpl extends BaseApiService implements CutApiService {
  CutApiServiceImpl(super.dio);

  @override
  Future<Result<String>> getTipsForCutting(CutRequestVo request) async {
    final response = await dio.post('/cut/check', data: request);
    if (response.statusCode == 200) {
      final result = Result.safeFromJson(
        response.data,
        (json) => json,
        'CutTips',
      );

      if (result.isSuccess && result.data != null) {
        return Result(code: 0, msg: 'success', data: result.data as String);
      } else {
        return Result(code: result.code, msg: result.msg, data: null);
      }
    } else {
      return Result(code: -1, msg: '获取切割提示失败，请重试', data: null);
    }
  }

  @override
  Future<Result<void>> doCut(CutRequestVo request) async {
    final response = await dio.post('/cut/scan', data: request);

    if (response.statusCode == 200) {
      final result = Result.safeFromJson(
        response.data,
        (json) => json,
        'DoCut',
      );

      if (result.isSuccess) {
        return Result(code: 0, msg: 'success');
      } else {
        return Result(code: result.code, msg: result.msg);
      }
    } else {
      return Result(code: -1, msg: '切割失败，请重试');
    }
  }
}
