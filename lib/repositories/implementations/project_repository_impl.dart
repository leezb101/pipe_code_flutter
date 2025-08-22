/*
 * @Author: LeeZB
 * @Date: 2025-07-10 00:10:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 18:36:54
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/project/project_general_display.dart';
import 'package:pipe_code_flutter/models/user/wx_login_vo.dart';
import 'package:pipe_code_flutter/models/user/current_user_on_project_role_info.dart';
import 'package:pipe_code_flutter/models/project/project_info.dart';
import 'package:pipe_code_flutter/services/api/interfaces/api_service_interface.dart';
import 'package:pipe_code_flutter/services/api/interfaces/project_api_service.dart';
import 'package:pipe_code_flutter/services/storage_service.dart';
import 'package:pipe_code_flutter/repositories/interfaces/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final StorageService _storageService;
  final ApiServiceInterface _apiservice;

  // 项目相关的内存缓存
  CurrentUserOnProjectRoleInfo? _cachedCurrentUserRoleInfo;
  DateTime? _lastProjectCacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  ProjectRepositoryImpl({
    required ApiServiceInterface apiService,
    required StorageService storageService,
  }) : _storageService = storageService,
       _apiservice = apiService;

  @override
  Future<void> saveCurrentUserRoleInfo(
    CurrentUserOnProjectRoleInfo roleInfo,
  ) async {
    try {
      // 确保进行一次迁移
      await _storageService.migrateProjectRelatedKeys();

      // 使用用户隔离key保存
      await _storageService.setUserString(
        'current_user_role_info',
        _storageService.encodeJsonString(roleInfo.toJson()),
      );
      await _storageService.setUserString(
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

      // 优先读用户隔离key，不存在则尝试迁移后再读一次
      String? roleInfoString = _storageService.getUserString(
        'current_user_role_info',
      );
      if (roleInfoString == null) {
        await _storageService.migrateLegacyKeyToUserScoped(
          'current_user_role_info',
        );
        roleInfoString =
            _storageService.getUserString('current_user_role_info') ??
            _storageService.getString('current_user_role_info');
      }
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
        _storageService.getUserString('current_project_id') != null ||
        _storageService.getString('current_project_id') != null;
    return !hasProjectSelection;
  }

  @override
  Future<String?> getLastSelectedProjectId() async {
    final scoped = _storageService.getUserString('current_project_id');
    if (scoped != null) return scoped;
    await _storageService.migrateLegacyKeyToUserScoped('current_project_id');
    return _storageService.getUserString('current_project_id') ??
        _storageService.getString('current_project_id');
  }

  @override
  Future<void> saveLastSelectedProjectId(String projectId) async {
    await _storageService.setUserString('current_project_id', projectId);
  }

  @override
  Future<Result<ProjectGeneralDisplay>> getProjectDisplayInfosForHome() async {
    final result = await _apiservice.project.getProjectDisplayInfos();
    if (result.code == 0 && result.data != null) {
      return Result(code: 0, msg: '获取项目统计信息成功', data: result.data);
    } else {
      return Result(code: result.code, msg: '获取项目统计失败: ${result.msg}');
    }
  }

  @override
  Future<void> clearProjectData() async {
    // 清除用户隔离key
    await _storageService.removeUserKey('current_user_role_info');
    await _storageService.removeUserKey('current_project_id');
    // 兜底清除遗留全局key
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
      _storageService.getUserString('current_project_id') ??
      _storageService.getString('current_project_id');

  @override
  CurrentUserOnProjectRoleInfo? get currentUserRoleInfo =>
      _cachedCurrentUserRoleInfo;
}
