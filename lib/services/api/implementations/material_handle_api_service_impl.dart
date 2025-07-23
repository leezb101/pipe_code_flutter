/*
 * @Author: LeeZB
 * @Date: 2025-07-22 17:57:18
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-23 17:43:07
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import '../../../config/app_config.dart';
import '../interfaces/material_handle_api_service.dart';
import '../../../utils/logger.dart';
import '../../../models/material/material_info_for_business.dart';

class MaterialHandleApiServiceImpl implements MaterialHandleApiService {
  final Dio _dio;

  MaterialHandleApiServiceImpl(this._dio);

  @override
  Future<Result<MaterialInfoForBusiness>> scanSingleToQueryAll(
    String code,
  ) async {
    try {
      Logger.api('扫码识别请求开始 - code: $code');
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/scan/d',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: {'deliveryCode': code},
      );

      Logger.api('扫码识别响应成功 - Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        return Result.safeFromJson(response.data, (json) {
          return MaterialInfoForBusiness.fromJson(json as Map<String, dynamic>);
          // return (json as List<dynamic>)
          //     .map((e) => MaterialInfoBase.fromJson(e))
          //     .toList();
        }, 'MaterialInfoForBusiness');
      } else {
        return Result(code: response.statusCode ?? -1, msg: '扫码识别响应失败');
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

      return Result(code: -1, msg: '扫码识别失败，请稍后再试', data: null);
    }
  }

  @override
  Future<Result<MaterialInfoForBusiness>> scanBatchToQueryAll(
    List<String> codes,
  ) async {
    try {
      Logger.api('扫码识别请求开始 - codes: $codes');
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}/scan/multi',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: {'codes': codes},
      );

      Logger.api('扫码识别响应成功 - Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        return Result.safeFromJson(response.data, (json) {
          return MaterialInfoForBusiness.fromJson(json as Map<String, dynamic>);
          // return (json as List<dynamic>)
          //     .map((e) => MaterialInfoBase.fromJson(e))
          //     .toList();
        }, 'MaterialInfoBase');
      } else {
        return Result(code: response.statusCode ?? -1, msg: '扫码识别响应失败');
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

      return Result(code: -1, msg: '扫码识别失败，请稍后再试', data: null);
    }
  }
}
