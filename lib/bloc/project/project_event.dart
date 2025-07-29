/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-28 20:24:41
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import '../../models/user/wx_login_vo.dart';
import '../../models/user/current_user_on_project_role_info.dart';

/// 切换为项目参与方身份
class ProjectSwitchToParticipant extends ProjectEvent {
  final int pendingProjectId;

  const ProjectSwitchToParticipant(this.pendingProjectId);

  @override
  List<Object?> get props => [pendingProjectId];
}

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

/// 加载用户项目信息（基于WxLoginVO）
class ProjectLoadUserProjects extends ProjectEvent {
  const ProjectLoadUserProjects({required this.wxLoginVO});

  final WxLoginVO wxLoginVO;

  @override
  List<Object?> get props => [wxLoginVO];
}

/// 选择项目
class ProjectSelectProject extends ProjectEvent {
  const ProjectSelectProject({
    required this.projectId,
    this.isFromStoreKeeperMode,
  });

  final bool? isFromStoreKeeperMode;
  final int projectId;

  @override
  List<Object?> get props => [isFromStoreKeeperMode, projectId];
}

/// 设置当前项目角色信息
class ProjectSetCurrentRoleInfo extends ProjectEvent {
  const ProjectSetCurrentRoleInfo({
    required this.wxLoginVO,
    required this.currentUserRoleInfo,
  });

  final WxLoginVO wxLoginVO;
  final CurrentUserOnProjectRoleInfo currentUserRoleInfo;

  @override
  List<Object?> get props => [wxLoginVO, currentUserRoleInfo];
}

/// 清除项目数据
class ProjectClearData extends ProjectEvent {
  const ProjectClearData();
}
