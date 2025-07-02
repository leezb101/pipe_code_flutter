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

  @override
  Future<List<dynamic>> getUserProjectRoles({
    required String userId,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      throw 'Failed to load user project roles';
    }

    // 生成模拟的用户项目角色数据（直接返回JSON格式）
    final projectRoles = MockDataGenerator.generateUserProjectRolesJson(userId);
    return projectRoles;
  }

  @override
  Future<List<dynamic>> getUserAccessibleProjects({
    required String userId,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      throw 'Failed to load accessible projects';
    }

    // 生成模拟的项目数据
    final projects = MockDataGenerator.generateProjects();
    return projects.map((project) => project.toJson()).toList();
  }

  @override
  Future<Map<String, dynamic>> updateUserProjectRole({
    required String projectId,
    required Map<String, dynamic> roleData,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      throw 'Failed to update user project role';
    }

    // 返回更新后的角色数据
    return {
      'success': true,
      'message': 'User project role updated successfully',
      'data': roleData,
    };
  }

  @override
  Future<Map<String, dynamic>> getUserProjectContext({
    required String userId,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      throw 'Failed to load user project context';
    }

    // 生成模拟的用户项目上下文
    final context = MockDataGenerator.generateUserProjectContext(userId);
    return context.toJson();
  }
}