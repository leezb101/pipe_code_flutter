/*
 * @Author: LeeZB
 * @Date: 2025-07-20 15:35:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-20 15:34:11
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:dio/dio.dart';
import '../../../config/app_config.dart';
import '../../../models/material/scan_identification_response.dart';
import '../../../models/common/result.dart';
import '../interfaces/identification_api_service.dart';
import '../../../utils/logger.dart';

/// 真实扫码识别API服务实现
class IdentificationApiServiceImpl implements IdentificationApiService {
  final Dio _dio;

  IdentificationApiServiceImpl(this._dio);

  @override
  Future<Result<ScanIdentificationData>> scanMaterialIdentification(
    String code,
  ) async {
    try {
      Logger.api('扫码识别请求开始 - Code: $code');

      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/scan/single/$code',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      Logger.api('扫码识别响应成功 - Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        return Result.safeFromJson(
          response.data,
          (json) => ScanIdentificationData.fromJson(json as Map<String, dynamic>),
          'ScanIdentificationData',
        );
      } else {
        return Result(
          code: response.statusCode ?? -1,
          msg: 'API响应异常: ${response.statusCode}',
          data: null,
        );
      }
    } on DioException catch (e) {
      Logger.api('扫码识别请求失败 - ${e.type}: ${e.message}');

      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = '网络连接超时，请检查网络设置';
          break;
        case DioExceptionType.connectionError:
          errorMessage = '网络连接失败，请检查网络设置';
          break;
        case DioExceptionType.badResponse:
          errorMessage = '服务器响应异常 (${e.response?.statusCode})';
          break;
        default:
          errorMessage = '网络请求失败';
      }

      return Result(
        code: e.response?.statusCode ?? -1,
        msg: errorMessage,
        data: null,
      );
    } catch (e) {
      Logger.api('扫码识别请求失败 - 其他异常: ${e.toString()}');

      return Result(
        code: -1,
        msg: '扫码识别失败，请稍后再试',
        data: null,
      );
    }
  }
}
