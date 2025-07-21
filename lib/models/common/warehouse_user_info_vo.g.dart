// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_user_info_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WarehouseUserInfoVO _$WarehouseUserInfoVOFromJson(Map<String, dynamic> json) =>
    WarehouseUserInfoVO(
      warehouseUsers: (json['warehouseUsers'] as List<dynamic>)
          .map((e) => CommonUserVO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WarehouseUserInfoVOToJson(
  WarehouseUserInfoVO instance,
) => <String, dynamic>{'warehouseUsers': instance.warehouseUsers};
