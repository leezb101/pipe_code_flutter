// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_on_project_role_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentUserOnProjectRoleInfo _$CurrentUserOnProjectRoleInfoFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(json, disallowNullValues: const ['currentProjectSupplyType']);
  return CurrentUserOnProjectRoleInfo(
    projectRoleType: $enumDecode(_$UserRoleEnumMap, json['projectRoleType']),
    currentProjectId: (json['currentProjectId'] as num).toInt(),
    currentProjectCode: json['currentProjectCode'] as String,
    currentProjectName: json['currentProjectName'] as String,
    currentOrgCode: json['currentOrgCode'] as String? ?? '',
    currentOrgName: json['currentOrgName'] as String? ?? '',
    currentProjectSupplyType: $enumDecode(
      _$ProjectSupplyTypeEnumMap,
      json['currentProjectSupplyType'],
    ),
    currentPurNm: json['currentPurNm'] as String? ?? '',
    currentProjectSuperiorUserId: (json['currentProjectSuperiorUserId'] as num?)
        ?.toInt(),
    currentProjectAuthorUserId: (json['currentProjectAuthorUserId'] as num?)
        ?.toInt(),
    expire: json['expire'] as bool,
  );
}

Map<String, dynamic> _$CurrentUserOnProjectRoleInfoToJson(
  CurrentUserOnProjectRoleInfo instance,
) => <String, dynamic>{
  'projectRoleType': instance.projectRoleType,
  'currentProjectId': instance.currentProjectId,
  'currentProjectCode': instance.currentProjectCode,
  'currentProjectName': instance.currentProjectName,
  'currentOrgCode': instance.currentOrgCode,
  'currentOrgName': instance.currentOrgName,
  'currentProjectSupplyType': instance.currentProjectSupplyType,
  'currentPurNm': instance.currentPurNm,
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
  UserRole.storekeeper: 8,
};

const _$ProjectSupplyTypeEnumMap = {
  ProjectSupplyType.jiaGongCai: 0,
  ProjectSupplyType.yiGongCai: 1,
  ProjectSupplyType.jiaYiHunGong: 2,
};
