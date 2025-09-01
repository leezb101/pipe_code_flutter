import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/models/common/common_enum_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/temporary_auth_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/api_service_interface.dart';

class TemporaryAuthRepositoryImpl implements TemporaryAuthRepository {
  final ApiServiceInterface apiservice;

  TemporaryAuthRepositoryImpl(this.apiservice);

  @override
  Future<bool> submitTemporarySubAuth(String name, String phone) async {
    final service = apiservice.temporaryAuth;
    try {
      final result = await service.submitTemporarySubAuth(
        name: name,
        phone: phone,
      );
      if (result.code != 0) {
        throw Exception('提交授权失败：${result.msg}');
      }
      return true;
    } on DioException catch (e) {
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
          final statusCode = e.response?.statusCode;
          errorMessage = '服务器响应异常(状态码：$statusCode)';
          break;
        case DioExceptionType.cancel:
          errorMessage = '请求已取消';
          break;
        case DioExceptionType.unknown:
        default:
          errorMessage = '发生未知网络错误';
          break;
      }
      throw Exception(errorMessage);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> submitTemporaryLaborAuth(
    String name,
    String phone,
    Interval interval,
  ) async {
    final service = apiservice.temporaryAuth;
    try {
      final result = await service.submitTemporaryLaborAuth(
        name: name,
        phone: phone,
        interval: interval.value,
      );
      if (result.code != 0) {
        throw Exception('提交授权失败：${result.msg}');
      }
      return true;
    } on DioException catch (e) {
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
          final statusCode = e.response?.statusCode;
          errorMessage = '服务器响应异常(状态码：$statusCode)';
          break;
        case DioExceptionType.cancel:
          errorMessage = '请求已取消';
          break;
        case DioExceptionType.unknown:
        default:
          errorMessage = '发生未知网络错误';
          break;
      }
      throw Exception(errorMessage);
    } catch (e) {
      rethrow;
    }
  }
}
