// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectInfo _$ProjectInfoFromJson(Map<String, dynamic> json) => ProjectInfo(
  projectRoleType: json['projectRoleType'] as String,
  projectCode: json['projectCode'] as String,
  projectName: json['projectName'] as String,
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
      'projectCode': instance.projectCode,
      'projectName': instance.projectName,
      'orgCode': instance.orgCode,
      'orgName': instance.orgName,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
    };
