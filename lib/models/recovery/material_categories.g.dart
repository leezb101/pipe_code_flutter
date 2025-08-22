// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_categories.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialCategory _$MaterialCategoryFromJson(Map<String, dynamic> json) =>
    MaterialCategory(
      group: (json['group'] as num).toInt(),
      name: json['name'] as String,
      types: (json['types'] as List<dynamic>)
          .map((e) => MaterialType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MaterialCategoryToJson(MaterialCategory instance) =>
    <String, dynamic>{
      'group': instance.group,
      'name': instance.name,
      'types': instance.types,
    };

MaterialType _$MaterialTypeFromJson(Map<String, dynamic> json) => MaterialType(
  name: json['name'] as String,
  retrieveBacks: (json['retrieveBacks'] as List<dynamic>)
      .map((e) => RetrieveBack.fromJson(e as Map<String, dynamic>))
      .toList(),
  type: (json['type'] as num).toInt(),
);

Map<String, dynamic> _$MaterialTypeToJson(MaterialType instance) =>
    <String, dynamic>{
      'name': instance.name,
      'retrieveBacks': instance.retrieveBacks,
      'type': instance.type,
    };

RetrieveBack _$RetrieveBackFromJson(Map<String, dynamic> json) => RetrieveBack(
  key: json['key'] as String,
  name: json['name'] as String,
  value: json['value'] as String?,
);

Map<String, dynamic> _$RetrieveBackToJson(RetrieveBack instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'value': instance.value,
    };
