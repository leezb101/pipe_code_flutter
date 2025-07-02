/*
 * @Author: LeeZB
 * @Date: 2025-07-01 18:35:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-02 11:32:18
 * @copyright: Copyright © 2025 高新供水.
 */
import '../models/user/user.dart';
import '../models/user/user_project_role.dart';
import '../models/project/project.dart';
import '../services/api/interfaces/api_service_interface.dart';
import '../services/storage_service.dart';

class ProjectRepository {
  final ApiServiceInterface _apiService;
  final StorageService _storageService;

  // 项目相关的内存缓存
  UserProjectContext? _cachedProjectContext;
  DateTime? _lastProjectCacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  ProjectRepository({
    required ApiServiceInterface apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  /// 加载用户项目上下文
  Future<UserProjectContext?> loadUserProjectContext(String userId) async {
    try {
      // 检查项目上下文缓存是否有效
      if (_cachedProjectContext != null && _isProjectCacheValid()) {
        return _cachedProjectContext;
      }

      final contextString = _storageService.getString('user_project_context');
      if (contextString != null) {
        final contextData = Map<String, dynamic>.from(
          _storageService.decodeJsonString(contextString),
        );
        final context = UserProjectContext.fromJson(contextData);

        // 更新缓存
        _cachedProjectContext = context;
        _lastProjectCacheTime = DateTime.now();
        return context;
      }

      // 如果没有缓存的上下文，尝试从服务器加载
      return await _loadUserProjectContextFromApi(userId);
    } catch (e) {
      _clearProjectCache();
      rethrow;
    }
  }

  /// 保存用户项目上下文
  Future<void> saveUserProjectContext(UserProjectContext context) async {
    await _storageService.setString(
      'user_project_context',
      _storageService.encodeJsonString(context.toJson()),
    );
    await _storageService.setString(
      'current_project_id',
      context.currentProject.id,
    );

    // 更新缓存
    _cachedProjectContext = context;
    _lastProjectCacheTime = DateTime.now();
  }

  /// 切换到指定项目
  Future<UserProjectContext?> switchToProject(String projectId) async {
    try {
      final currentContext = _cachedProjectContext;
      if (currentContext == null) {
        throw Exception('未找到用户项目上下文，请先加载用户项目信息');
      }

      final targetRole = currentContext.getRoleInProject(projectId);
      if (targetRole == null) {
        throw Exception('您没有在该项目中的权限');
      }

      final targetProject = targetRole.project;
      if (targetProject == null) {
        throw Exception('未找到目标项目信息');
      }

      final newContext = currentContext.copyWith(
        currentProject: targetProject,
        currentRole: targetRole,
      );

      await saveUserProjectContext(newContext);
      return newContext;
    } catch (e) {
      rethrow;
    }
  }

  /// 刷新用户项目角色
  Future<UserProjectContext?> refreshUserProjectRoles(String userId) async {
    try {
      _clearProjectCache(); // 清除缓存强制重新加载
      return await _loadUserProjectContextFromApi(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// 更新用户在项目中的角色
  Future<void> updateUserProjectRole(
    String projectId,
    UserProjectRole role,
  ) async {
    try {
      await _apiService.user.updateUserProjectRole(
        projectId: projectId,
        roleData: role.toJson(),
      );

      // 清除缓存，强制在下次访问时重新加载
      _clearProjectCache();
    } catch (e) {
      rethrow;
    }
  }

  /// 获取用户在所有项目中的角色
  Future<List<UserProjectRole>> getUserProjectRoles(String userId) async {
    try {
      final response = await _apiService.user.getUserProjectRoles(
        userId: userId,
      );
      return (response)
          .map((data) => UserProjectRole.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 获取用户可访问的项目列表
  Future<List<Project>> getUserAccessibleProjects(String userId) async {
    try {
      final response = await _apiService.user.getUserAccessibleProjects(
        userId: userId,
      );
      return (response)
          .map((data) => Project.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// 清除项目数据
  Future<void> clearProjectData() async {
    await _storageService.remove('user_project_context');
    await _storageService.remove('current_project_id');
    _clearProjectCache();
  }

  /// 从 API 加载用户项目上下文
  Future<UserProjectContext?> _loadUserProjectContextFromApi(
    String userId,
  ) async {
    try {
      final projectRoles = await getUserProjectRoles(userId);
      if (projectRoles.isEmpty) {
        throw Exception('用户没有分配任何项目角色');
      }

      // 获取当前选中的项目 ID，如果没有则选择第一个
      final currentProjectId =
          _storageService.getString('current_project_id') ??
          projectRoles.first.projectId;

      final currentRole = projectRoles.firstWhere(
        (role) => role.projectId == currentProjectId && role.isCurrentlyValid,
        orElse: () => projectRoles.first,
      );

      final currentProject = currentRole.project;
      if (currentProject == null) {
        throw Exception('未找到当前项目信息');
      }

      // 需要用户信息来构建完整的上下文，但这里我们不从存储加载用户
      // 而是要求调用方提供用户信息
      throw Exception('需要用户信息来构建项目上下文，请先确保用户已登录');
    } catch (e) {
      rethrow;
    }
  }

  /// 使用用户信息构建项目上下文
  Future<UserProjectContext?> buildUserProjectContext(User user) async {
    try {
      final projectRoles = await getUserProjectRoles(user.id);
      if (projectRoles.isEmpty) {
        return null; // 用户没有项目分配，返回null而不是抛出异常
      }

      // 获取当前选中的项目 ID，如果没有则选择第一个
      final currentProjectId =
          _storageService.getString('current_project_id') ??
          projectRoles.first.projectId;

      final currentRole = projectRoles.firstWhere(
        (role) => role.projectId == currentProjectId && role.isCurrentlyValid,
        orElse: () => projectRoles.first,
      );

      final currentProject = currentRole.project;
      if (currentProject == null) {
        throw Exception('未找到当前项目信息');
      }

      final context = UserProjectContext(
        user: user,
        currentProject: currentProject,
        currentRole: currentRole,
        allProjectRoles: projectRoles,
      );

      await saveUserProjectContext(context);
      return context;
    } catch (e) {
      rethrow;
    }
  }

  /// 检查项目缓存是否仍然有效
  bool _isProjectCacheValid() {
    if (_lastProjectCacheTime == null) return false;
    return DateTime.now().difference(_lastProjectCacheTime!) < _cacheTimeout;
  }

  /// 清除项目缓存
  void _clearProjectCache() {
    _cachedProjectContext = null;
    _lastProjectCacheTime = null;
  }

  /// 手动清除项目缓存（用于调试或强制刷新）
  void clearCache() {
    _clearProjectCache();
  }

  /// 获取当前项目ID
  String? get currentProjectId =>
      _storageService.getString('current_project_id');
}
