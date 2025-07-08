// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipe_material.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PipeMaterial _$PipeMaterialFromJson(Map<String, dynamic> json) => PipeMaterial(
  id: json['id'] as String,
  materialCode: json['materialCode'] as String,
  materialName: json['materialName'] as String,
  specification: json['specification'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unit: json['unit'] as String? ?? '个',
  batchCode: json['batchCode'] as String?,
  deliveryDate: json['deliveryDate'] == null
      ? null
      : DateTime.parse(json['deliveryDate'] as String),
  supplier: json['supplier'] as String?,
  remarks: json['remarks'] as String?,
);

Map<String, dynamic> _$PipeMaterialToJson(PipeMaterial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'materialCode': instance.materialCode,
      'materialName': instance.materialName,
      'specification': instance.specification,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'batchCode': instance.batchCode,
      'deliveryDate': instance.deliveryDate?.toIso8601String(),
      'supplier': instance.supplier,
      'remarks': instance.remarks,
    };
