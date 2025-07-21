// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WarehouseVO _$WarehouseVOFromJson(Map<String, dynamic> json) => WarehouseVO(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  address: json['address'] as String,
  isRealWarehouse: json['isRealWarehouse'] as bool,
);

Map<String, dynamic> _$WarehouseVOToJson(WarehouseVO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'isRealWarehouse': instance.isRealWarehouse,
    };
