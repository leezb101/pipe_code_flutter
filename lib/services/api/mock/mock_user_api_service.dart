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

    final wxLoginVO = MockDataGenerator.generateWxLoginVO(customName: 'Current User');
    return wxLoginVO.toJson();
  }

  @override
  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> data,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      throw 'Failed to update user profile';
    }

    final wxLoginVO = MockDataGenerator.generateWxLoginVO(
      customName: data['name'] ?? 'Updated User',
      customPhone: data['phone'],
    );
    
    return wxLoginVO.toJson();
  }

  @override
  Future<List<dynamic>> getUserProjectRoles({
    required String userId,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      throw 'Failed to load user project roles';
    }

    // 生成模拟的项目信息数据
    final projectInfos = MockDataGenerator.generateProjectInfos(count: 3);
    return projectInfos.map((project) => project.toJson()).toList();
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
    final projects = MockDataGenerator.generateProjectInfos(count: 5);
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

    // 生成模拟的当前用户角色信息
    final currentUserRoleInfo = MockDataGenerator.generateCurrentUserOnProjectRoleInfo();
    return currentUserRoleInfo.toJson();
  }
}