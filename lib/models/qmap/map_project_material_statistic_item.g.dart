// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_project_material_statistic_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapProjectMaterialStatisticItem _$MapProjectMaterialStatisticItemFromJson(
  Map<String, dynamic> json,
) => MapProjectMaterialStatisticItem(
  materialType: (json['materialType'] as num?)?.toInt(),
  materialName: json['materialName'] as String?,
  num: (json['num'] as num?)?.toInt(),
);

Map<String, dynamic> _$MapProjectMaterialStatisticItemToJson(
  MapProjectMaterialStatisticItem instance,
) => <String, dynamic>{
  'materialType': instance.materialType,
  'materialName': instance.materialName,
  'num': instance.num,
};
