/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 18:25:44
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../user/user_role.dart';

part 'project_info.g.dart';

/// 项目信息模型
/// 完全匹配API文档中的ProjectInfo结构
@JsonSerializable()
class ProjectInfo extends Equatable {
  const ProjectInfo({
    required this.projectRoleType,
    required this.projectCode,
    required this.projectName,
    required this.projectId,
    this.orgCode,
    this.orgName,
    this.startTime,
    this.endTime,
  });

  /// 项目角色类型
  // @JsonKey(fromJson: UserRole.fromJson, toJson: _userRoleToJson)
  final UserRole projectRoleType;

  // static int _userRoleToJson(UserRole role) => role.toJson();

  /// 项目ID
  final int projectId;

  /// 项目代码
  final String projectCode;

  /// 项目名称
  final String projectName;

  /// 组织代码
  final String? orgCode;

  /// 组织名称
  final String? orgName;

  /// 角色项目授权起始时间
  final DateTime? startTime;

  /// 角色项目授权终止时间
  final DateTime? endTime;

  factory ProjectInfo.fromJson(Map<String, dynamic> json) =>
      _$ProjectInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectInfoToJson(this);

  ProjectInfo copyWith({
    UserRole? projectRoleType,
    int? projectId,
    String? projectCode,
    String? projectName,
    String? orgCode,
    String? orgName,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return ProjectInfo(
      projectId: projectId ?? this.projectId,
      projectRoleType: projectRoleType ?? this.projectRoleType,
      projectCode: projectCode ?? this.projectCode,
      projectName: projectName ?? this.projectName,
      orgCode: orgCode ?? this.orgCode,
      orgName: orgName ?? this.orgName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  List<Object?> get props => [
    projectRoleType,
    projectCode,
    projectName,
    orgCode,
    orgName,
    startTime,
    endTime,
  ];
}
