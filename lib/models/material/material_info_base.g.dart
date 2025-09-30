// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_info_base.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialInfoBase _$MaterialInfoBaseFromJson(Map<String, dynamic> json) =>
    MaterialInfoBase(
      materialId: (json['materialId'] as num).toInt(),
      materialCode: json['materialCode'] as String?,
      deliveryNumber: json['deliveryNumber'] as String?,
      batchCode: json['batchCode'] as String?,
      mfgNm: json['mfgNm'] as String?,
      purNm: json['purNm'] as String?,
      prodStdNo: json['prodStdNo'] as String?,
      prodNm: json['prodNm'] as String?,
      spec: json['spec'] as String?,
      pressLvl: json['pressLvl'] as String?,
      weight: json['weight'] as String?,
      status: (json['status'] as num?)?.toInt(),
      statusName: json['statusName'] as String?,
    );

Map<String, dynamic> _$MaterialInfoBaseToJson(MaterialInfoBase instance) =>
    <String, dynamic>{
      'materialId': instance.materialId,
      'materialCode': instance.materialCode,
      'deliveryNumber': instance.deliveryNumber,
      'batchCode': instance.batchCode,
      'mfgNm': instance.mfgNm,
      'purNm': instance.purNm,
      'prodStdNo': instance.prodStdNo,
      'prodNm': instance.prodNm,
      'spec': instance.spec,
      'pressLvl': instance.pressLvl,
      'weight': instance.weight,
      'status': instance.status,
      'statusName': instance.statusName,
    };
