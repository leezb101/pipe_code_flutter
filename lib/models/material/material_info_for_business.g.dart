// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_info_for_business.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialInfoForBusiness _$MaterialInfoForBusinessFromJson(
  Map<String, dynamic> json,
) => MaterialInfoForBusiness(
  normals: (json['normals'] as List<dynamic>)
      .map((e) => MaterialInfoBase.fromJson(e as Map<String, dynamic>))
      .toList(),
  errors: (json['errors'] as List<dynamic>)
      .map((e) => SyncVendorDataError.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MaterialInfoForBusinessToJson(
  MaterialInfoForBusiness instance,
) => <String, dynamic>{'normals': instance.normals, 'errors': instance.errors};
