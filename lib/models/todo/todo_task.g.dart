// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoTask _$TodoTaskFromJson(Map<String, dynamic> json) => TodoTask(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  businessType: (json['businessType'] as num).toInt(),
  businessName: json['businessName'] as String,
  businessId: (json['businessId'] as num).toInt(),
  projectId: (json['projectId'] as num).toInt(),
  projectName: json['projectName'] as String,
  projectCode: json['projectCode'] as String,
  launchTime: TodoTask._timestampToDateTime(json['launchTime']),
  finishTime: TodoTask._timestampToDateTime(json['finishTime']),
  finishStatus: (json['finishStatus'] as num).toInt(),
  launchUser: json['launchUser'] as String,
  launchName: json['launchName'] as String,
);

Map<String, dynamic> _$TodoTaskToJson(TodoTask instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'businessType': instance.businessType,
  'businessName': instance.businessName,
  'businessId': instance.businessId,
  'projectId': instance.projectId,
  'projectName': instance.projectName,
  'projectCode': instance.projectCode,
  'launchTime': TodoTask._dateTimeToTimestamp(instance.launchTime),
  'finishTime': TodoTask._dateTimeToTimestamp(instance.finishTime),
  'finishStatus': instance.finishStatus,
  'launchUser': instance.launchUser,
  'launchName': instance.launchName,
};
