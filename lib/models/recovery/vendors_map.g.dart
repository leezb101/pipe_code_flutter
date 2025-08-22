// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendors_map.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorsMap _$VendorsMapFromJson(Map<String, dynamic> json) =>
    VendorsMap(vendors: Map<String, String>.from(json['vendors'] as Map));

Map<String, dynamic> _$VendorsMapToJson(VendorsMap instance) =>
    <String, dynamic>{'vendors': instance.vendors};

VendorOption _$VendorOptionFromJson(Map<String, dynamic> json) =>
    VendorOption(code: json['code'] as String, name: json['name'] as String);

Map<String, dynamic> _$VendorOptionToJson(VendorOption instance) =>
    <String, dynamic>{'code': instance.code, 'name': instance.name};
