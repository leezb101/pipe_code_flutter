abstract class UserApiService {
  Future<Map<String, dynamic>> getUserProfile();

  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> data,
  });

  /// 获取用户在所有项目中的角色
  Future<List<dynamic>> getUserProjectRoles({
    required String userId,
  });

  /// 获取用户可访问的项目列表
  Future<List<dynamic>> getUserAccessibleProjects({
    required String userId,
  });

  /// 更新用户在项目中的角色
  Future<Map<String, dynamic>> updateUserProjectRole({
    required String projectId,
    required Map<String, dynamic> roleData,
  });

  /// 获取用户项目上下文（包含当前项目和角色信息）
  Future<Map<String, dynamic>> getUserProjectContext({
    required String userId,
  });
}