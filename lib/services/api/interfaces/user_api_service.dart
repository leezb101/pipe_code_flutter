abstract class UserApiService {
  Future<Map<String, dynamic>> getUserProfile();

  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> data,
  });
}