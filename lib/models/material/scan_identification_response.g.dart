// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_identification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScanIdentificationData _$ScanIdentificationDataFromJson(
  Map<String, dynamic> json,
) => ScanIdentificationData(
  info: MaterialInfo.fromJson(json['info'] as Map<String, dynamic>),
  projectName: json['projectName'] as String?,
  projectId: (json['projectId'] as num).toInt(),
  projectAddress: json['projectAddress'] as String?,
  materialCode: json['materialCode'] as String,
  cut: json['cut'] as bool,
  type: (json['type'] as num).toInt(),
  group: (json['group'] as num).toInt(),
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
  img: json['img'] as String?,
  accepts: json['accepts'],
  history: json['history'],
  installs: json['installs'],
);

Map<String, dynamic> _$ScanIdentificationDataToJson(
  ScanIdentificationData instance,
) => <String, dynamic>{
  'info': instance.info,
  'projectName': instance.projectName,
  'projectId': instance.projectId,
  'projectAddress': instance.projectAddress,
  'materialCode': instance.materialCode,
  'cut': instance.cut,
  'type': instance.type,
  'group': instance.group,
  'lat': instance.lat,
  'lng': instance.lng,
  'img': instance.img,
  'accepts': instance.accepts,
  'history': instance.history,
  'installs': instance.installs,
};

ScanIdentificationResponse _$ScanIdentificationResponseFromJson(
  Map<String, dynamic> json,
) => ScanIdentificationResponse(
  code: (json['code'] as num).toInt(),
  msg: json['msg'] as String,
  tc: json['tc'],
  data: ScanIdentificationData.fromJson(json['data'] as Map<String, dynamic>),
  success: json['success'] as bool,
);

Map<String, dynamic> _$ScanIdentificationResponseToJson(
  ScanIdentificationResponse instance,
) => <String, dynamic>{
  'code': instance.code,
  'msg': instance.msg,
  'tc': instance.tc,
  'data': instance.data,
  'success': instance.success,
};
