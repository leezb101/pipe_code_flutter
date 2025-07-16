import 'package:dio/dio.dart';
import '../../../utils/network_error_mapper.dart';

abstract class BaseApiService {
  final Dio dio;

  BaseApiService(this.dio);

  /// 处理网络错误，返回用户友好的错误信息
  /// 同时记录详细的开发日志
  String handleError(DioException error) {
    return NetworkErrorMapper.mapError(error);
  }

  /// 为特定接口处理错误（预留扩展空间）
  String handleErrorForEndpoint(DioException error, String endpoint) {
    return NetworkErrorMapper.mapErrorForEndpoint(error, endpoint);
  }
}