// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialVO _$MaterialVOFromJson(Map<String, dynamic> json) => MaterialVO(
  materialId: (json['materialId'] as num?)?.toInt(),
  materialName: json['materialName'] as String?,
  num: (json['num'] as num?)?.toInt(),
  installPileNo: json['installPileNo'] as String?,
  installImageUrl1: json['installImageUrl1'] as String?,
  installImageUrl2: json['installImageUrl2'] as String?,
  materialCode: json['materialCode'] as String?,
  batchCode: json['batchCode'] as String?,
  status: (json['status'] as num?)?.toInt(),
  statusName: json['statusName'] as String?,
);

Map<String, dynamic> _$MaterialVOToJson(MaterialVO instance) =>
    <String, dynamic>{
      'materialId': instance.materialId,
      'materialName': instance.materialName,
      'num': instance.num,
      'installPileNo': instance.installPileNo,
      'installImageUrl1': instance.installImageUrl1,
      'installImageUrl2': instance.installImageUrl2,
      'materialCode': instance.materialCode,
      'batchCode': instance.batchCode,
      'status': instance.status,
      'statusName': instance.statusName,
    };
