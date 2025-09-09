/*
 * @Author: LeeZB
 * @Date: 2025-09-09 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-09 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_user.dart';

/// 项目用户列表状态枚举
enum ProjectUsersStatus { initial, loading, loaded, error, refreshing }

/// 项目用户列表状态
class ProjectUsersState extends Equatable {
  const ProjectUsersState({
    this.status = ProjectUsersStatus.initial,
    this.users = const [],
    this.errorMessage,
    this.projectId,
    this.code,
    this.orgName,
  });

  /// 状态
  final ProjectUsersStatus status;

  /// 用户列表
  final List<MapProjectUser> users;

  /// 错误消息
  final String? errorMessage;

  /// 项目ID
  final int? projectId;

  /// 公司代码
  final String? code;

  /// 组织名称
  final String? orgName;

  /// 是否加载中
  bool get isLoading => status == ProjectUsersStatus.loading;

  /// 是否刷新中
  bool get isRefreshing => status == ProjectUsersStatus.refreshing;

  /// 是否已加载
  bool get isLoaded => status == ProjectUsersStatus.loaded;

  /// 是否有错误
  bool get hasError => status == ProjectUsersStatus.error;

  /// 是否有错误消息
  bool get hasErrorMessage => errorMessage != null && errorMessage!.isNotEmpty;

  /// 是否有用户数据
  bool get hasUsers => users.isNotEmpty;

  /// 复制状态
  ProjectUsersState copyWith({
    ProjectUsersStatus? status,
    List<MapProjectUser>? users,
    String? errorMessage,
    int? projectId,
    String? code,
    String? orgName,
  }) {
    return ProjectUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage,
      projectId: projectId ?? this.projectId,
      code: code ?? this.code,
      orgName: orgName ?? this.orgName,
    );
  }

  /// 清除错误消息
  ProjectUsersState clearError() {
    return copyWith(errorMessage: null);
  }

  @override
  List<Object?> get props => [
    status,
    users,
    errorMessage,
    projectId,
    code,
    orgName,
  ];
}
