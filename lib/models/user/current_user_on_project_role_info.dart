/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:15:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 18:14:18
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'user_role.dart';

part 'current_user_on_project_role_info.g.dart';

/// 当前用户在项目中的角色信息
/// 完全匹配API文档中的CurrentUserOnProjectRoleInfo结构
@JsonSerializable()
class CurrentUserOnProjectRoleInfo extends Equatable {
  const CurrentUserOnProjectRoleInfo({
    required this.currentProjectRoleType,
    required this.currentProjectId,
    required this.currentProjectCode,
    required this.currentProjectName,
    required this.currentOrgCode,
    required this.currentOrgName,
    this.currentProjectSuperiorUserId,
    this.currentProjectAuthorUserId,
    required this.expire,
  });

  /// 当前项目角色类型
  // @JsonKey(fromJson: UserRole.fromJson, toJson: _userRoleToJson)
  final UserRole currentProjectRoleType;

  // static int _userRoleToJson(UserRole role) => role.toJson();

  /// 当前项目ID
  final int currentProjectId;

  /// 当前项目代码
  final String currentProjectCode;

  /// 当前项目名称
  final String currentProjectName;

  /// 当前组织代码
  final String currentOrgCode;

  /// 当前组织名称
  final String currentOrgName;

  /// 当前选中项目上级授权用户userId，施工方角色存在此字段
  final int? currentProjectSuperiorUserId;

  /// 当前选中项目根授权用户userId，施工方角色存在此字段
  final int? currentProjectAuthorUserId;

  /// 是否过期，仅劳务角色涉及
  final bool expire;

  factory CurrentUserOnProjectRoleInfo.fromJson(Map<String, dynamic> json) =>
      _$CurrentUserOnProjectRoleInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentUserOnProjectRoleInfoToJson(this);

  CurrentUserOnProjectRoleInfo copyWith({
    UserRole? currentProjectRoleType,
    int? currentProjectId,
    String? currentProjectCode,
    String? currentProjectName,
    String? currentOrgCode,
    String? currentOrgName,
    int? currentProjectSuperiorUserId,
    int? currentProjectAuthorUserId,
    bool? expire,
  }) {
    return CurrentUserOnProjectRoleInfo(
      currentProjectRoleType:
          currentProjectRoleType ?? this.currentProjectRoleType,
      currentProjectId: currentProjectId ?? this.currentProjectId,
      currentProjectCode: currentProjectCode ?? this.currentProjectCode,
      currentProjectName: currentProjectName ?? this.currentProjectName,
      currentOrgCode: currentOrgCode ?? this.currentOrgCode,
      currentOrgName: currentOrgName ?? this.currentOrgName,
      currentProjectSuperiorUserId:
          currentProjectSuperiorUserId ?? this.currentProjectSuperiorUserId,
      currentProjectAuthorUserId:
          currentProjectAuthorUserId ?? this.currentProjectAuthorUserId,
      expire: expire ?? this.expire,
    );
  }

  @override
  List<Object?> get props => [
    currentProjectRoleType,
    currentProjectId,
    currentProjectCode,
    currentProjectName,
    currentOrgCode,
    currentOrgName,
    currentProjectSuperiorUserId,
    currentProjectAuthorUserId,
    expire,
  ];

  /// 获取项目显示信息
  String get projectDisplayName => currentProjectName;

  /// 获取组织显示信息
  String get orgDisplayName => currentOrgName;

  /// 判断是否为施工方角色（存在上级或根授权用户）
  bool get isConstructionRole =>
      currentProjectSuperiorUserId != null ||
      currentProjectAuthorUserId != null;
}
