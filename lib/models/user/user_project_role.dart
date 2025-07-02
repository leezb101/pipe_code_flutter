/*
 * @Author: LeeZB
 * @Date: 2025-07-01 17:45:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-01 17:45:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../project/project.dart';
import 'user.dart';
import 'user_role.dart';

part 'user_project_role.g.dart';

/// 用户项目角色关联模型
/// 管理用户在特定项目中的角色分配
@JsonSerializable()
class UserProjectRole extends Equatable {
  const UserProjectRole({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.role,
    required this.assignedAt,
    this.assignedBy,
    this.validFrom,
    this.validUntil,
    this.isActive = true,
    this.user,
    this.project,
  });

  /// 关联记录唯一标识
  final String id;
  
  /// 用户ID
  @JsonKey(name: 'user_id')
  final String userId;
  
  /// 项目ID
  @JsonKey(name: 'project_id')
  final String projectId;
  
  /// 用户在该项目中的角色
  final UserRole role;
  
  /// 角色分配时间
  @JsonKey(name: 'assigned_at')
  final DateTime assignedAt;
  
  /// 分配者ID
  @JsonKey(name: 'assigned_by')
  final String? assignedBy;
  
  /// 角色生效开始时间
  @JsonKey(name: 'valid_from')
  final DateTime? validFrom;
  
  /// 角色生效结束时间
  @JsonKey(name: 'valid_until')
  final DateTime? validUntil;
  
  /// 是否激活状态
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  /// 关联的用户信息（可选，用于减少查询）
  final User? user;
  
  /// 关联的项目信息（可选，用于减少查询）
  final Project? project;

  factory UserProjectRole.fromJson(Map<String, dynamic> json) => 
      _$UserProjectRoleFromJson(json);

  Map<String, dynamic> toJson() => _$UserProjectRoleToJson(this);

  UserProjectRole copyWith({
    String? id,
    String? userId,
    String? projectId,
    UserRole? role,
    DateTime? assignedAt,
    String? assignedBy,
    DateTime? validFrom,
    DateTime? validUntil,
    bool? isActive,
    User? user,
    Project? project,
  }) {
    return UserProjectRole(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      role: role ?? this.role,
      assignedAt: assignedAt ?? this.assignedAt,
      assignedBy: assignedBy ?? this.assignedBy,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
      user: user ?? this.user,
      project: project ?? this.project,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    projectId,
    role,
    assignedAt,
    assignedBy,
    validFrom,
    validUntil,
    isActive,
    user,
    project,
  ];

  /// 判断当前角色是否在指定时间有效
  bool isValidAt(DateTime dateTime) {
    if (!isActive) return false;
    
    // 检查开始时间
    if (validFrom != null && dateTime.isBefore(validFrom!)) {
      return false;
    }
    
    // 检查结束时间
    if (validUntil != null && dateTime.isAfter(validUntil!)) {
      return false;
    }
    
    return true;
  }

  /// 判断当前角色是否现在有效
  bool get isCurrentlyValid => isValidAt(DateTime.now());

  /// 获取角色的显示信息
  String get roleDisplayInfo {
    final projectName = project?.name ?? projectId;
    return '${role.displayName} - $projectName';
  }

  /// 判断是否有管理权限
  bool get hasManagementPermission => role.isManagementRole;

  /// 判断是否有施工权限
  bool get hasConstructionPermission => role.isConstructionRole;

  /// 判断是否可以代理操作
  bool get canDelegate => role.canDelegate;

  /// 判断是否有质检权限
  bool get hasQualityCheckPermission => role.hasQualityCheckPermission;
}

/// 用户当前项目上下文
/// 包含用户当前选择的项目和在该项目中的角色
@JsonSerializable()
class UserProjectContext extends Equatable {
  const UserProjectContext({
    required this.user,
    required this.currentProject,
    required this.currentRole,
    required this.allProjectRoles,
  });

  /// 当前用户
  final User user;
  
  /// 当前选择的项目
  final Project currentProject;
  
  /// 用户在当前项目中的角色
  final UserProjectRole currentRole;
  
  /// 用户在所有项目中的角色列表
  final List<UserProjectRole> allProjectRoles;

  factory UserProjectContext.fromJson(Map<String, dynamic> json) => 
      _$UserProjectContextFromJson(json);

  Map<String, dynamic> toJson() => _$UserProjectContextToJson(this);

  UserProjectContext copyWith({
    User? user,
    Project? currentProject,
    UserProjectRole? currentRole,
    List<UserProjectRole>? allProjectRoles,
  }) {
    return UserProjectContext(
      user: user ?? this.user,
      currentProject: currentProject ?? this.currentProject,
      currentRole: currentRole ?? this.currentRole,
      allProjectRoles: allProjectRoles ?? this.allProjectRoles,
    );
  }

  @override
  List<Object?> get props => [
    user,
    currentProject,
    currentRole,
    allProjectRoles,
  ];

  /// 获取用户可以访问的所有项目
  List<Project> get availableProjects {
    return allProjectRoles
        .where((role) => role.isCurrentlyValid)
        .map((role) => role.project)
        .where((project) => project != null)
        .cast<Project>()
        .toList();
  }

  /// 获取用户在指定项目中的角色
  UserProjectRole? getRoleInProject(String projectId) {
    try {
      return allProjectRoles.firstWhere(
        (role) => role.projectId == projectId && role.isCurrentlyValid,
      );
    } catch (e) {
      return null;
    }
  }

  /// 判断用户是否可以切换到指定项目
  bool canSwitchToProject(String projectId) {
    return getRoleInProject(projectId) != null;
  }

  /// 获取当前用户的所有有效角色
  List<UserRole> get allValidRoles {
    return allProjectRoles
        .where((role) => role.isCurrentlyValid)
        .map((role) => role.role)
        .toSet()
        .toList();
  }
}