/*
 * @Author: LeeZB
 * @Date: 2025-08-03 10:46:29
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 11:06:32
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/scrap/scrap_models.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/scrap_api_service.dart';

class ScrapApiServiceImpl extends BaseApiService implements ScrapApiService {
  ScrapApiServiceImpl(super.dio);

  @override
  Future<Result<ScrapDetailVO>> getScrapDetail(int id) async {
    try {
      final response = await dio.get(
        '/waste/detail',
        queryParameters: {'id': id},
      );

      // 使用 safeFromJson 直接转换成 ScrapDetailVO 对象
      return Result.safeFromJson<ScrapDetailVO>(
        response.data,
        (data) => ScrapDetailVO.fromJson(data as Map<String, dynamic>),
        'ScrapDetailVO',
      );
    } on DioException catch (e) {
      return Result<ScrapDetailVO>(
        code: e.response?.statusCode ?? 500,
        msg: handleError(e),
        data: null,
      );
    } catch (e) {
      return Result<ScrapDetailVO>(code: -1, msg: '获取报废详情失败: $e', data: null);
    }
  }

  @override
  Future<Result<void>> doScrap(ScrapDetailVO request) async {
    try {
      final response = await dio.post('/waste/add', data: request.toJson());

      // 对于操作类接口，通常只需要验证成功状态，不需要返回具体数据
      return Result.safeFromJson<void>(
        response.data,
        (data) {}, // void 类型直接返回 null
        'DoScrapResponse',
      );
    } on DioException catch (e) {
      return Result<void>(
        code: e.response?.statusCode ?? 500,
        msg: handleError(e),
        data: null,
      );
    } catch (e) {
      return Result<void>(code: -1, msg: '执行报废操作失败: $e', data: null);
    }
  }
}
