/*
 * @Author: LeeZB
 * @Date: 2025-07-30 10:20:41
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 10:22:17
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/return/do_return_req_vo.dart';
import 'package:pipe_code_flutter/models/return/return_detail_vo.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/return_api_service.dart';

class ReturnApiServiceImpl extends BaseApiService implements ReturnApiService {
  ReturnApiServiceImpl(super.dio);

  @override
  Future<Result<ReturnDetailVo>> getReturnDetail(int id) async {
    final response = await dio.get(
      '/return/detail',
      queryParameters: {'id': id},
    );

    if (response.statusCode == 200) {
      final result = Result.safeFromJson(
        response.data,
        (json) => json,
        'ReturnDetailVo',
      );

      if (result.isSuccess && result.data != null) {
        final returnDetail = ReturnDetailVo.fromJson(
          result.data as Map<String, dynamic>,
        );
        return Result(code: 0, msg: 'success', data: returnDetail);
      } else {
        return Result(code: result.code, msg: result.msg, data: null);
      }
    } else {
      return Result(code: -1, msg: '获取退货详情失败，请重试', data: null);
    }
  }

  @override
  Future<Result<void>> doReturn(DoReturnReqVo request) async {
    final response = await dio.post('/return/do', data: request.toJson());

    if (response.statusCode == 200) {
      return Result(code: 0, msg: 'success', data: null);
    } else {
      return Result(code: -1, msg: '退货失败，请重试', data: null);
    }
  }
}
