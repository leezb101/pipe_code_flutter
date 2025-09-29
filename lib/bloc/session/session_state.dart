/*
 * @Author: LeeZB
 * @Date: 2025-07-29 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-29 19:55:12
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import '../../models/user/wx_login_vo.dart';
import '../../models/user/current_user_on_project_role_info.dart';
import '../../models/project/project_info.dart';
import '../../models/project/project_general_display.dart';
import '../../models/menu/menu_config.dart';
import '../../models/records/record_item.dart';
import '../../services/menu_service.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];

  Object? get user => null;
}

/// 会话初始状态
class SessionInitial extends SessionState {
  const SessionInitial();
}

/// 会话加载中
class SessionLoading extends SessionState {
  const SessionLoading();
}

/// 需要身份选择（仓管员用户）
class SessionIdentitySelectionRequired extends SessionState {
  const SessionIdentitySelectionRequired({required this.wxLoginVO});

  final WxLoginVO wxLoginVO;

  @override
  List<Object> get props => [wxLoginVO];

  /// 检查是否为仓管员
  bool get isStorekeeper => wxLoginVO.storekeeper == true;
}

/// 需要项目选择（普通用户）
class SessionProjectSelectionRequired extends SessionState {
  const SessionProjectSelectionRequired({
    required this.wxLoginVO,
    required this.availableProjects,
  });

  final WxLoginVO wxLoginVO;
  final List<ProjectInfo> availableProjects;

  @override
  List<Object> get props => [wxLoginVO, availableProjects];

  /// 检查是否有可选项目
  bool get hasProjects => availableProjects.isNotEmpty;
}

/// 仓管员会话已建立
class SessionStorekeeperEstablished extends SessionState {
  const SessionStorekeeperEstablished({
    required this.wxLoginVO,
    this.isSwitching = false,
  });

  final WxLoginVO wxLoginVO;
  final bool isSwitching;

  @override
  List<Object> get props => [wxLoginVO, isSwitching];

  /// 获取用户信息
  @override
  WxLoginVO get user => wxLoginVO;

  SessionStorekeeperEstablished copyWith({
    WxLoginVO? wxLoginVO,
    bool? isSwitching,
  }) {
    return SessionStorekeeperEstablished(
      wxLoginVO: wxLoginVO ?? this.wxLoginVO,
      isSwitching: isSwitching ?? this.isSwitching,
    );
  }
}

/// 管理方会话已建立
class SessionAdminEstablished extends SessionState {
  const SessionAdminEstablished({
    required this.wxLoginVO,
    this.isSwitching = false,
  });

  final WxLoginVO wxLoginVO;
  final bool isSwitching;

  @override
  List<Object> get props => [wxLoginVO, isSwitching];

  /// 获取用户信息
  @override
  WxLoginVO get user => wxLoginVO;

  /// 是否为管理员
  bool get isAdmin => wxLoginVO.admin;

  /// 是否为老板
  bool get isBoss => wxLoginVO.boss;

  SessionAdminEstablished copyWith({WxLoginVO? wxLoginVO, bool? isSwitching}) {
    return SessionAdminEstablished(
      wxLoginVO: wxLoginVO ?? this.wxLoginVO,
      isSwitching: isSwitching ?? this.isSwitching,
    );
  }
}

/// 项目会话已建立
class SessionProjectEstablished extends SessionState {
  const SessionProjectEstablished({
    required this.wxLoginVO,
    required this.currentUserRoleInfo,
    this.pendingTodoRecord,
    this.isSwitching = false,
    this.projectDisplayInfo,
  });

  final WxLoginVO wxLoginVO;
  final CurrentUserOnProjectRoleInfo currentUserRoleInfo;
  final TodoRecordItem? pendingTodoRecord;
  final bool isSwitching;
  final ProjectGeneralDisplay? projectDisplayInfo;

  @override
  List<dynamic> get props => [
    wxLoginVO,
    currentUserRoleInfo,
    pendingTodoRecord,
    isSwitching,
    projectDisplayInfo,
  ];

  /// 获取当前项目信息
  ProjectInfo get project => ProjectInfo(
    projectId: currentUserRoleInfo.currentProjectId,
    projectRoleType: currentUserRoleInfo.projectRoleType,
    projectCode: currentUserRoleInfo.currentProjectCode,
    projectName: currentUserRoleInfo.currentProjectName,
    orgCode: currentUserRoleInfo.currentOrgCode,
    orgName: currentUserRoleInfo.currentOrgName,
  );

  /// 获取当前项目采购单位名称
  String get projectPurNm => currentUserRoleInfo.currentPurNm ?? '';

  /// 获取当前项目信息 (别名)
  ProjectInfo get currentProject => project;

  /// 获取可用项目列表
  List<ProjectInfo> get availableProjects => wxLoginVO.projectInfos;

  /// 获取当前用户信息
  @override
  WxLoginVO get user => wxLoginVO;

  /// 获取菜单项列表
  List<MenuItem> get menuItems {
    // 根据用户角色和过期状态动态生成菜单项
    return MenuService.getMenuItemsByRole(
      currentUserRoleInfo.projectRoleType,
      isExpired: currentUserRoleInfo.expire,
      supplyType: currentUserRoleInfo.currentProjectSupplyType,
    );
  }

  /// 检查当前用户是否已过期
  bool get isExpired => currentUserRoleInfo.expire;

  SessionProjectEstablished copyWith({
    WxLoginVO? wxLoginVO,
    CurrentUserOnProjectRoleInfo? currentUserRoleInfo,
    TodoRecordItem? pendingTodoRecord,
    bool clearPendingTodo = false,
    bool? isSwitching,
    ProjectGeneralDisplay? projectDisplayInfo,
  }) {
    return SessionProjectEstablished(
      wxLoginVO: wxLoginVO ?? this.wxLoginVO,
      currentUserRoleInfo: currentUserRoleInfo ?? this.currentUserRoleInfo,
      pendingTodoRecord: clearPendingTodo
          ? null
          : pendingTodoRecord ?? this.pendingTodoRecord,
      isSwitching: isSwitching ?? this.isSwitching,
      projectDisplayInfo: projectDisplayInfo ?? this.projectDisplayInfo,
    );
  }
}

/// 会话错误状态
class SessionError extends SessionState {
  const SessionError({required this.error});

  final String error;

  @override
  List<Object> get props => [error];

  /// 获取错误消息
  String get message => error;
}

/// 无项目可用
class SessionNoProjectsAvailable extends SessionState {
  const SessionNoProjectsAvailable({required this.wxLoginVO});

  final WxLoginVO wxLoginVO;

  @override
  List<Object> get props => [wxLoginVO];
}

/// 会话空状态
class SessionEmpty extends SessionState {
  const SessionEmpty();
}
