// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jsf_accept_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsfAcceptVO _$JsfAcceptVOFromJson(Map<String, dynamic> json) => JsfAcceptVO(
  lng: json['lng'] as String?,
  lat: json['lat'] as String?,
  materialList: (json['materialList'] as List<dynamic>)
      .map((e) => JsfMaterialVO.fromJson(e as Map<String, dynamic>))
      .toList(),
  imageList: (json['imageList'] as List<dynamic>)
      .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
      .toList(),
  sendAcceptUrl: (json['sendAcceptUrl'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  acceptReportUrl: (json['acceptReportUrl'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  realWarehouse: json['realWarehouse'] as bool,
  warehouseId: (json['warehouseId'] as num).toInt(),
  messageTo: (json['messageTo'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  returnData: json['returnData'] == null
      ? null
      : JsfReturnDataVO.fromJson(json['returnData'] as Map<String, dynamic>),
);

Map<String, dynamic> _$JsfAcceptVOToJson(JsfAcceptVO instance) =>
    <String, dynamic>{
      'lng': instance.lng,
      'lat': instance.lat,
      'materialList': instance.materialList,
      'imageList': instance.imageList,
      'sendAcceptUrl': instance.sendAcceptUrl,
      'acceptReportUrl': instance.acceptReportUrl,
      'realWarehouse': instance.realWarehouse,
      'warehouseId': instance.warehouseId,
      'messageTo': instance.messageTo,
      'returnData': instance.returnData,
    };
