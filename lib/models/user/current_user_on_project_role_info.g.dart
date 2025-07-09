// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_on_project_role_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentUserOnProjectRoleInfo _$CurrentUserOnProjectRoleInfoFromJson(
  Map<String, dynamic> json,
) => CurrentUserOnProjectRoleInfo(
  currentProjectRoleType: json['currentProjectRoleType'] as String,
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
