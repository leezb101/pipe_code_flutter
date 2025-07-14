// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectRecord _$ProjectRecordFromJson(Map<String, dynamic> json) =>
    ProjectRecord(
      id: (json['id'] as num).toInt(),
      projectName: json['projectName'] as String,
      projectCode: json['projectCode'] as String,
      projectStart: json['projectStart'] as String?,
      projectEnd: json['projectEnd'] as String?,
      createdName: json['createdName'] as String?,
      createdId: (json['createdId'] as num?)?.toInt(),
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$ProjectRecordToJson(ProjectRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectName': instance.projectName,
      'projectCode': instance.projectCode,
      'projectStart': instance.projectStart,
      'projectEnd': instance.projectEnd,
      'createdName': instance.createdName,
      'createdId': instance.createdId,
      'status': instance.status,
    };
