/*
 * @Author: LeeZB
 * @Date: 2025-07-01 18:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-01 18:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import '../../models/user/user_project_role.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

/// 加载用户项目上下文
class ProjectLoadUserContext extends ProjectEvent {
  const ProjectLoadUserContext({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// 切换当前项目
class ProjectSwitchProject extends ProjectEvent {
  const ProjectSwitchProject({required this.projectId});

  final String projectId;

  @override
  List<Object?> get props => [projectId];
}

/// 设置项目上下文
class ProjectSetContext extends ProjectEvent {
  const ProjectSetContext({required this.context});

  final UserProjectContext context;

  @override
  List<Object?> get props => [context];
}

/// 刷新用户项目角色
class ProjectRefreshUserRoles extends ProjectEvent {
  const ProjectRefreshUserRoles({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// 更新用户在项目中的角色
class ProjectUpdateUserRole extends ProjectEvent {
  const ProjectUpdateUserRole({
    required this.projectId,
    required this.role,
  });

  final String projectId;
  final UserProjectRole role;

  @override
  List<Object?> get props => [projectId, role];
}

/// 清除项目数据
class ProjectClearData extends ProjectEvent {
  const ProjectClearData();
}