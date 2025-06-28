import '../interfaces/user_api_service.dart';
import '../../../utils/mock_data_generator.dart';

class MockUserApiService implements UserApiService {
  static const Duration _defaultDelay = Duration(milliseconds: 800);

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      throw 'Failed to load user profile';
    }

    final user = MockDataGenerator.generateUser(id: 'current_user');
    return user.toJson();
  }

  @override
  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> data,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      throw 'Failed to update user profile';
    }

    final user = MockDataGenerator.generateUser(id: 'current_user');
    final updatedUser = user.copyWith(
      username: data['username'] ?? user.username,
      email: data['email'] ?? user.email,
      firstName: data['firstName'] ?? user.firstName,
      lastName: data['lastName'] ?? user.lastName,
      avatar: data['avatar'] ?? user.avatar,
    );
    
    return updatedUser.toJson();
  }
}