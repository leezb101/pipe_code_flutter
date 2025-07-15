/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:35:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 19:18:49
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import '../../models/user/wx_login_vo.dart';
import '../../models/user/current_user_on_project_role_info.dart';
import '../../models/project/project_info.dart';
import '../../models/user/user_role.dart';
import '../../models/user/user_role_menu_ext.dart';
import '../../models/menu/menu_config.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

/// 项目状态初始化
class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

/// 项目数据加载中
class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

/// 项目列表已加载
class ProjectListLoaded extends ProjectState {
  const ProjectListLoaded({
    required this.wxLoginVO,
    required this.availableProjects,
  });

  final WxLoginVO wxLoginVO;
  final List<ProjectInfo> availableProjects;

  @override
  List<Object?> get props => [wxLoginVO, availableProjects];
}

/// 项目角色信息已加载
class ProjectRoleInfoLoaded extends ProjectState {
  const ProjectRoleInfoLoaded({
    required this.wxLoginVO,
    required this.currentUserRoleInfo,
  });

  final WxLoginVO wxLoginVO;
  final CurrentUserOnProjectRoleInfo currentUserRoleInfo;

  @override
  List<Object?> get props => [wxLoginVO, currentUserRoleInfo];

  /// 获取当前项目信息
  ProjectInfo get currentProject => ProjectInfo(
    projectId: currentUserRoleInfo.currentProjectId,
    projectRoleType: currentUserRoleInfo.projectRoleType,
    projectCode: currentUserRoleInfo.currentProjectCode,
    projectName: currentUserRoleInfo.currentProjectName,
    orgCode: currentUserRoleInfo.currentOrgCode,
    orgName: currentUserRoleInfo.currentOrgName,
  );

  /// 获取当前用户角色
  UserRole get currentUserRole => currentUserRoleInfo.projectRoleType;

  /// 获取当前角色的菜单项
  List<MenuItem> get menuItems =>
      currentUserRole.getMenuItemsWithExpireState(currentUserRoleInfo.expire);

  /// 获取启用的菜单项
  List<MenuItem> get enabledMenuItems => currentUserRole.getEnabledMenuItems(
    isExpired: currentUserRoleInfo.expire,
  );

  /// 检查是否有指定菜单项
  bool hasMenuItem(String menuId) => currentUserRole.hasMenuItem(menuId);

  /// 获取可用的项目列表
  List<ProjectInfo> get availableProjects => wxLoginVO.projectInfos;

  /// 判断是否已过期
  bool get isExpired => currentUserRoleInfo.expire;
}

/// 项目错误状态
class ProjectError extends ProjectState {
  const ProjectError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// 项目数据为空
class ProjectEmpty extends ProjectState {
  const ProjectEmpty();
}
