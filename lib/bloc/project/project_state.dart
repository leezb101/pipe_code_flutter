/*
 * @Author: LeeZB
 * @Date: 2025-07-01 18:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-01 20:50:41
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import '../../models/user/user_project_role.dart';
import '../../models/project/project.dart';
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

/// 项目上下文已加载
class ProjectContextLoaded extends ProjectState {
  const ProjectContextLoaded({required this.context, required this.menuConfig});

  final UserProjectContext context;
  final RoleMenuConfig menuConfig;

  @override
  List<Object?> get props => [context, menuConfig];

  /// 获取当前项目
  Project get currentProject => context.currentProject;

  /// 获取当前角色
  UserProjectRole get currentRole => context.currentRole;

  /// 获取所有项目角色
  List<UserProjectRole> get allProjectRoles => context.allProjectRoles;

  /// 获取可用项目列表
  List<Project> get availableProjects => context.availableProjects;

  /// 获取当前角色的菜单项
  List<MenuItem> get menuItems => menuConfig.enabledMenuItems;

  /// 检查是否有指定菜单权限
  bool hasMenuPermission(String menuId) => menuConfig.hasMenuPermission(menuId);

  /// 检查是否可以切换到指定项目
  bool canSwitchToProject(String projectId) =>
      context.canSwitchToProject(projectId);

  /// 复制状态with新的上下文
  ProjectContextLoaded copyWith({
    UserProjectContext? context,
    RoleMenuConfig? menuConfig,
  }) {
    return ProjectContextLoaded(
      context: context ?? this.context,
      menuConfig: menuConfig ?? this.menuConfig,
    );
  }
}

/// 项目切换中
class ProjectSwitching extends ProjectState {
  const ProjectSwitching({required this.targetProjectId});

  final String targetProjectId;

  @override
  List<Object?> get props => [targetProjectId];
}

/// 项目数据为空（用户没有分配任何项目）
class ProjectEmpty extends ProjectState {
  const ProjectEmpty({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// 项目相关错误
class ProjectError extends ProjectState {
  const ProjectError({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}
