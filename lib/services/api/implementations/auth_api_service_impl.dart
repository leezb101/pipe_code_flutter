import 'package:dio/dio.dart';
import '../interfaces/auth_api_service.dart';
import 'base_api_service.dart';

class AuthApiServiceImpl extends BaseApiService implements AuthApiService {
  AuthApiServiceImpl(super.dio);

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  @override
  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }
}