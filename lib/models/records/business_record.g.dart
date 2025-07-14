// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessRecord _$BusinessRecordFromJson(Map<String, dynamic> json) =>
    BusinessRecord(
      id: (json['id'] as num).toInt(),
      bizType: (json['bizType'] as num?)?.toInt(),
      projectName: json['projectName'] as String,
      projectCode: json['projectCode'] as String,
      materialNum: (json['materialNum'] as num?)?.toInt(),
      userName: json['userName'] as String,
      doTime: json['doTime'] as String,
    );

Map<String, dynamic> _$BusinessRecordToJson(BusinessRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bizType': instance.bizType,
      'projectName': instance.projectName,
      'projectCode': instance.projectCode,
      'materialNum': instance.materialNum,
      'userName': instance.userName,
      'doTime': instance.doTime,
    };
