// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_project_statistic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapProjectStatistic _$MapProjectStatisticFromJson(Map<String, dynamic> json) =>
    MapProjectStatistic(
      projectId: (json['projectId'] as num).toInt(),
      num: (json['num'] as num?)?.toInt(),
      num2: (json['num2'] as num?)?.toInt(),
      acceptTimes: (json['acceptTimes'] as num?)?.toInt(),
      acceptNum: (json['acceptNum'] as num?)?.toInt(),
      installNum: (json['installNum'] as num?)?.toInt(),
      backNum: (json['backNum'] as num?)?.toInt(),
      cutNum: (json['cutNum'] as num?)?.toInt(),
      destroyNum: (json['destroyNum'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MapProjectStatisticToJson(
  MapProjectStatistic instance,
) => <String, dynamic>{
  'projectId': instance.projectId,
  'num': instance.num,
  'num2': instance.num2,
  'acceptTimes': instance.acceptTimes,
  'acceptNum': instance.acceptNum,
  'installNum': instance.installNum,
  'backNum': instance.backNum,
  'cutNum': instance.cutNum,
  'destroyNum': instance.destroyNum,
};
