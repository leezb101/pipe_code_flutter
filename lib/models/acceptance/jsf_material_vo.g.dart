// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jsf_material_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsfMaterialVO _$JsfMaterialVOFromJson(Map<String, dynamic> json) =>
    JsfMaterialVO(
      materialId: (json['materialId'] as num).toInt(),
      materialName: json['materialName'] as String,
      num: (json['num'] as num?)?.toInt() ?? 1,
      installPileNo: json['installPileNo'] as String?,
      installImageUrl1: json['installImageUrl1'] as String?,
      installImageUrl2: json['installImageUrl2'] as String?,
      remark: json['remark'] as String?,
      projectId: (json['projectId'] as num).toInt(),
    );

Map<String, dynamic> _$JsfMaterialVOToJson(JsfMaterialVO instance) =>
    <String, dynamic>{
      'materialId': instance.materialId,
      'materialName': instance.materialName,
      'num': instance.num,
      'installPileNo': instance.installPileNo,
      'installImageUrl1': instance.installImageUrl1,
      'installImageUrl2': instance.installImageUrl2,
      'remark': instance.remark,
      'projectId': instance.projectId,
    };
