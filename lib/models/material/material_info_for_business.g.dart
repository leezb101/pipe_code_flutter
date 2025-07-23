// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_info_for_business.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialInfoForBusiness _$MaterialInfoForBusinessFromJson(
  Map<String, dynamic> json,
) => MaterialInfoForBusiness(
  normal: (json['normal'] as List<dynamic>)
      .map((e) => MaterialInfoBase.fromJson(e as Map<String, dynamic>))
      .toList(),
  error: (json['error'] as List<dynamic>)
      .map((e) => SyncVendorDataError.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MaterialInfoForBusinessToJson(
  MaterialInfoForBusiness instance,
) => <String, dynamic>{'normal': instance.normal, 'error': instance.error};
