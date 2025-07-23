// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_vendor_data_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncVendorDataError _$SyncVendorDataErrorFromJson(Map<String, dynamic> json) =>
    SyncVendorDataError(
      qrCode: json['qrCode'] as String?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      msg: json['msg'] as String?,
    );

Map<String, dynamic> _$SyncVendorDataErrorToJson(
  SyncVendorDataError instance,
) => <String, dynamic>{
  'qrCode': instance.qrCode,
  'code': instance.code,
  'name': instance.name,
  'msg': instance.msg,
};
