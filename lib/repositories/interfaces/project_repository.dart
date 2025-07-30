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

abstract class ProjectRepository {
  Future<void> saveCurrentUserRoleInfo(
    CurrentUserOnProjectRoleInfo roleInfo,
  );
  Future<CurrentUserOnProjectRoleInfo?> loadCurrentUserRoleInfo();
  List<ProjectInfo> getUserProjects(WxLoginVO wxLoginVO);
  Future<bool> isFirstLogin();
  Future<String?> getLastSelectedProjectId();
  Future<void> saveLastSelectedProjectId(String projectId);
  Future<void> clearProjectData();
  void clearCache();
  String? get currentProjectId;
  CurrentUserOnProjectRoleInfo? get currentUserRoleInfo;
}
