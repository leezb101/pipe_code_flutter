import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/models/acceptance/sign_in_info_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/signin_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/api_service_interface.dart';

class SigninRepositoryImpl implements SigninRepository {
  final ApiServiceInterface apiService;

  SigninRepositoryImpl(this.apiService);

  @override
  Future<SignInInfoVO> getSigninDetail(int id) async {
    final service = apiService.signin;
    try {
      final result = await service.getSigninDetail(id);
      if (result.data == null) {
        throw Exception('获取入库详情失败，返回数据为空');
      }
      return result.data!;
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
