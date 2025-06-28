import 'package:dio/dio.dart';
import '../interfaces/user_api_service.dart';
import 'base_api_service.dart';

class UserApiServiceImpl extends BaseApiService implements UserApiService {
  UserApiServiceImpl(super.dio);

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await dio.get('/user/profile');
      return response.data;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.put('/user/profile', data: data);
      return response.data;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}