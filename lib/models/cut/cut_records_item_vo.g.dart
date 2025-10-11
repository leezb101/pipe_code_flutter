// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cut_records_item_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CutRecordsItemVO _$CutRecordsItemVOFromJson(Map<String, dynamic> json) =>
    CutRecordsItemVO(
      projectId: (json['projectId'] as num).toInt(),
      materialId: (json['materialId'] as num).toInt(),
      type: (json['type'] as num?)?.toInt(),
      typeName: json['typeName'] as String?,
      spec: json['spec'] as String?,
      name: json['name'] as String?,
      len: json['len'] as String?,
      materialCode: json['materialCode'] as String?,
      cutTime: CutRecordsItemVO._cutTimeFromJson(json['cutTime']),
    );

Map<String, dynamic> _$CutRecordsItemVOToJson(CutRecordsItemVO instance) =>
    <String, dynamic>{
      'projectId': instance.projectId,
      'type': instance.type,
      'typeName': instance.typeName,
      'spec': instance.spec,
      'name': instance.name,
      'len': instance.len,
      'materialCode': instance.materialCode,
      'materialId': instance.materialId,
      'cutTime': CutRecordsItemVO._cutTimeToJson(instance.cutTime),
    };
