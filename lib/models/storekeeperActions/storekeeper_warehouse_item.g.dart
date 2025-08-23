// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storekeeper_warehouse_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorekeeperWarehouseItem _$StorekeeperWarehouseItemFromJson(
  Map<String, dynamic> json,
) => StorekeeperWarehouseItem(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  address: json['address'] as String?,
  isRealWarehouse: json['isRealWarehouse'] as bool? ?? false,
);

Map<String, dynamic> _$StorekeeperWarehouseItemToJson(
  StorekeeperWarehouseItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'isRealWarehouse': instance.isRealWarehouse,
};
