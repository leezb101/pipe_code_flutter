/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:15:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 19:16:29
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'user_role.dart';

part 'current_user_on_project_role_info.g.dart';

/// 供材类型枚举 0-甲供材，1-乙供材，2-甲乙混供
enum ProjectSupplyType {
  jiaGongCai(0),
  yiGongCai(1),
  jiaYiHunGong(2);

  final int value;
  const ProjectSupplyType(this.value);

  static ProjectSupplyType fromJson(int value) {
    return ProjectSupplyType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProjectSupplyType.jiaGongCai,
    );
  }

  int toJson() => value;
}

/// 当前用户在项目中的角色信息
/// 完全匹配API文档中的CurrentUserOnProjectRoleInfo结构
@JsonSerializable()
class CurrentUserOnProjectRoleInfo extends Equatable {
  const CurrentUserOnProjectRoleInfo({
    // required this.currentProjectRoleType,
    required this.projectRoleType,
    required this.currentProjectId,
    required this.currentProjectCode,
    required this.currentProjectName,
    required this.currentOrgCode,
    required this.currentOrgName,
    required this.currentProjectSupplyType,
    this.currentPurNm,
    this.currentProjectSuperiorUserId,
    this.currentProjectAuthorUserId,
    required this.expire,
  });

  /// 当前项目角色类型
  // @JsonKey(fromJson: UserRole.fromJson, toJson: _userRoleToJson)
  // final UserRole currentProjectRoleType;

  // static int _userRoleToJson(UserRole role) => role.toJson();

  final UserRole projectRoleType;

  /// 当前项目ID
  final int currentProjectId;

  /// 当前项目代码
  final String currentProjectCode;

  /// 当前项目名称
  final String currentProjectName;

  /// 当前组织代码
  @JsonKey(defaultValue: '')
  final String currentOrgCode;

  /// 当前组织名称
  @JsonKey(defaultValue: '')
  final String currentOrgName;

  /// 甲乙供材类型，0-甲供材，1-乙供材，2-甲乙混供
  @JsonKey(disallowNullValue: true)
  final ProjectSupplyType currentProjectSupplyType;

  /// 当前项目采购单位名称
  @JsonKey(defaultValue: '')
  final String? currentPurNm;

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
    UserRole? projectRoleType,
    int? currentProjectId,
    String? currentProjectCode,
    String? currentProjectName,
    String? currentOrgCode,
    String? currentOrgName,
    String? currentPurNm,
    ProjectSupplyType? currentProjectSupplyType,
    int? currentProjectSuperiorUserId,
    int? currentProjectAuthorUserId,
    bool? expire,
  }) {
    return CurrentUserOnProjectRoleInfo(
      // currentProjectRoleType:
      // currentProjectRoleType ?? this.currentProjectRoleType,
      projectRoleType: projectRoleType ?? this.projectRoleType,
      currentProjectId: currentProjectId ?? this.currentProjectId,
      currentProjectCode: currentProjectCode ?? this.currentProjectCode,
      currentProjectName: currentProjectName ?? this.currentProjectName,
      currentOrgCode: currentOrgCode ?? this.currentOrgCode,
      currentOrgName: currentOrgName ?? this.currentOrgName,
      currentProjectSupplyType:
          currentProjectSupplyType ?? this.currentProjectSupplyType,
      currentPurNm: currentPurNm ?? this.currentPurNm,
      currentProjectSuperiorUserId:
          currentProjectSuperiorUserId ?? this.currentProjectSuperiorUserId,
      currentProjectAuthorUserId:
          currentProjectAuthorUserId ?? this.currentProjectAuthorUserId,
      expire: expire ?? this.expire,
    );
  }

  @override
  List<Object?> get props => [
    // currentProjectRoleType,
    projectRoleType,
    currentProjectId,
    currentProjectCode,
    currentProjectName,
    currentOrgCode,
    currentOrgName,
    currentProjectSupplyType,
    currentPurNm,
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
