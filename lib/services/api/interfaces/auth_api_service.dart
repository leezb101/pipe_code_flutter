abstract class AuthApiService {
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  });

  void setAuthToken(String token);
  void clearAuthToken();
}