// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectInfo _$ProjectInfoFromJson(Map<String, dynamic> json) => ProjectInfo(
  projectRoleType: $enumDecode(_$UserRoleEnumMap, json['projectRoleType']),
  projectCode: json['projectCode'] as String,
  projectName: json['projectName'] as String,
  projectId: (json['projectId'] as num).toInt(),
  orgCode: json['orgCode'] as String?,
  orgName: json['orgName'] as String?,
  startTime: json['startTime'] == null
      ? null
      : DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
);

Map<String, dynamic> _$ProjectInfoToJson(ProjectInfo instance) =>
    <String, dynamic>{
      'projectRoleType': instance.projectRoleType,
      'projectId': instance.projectId,
      'projectCode': instance.projectCode,
      'projectName': instance.projectName,
      'orgCode': instance.orgCode,
      'orgName': instance.orgName,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
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
