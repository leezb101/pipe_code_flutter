/*
 * @Author: LeeZB
 * @Date: 2025-09-09 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-09 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';

/// 项目用户列表事件基类
abstract class ProjectUsersEvent extends Equatable {
  const ProjectUsersEvent();

  @override
  List<Object?> get props => [];
}

/// 加载项目用户列表
class LoadProjectUsers extends ProjectUsersEvent {
  final int projectId;
  final String code;
  final String orgName;

  const LoadProjectUsers({
    required this.projectId,
    required this.code,
    required this.orgName,
  });

  @override
  List<Object?> get props => [projectId, code, orgName];
}

/// 刷新项目用户列表
class RefreshProjectUsers extends ProjectUsersEvent {
  final int projectId;
  final String code;
  final String orgName;

  const RefreshProjectUsers({
    required this.projectId,
    required this.code,
    required this.orgName,
  });

  @override
  List<Object?> get props => [projectId, code, orgName];
}

/// 清除错误消息
class ClearUsersErrorMessage extends ProjectUsersEvent {
  const ClearUsersErrorMessage();
}
