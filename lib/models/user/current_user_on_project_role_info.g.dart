// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_on_project_role_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentUserOnProjectRoleInfo _$CurrentUserOnProjectRoleInfoFromJson(
  Map<String, dynamic> json,
) => CurrentUserOnProjectRoleInfo(
  currentProjectRoleType: $enumDecode(
    _$UserRoleEnumMap,
    json['currentProjectRoleType'],
  ),
  currentProjectId: (json['currentProjectId'] as num).toInt(),
  currentProjectCode: json['currentProjectCode'] as String,
  currentProjectName: json['currentProjectName'] as String,
  currentOrgCode: json['currentOrgCode'] as String,
  currentOrgName: json['currentOrgName'] as String,
  currentProjectSuperiorUserId: (json['currentProjectSuperiorUserId'] as num?)
      ?.toInt(),
  currentProjectAuthorUserId: (json['currentProjectAuthorUserId'] as num?)
      ?.toInt(),
  expire: json['expire'] as bool,
);

Map<String, dynamic> _$CurrentUserOnProjectRoleInfoToJson(
  CurrentUserOnProjectRoleInfo instance,
) => <String, dynamic>{
  'currentProjectRoleType': instance.currentProjectRoleType,
  'currentProjectId': instance.currentProjectId,
  'currentProjectCode': instance.currentProjectCode,
  'currentProjectName': instance.currentProjectName,
  'currentOrgCode': instance.currentOrgCode,
  'currentOrgName': instance.currentOrgName,
  'currentProjectSuperiorUserId': instance.currentProjectSuperiorUserId,
  'currentProjectAuthorUserId': instance.currentProjectAuthorUserId,
  'expire': instance.expire,
};

const _$UserRoleEnumMap = {
  UserRole.suppliers: 0,
  UserRole.construction: 1,
  UserRole.supervisor: 2,
  UserRole.builder: 3,
  UserRole.check: 4,
  UserRole.builderSub: 5,
  UserRole.laborer: 6,
  UserRole.playgoer: 7,
};
