/*
 * @Author: LeeZB
 * @Date: 2025-07-10 00:10:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 18:36:54
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/user/wx_login_vo.dart';
import 'package:pipe_code_flutter/models/user/current_user_on_project_role_info.dart';
import 'package:pipe_code_flutter/models/project/project_info.dart';
import 'package:pipe_code_flutter/services/api/interfaces/api_service_interface.dart';
import 'package:pipe_code_flutter/services/storage_service.dart';
import 'package:pipe_code_flutter/repositories/interfaces/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ApiServiceInterface _apiService;
  final StorageService _storageService;

  // 项目相关的内存缓存
  CurrentUserOnProjectRoleInfo? _cachedCurrentUserRoleInfo;
  DateTime? _lastProjectCacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  ProjectRepositoryImpl({
    required ApiServiceInterface apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  @override
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

  @override
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

  @override
  List<ProjectInfo> getUserProjects(WxLoginVO wxLoginVO) {
    return wxLoginVO.projectInfos;
  }

  @override
  Future<bool> isFirstLogin() async {
    final hasProjectSelection =
        _storageService.getString('current_project_id') != null;
    return !hasProjectSelection;
  }

  @override
  Future<String?> getLastSelectedProjectId() async {
    return _storageService.getString('current_project_id');
  }

  @override
  Future<void> saveLastSelectedProjectId(String projectId) async {
    await _storageService.setString('current_project_id', projectId);
  }

  @override
  Future<void> clearProjectData() async {
    await _storageService.remove('current_user_role_info');
    await _storageService.remove('current_project_id');
    _clearProjectCache();
  }

  bool _isProjectCacheValid() {
    if (_lastProjectCacheTime == null) return false;
    return DateTime.now().difference(_lastProjectCacheTime!) < _cacheTimeout;
  }

  void _clearProjectCache() {
    _cachedCurrentUserRoleInfo = null;
    _lastProjectCacheTime = null;
  }

  @override
  void clearCache() {
    _clearProjectCache();
  }

  @override
  String? get currentProjectId =>
      _storageService.getString('current_project_id');

  @override
  CurrentUserOnProjectRoleInfo? get currentUserRoleInfo =>
      _cachedCurrentUserRoleInfo;
}
