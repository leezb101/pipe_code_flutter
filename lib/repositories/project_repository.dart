/*
 * @Author: LeeZB
 * @Date: 2025-07-10 00:10:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 18:36:54
 * @copyright: Copyright © 2025 高新供水.
 */
import '../models/user/wx_login_vo.dart';
import '../models/user/current_user_on_project_role_info.dart';
import '../models/project/project_info.dart';
import '../services/api/interfaces/api_service_interface.dart';
import '../services/storage_service.dart';

class ProjectRepository {
  final ApiServiceInterface _apiService;
  final StorageService _storageService;

  // 项目相关的内存缓存
  CurrentUserOnProjectRoleInfo? _cachedCurrentUserRoleInfo;
  DateTime? _lastProjectCacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  ProjectRepository({
    required ApiServiceInterface apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  /// 保存当前用户项目角色信息
  Future<void> saveCurrentUserRoleInfo(
    CurrentUserOnProjectRoleInfo roleInfo,
  ) async {
    try {
      await _storageService.setString(
        'current_user_role_info',
        _storageService.encodeJsonString(roleInfo.toJson()),
      );
      await _storageService.setString(
        'current_project_id',
        roleInfo.currentProjectId.toString(),
      );

      // 更新缓存
      _cachedCurrentUserRoleInfo = roleInfo;
      _lastProjectCacheTime = DateTime.now();
    } catch (e) {
      rethrow;
    }
  }

  /// 加载当前用户项目角色信息
  Future<CurrentUserOnProjectRoleInfo?> loadCurrentUserRoleInfo() async {
    try {
      // 检查缓存是否有效
      if (_cachedCurrentUserRoleInfo != null && _isProjectCacheValid()) {
        return _cachedCurrentUserRoleInfo;
      }

      final roleInfoString = _storageService.getString(
        'current_user_role_info',
      );
      if (roleInfoString != null) {
        final roleInfoData = Map<String, dynamic>.from(
          _storageService.decodeJsonString(roleInfoString),
        );
        final roleInfo = CurrentUserOnProjectRoleInfo.fromJson(roleInfoData);

        // 更新缓存
        _cachedCurrentUserRoleInfo = roleInfo;
        _lastProjectCacheTime = DateTime.now();
        return roleInfo;
      }

      return null;
    } catch (e) {
      _clearProjectCache();
      return null;
    }
  }

  /// 获取用户项目列表（从WxLoginVO中获取）
  List<ProjectInfo> getUserProjects(WxLoginVO wxLoginVO) {
    return wxLoginVO.projectInfos;
  }

  /// 根据项目ID查找项目信息
  // ProjectInfo? findProjectById(WxLoginVO wxLoginVO, int projectId) {
  //   try {
  //     return wxLoginVO.projectInfos.firstWhere(
  //       (project) =>
  //           project.projectId == 'WM${projectId.toString().padLeft(3, '0')}',
  //     );
  //   } catch (e) {
  //     return null;
  //   }
  // }

  /// 检查是否为首次登录
  Future<bool> isFirstLogin() async {
    final hasProjectSelection =
        _storageService.getString('current_project_id') != null;
    return !hasProjectSelection;
  }

  /// 获取最后选择的项目ID
  Future<String?> getLastSelectedProjectId() async {
    return _storageService.getString('current_project_id');
  }

  /// 保存最后选择的项目ID
  Future<void> saveLastSelectedProjectId(String projectId) async {
    await _storageService.setString('current_project_id', projectId);
  }

  /// 清除项目数据
  Future<void> clearProjectData() async {
    await _storageService.remove('current_user_role_info');
    await _storageService.remove('current_project_id');
    _clearProjectCache();
  }

  /// 检查项目缓存是否仍然有效
  bool _isProjectCacheValid() {
    if (_lastProjectCacheTime == null) return false;
    return DateTime.now().difference(_lastProjectCacheTime!) < _cacheTimeout;
  }

  /// 清除项目缓存
  void _clearProjectCache() {
    _cachedCurrentUserRoleInfo = null;
    _lastProjectCacheTime = null;
  }

  /// 手动清除项目缓存（用于调试或强制刷新）
  void clearCache() {
    _clearProjectCache();
  }

  /// 获取当前项目ID
  String? get currentProjectId =>
      _storageService.getString('current_project_id');

  /// 获取当前用户角色信息（从缓存）
  CurrentUserOnProjectRoleInfo? get currentUserRoleInfo =>
      _cachedCurrentUserRoleInfo;
}
