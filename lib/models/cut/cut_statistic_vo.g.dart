// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cut_statistic_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CutStatisticVo _$CutStatisticVoFromJson(Map<String, dynamic> json) =>
    CutStatisticVo(
      projectId: (json['projectId'] as num).toInt(),
      cutSourceNum: (json['cutSourceNum'] as num?)?.toInt() ?? 0,
      cutTimes: (json['cutTimes'] as num?)?.toInt() ?? 0,
      newActivePipeNum: (json['newActivePipeNum'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CutStatisticVoToJson(CutStatisticVo instance) =>
    <String, dynamic>{
      'projectId': instance.projectId,
      'cutSourceNum': instance.cutSourceNum,
      'cutTimes': instance.cutTimes,
      'newActivePipeNum': instance.newActivePipeNum,
    };
