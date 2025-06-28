import '../models/user/user.dart';
import '../services/api/interfaces/api_service_interface.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiServiceInterface _apiService;
  final StorageService _storageService;

  AuthRepository({
    required ApiServiceInterface apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiService.auth.login(
      username: username,
      password: password,
    );
    
    final token = response['token'] as String;
    final userData = response['user'] as Map<String, dynamic>;
    
    await _storageService.saveAuthToken(token);
    await _storageService.saveUserId(userData['id']);
    await _storageService.saveUsername(userData['username']);
    
    _apiService.auth.setAuthToken(token);
    
    return User.fromJson(userData);
  }

  Future<User> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _apiService.auth.register(
      username: username,
      email: email,
      password: password,
    );
    
    final token = response['token'] as String;
    final userData = response['user'] as Map<String, dynamic>;
    
    await _storageService.saveAuthToken(token);
    await _storageService.saveUserId(userData['id']);
    await _storageService.saveUsername(userData['username']);
    
    _apiService.auth.setAuthToken(token);
    
    return User.fromJson(userData);
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    _apiService.auth.clearAuthToken();
  }

  bool get isLoggedIn => _storageService.isLoggedIn;

  Future<void> initializeAuth() async {
    final token = _storageService.getAuthToken();
    if (token != null) {
      _apiService.auth.setAuthToken(token);
    }
  }
}