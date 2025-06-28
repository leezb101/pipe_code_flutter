import '../interfaces/auth_api_service.dart';
import '../../../utils/mock_data_generator.dart';

class MockAuthApiService implements AuthApiService {
  static const Duration _defaultDelay = Duration(milliseconds: 800);

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.2)) {
      throw 'Invalid username or password';
    }

    if (password.length < 3) {
      throw 'Password must be at least 3 characters';
    }

    return MockDataGenerator.generateAuthResponse(
      username: username,
    );
  }

  @override
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.15)) {
      throw 'Username already exists';
    }

    if (!email.contains('@')) {
      throw 'Invalid email format';
    }

    if (password.length < 6) {
      throw 'Password must be at least 6 characters';
    }

    return MockDataGenerator.generateAuthResponse(
      username: username,
      email: email,
    );
  }

  @override
  void setAuthToken(String token) {
    // Mock implementation - store token if needed
  }

  @override
  void clearAuthToken() {
    // Mock implementation - clear stored token
  }
}