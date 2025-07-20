// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'do_accept_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoAcceptVO _$DoAcceptVOFromJson(Map<String, dynamic> json) => DoAcceptVO(
  materiaList: (json['materiaList'] as List<dynamic>)
      .map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
      .toList(),
  imageList: (json['imageList'] as List<dynamic>)
      .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
      .toList(),
  sendAcceptUrl: json['sendAcceptUrl'] as String?,
  acceptReportUrl: json['acceptReportUrl'] as String?,
  realWarehouse: json['realWarehouse'] as bool,
  warehouseId: (json['warehouseId'] as num).toInt(),
  messageTo: (json['messageTo'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$DoAcceptVOToJson(DoAcceptVO instance) =>
    <String, dynamic>{
      'materiaList': instance.materiaList,
      'imageList': instance.imageList,
      'sendAcceptUrl': instance.sendAcceptUrl,
      'acceptReportUrl': instance.acceptReportUrl,
      'realWarehouse': instance.realWarehouse,
      'warehouseId': instance.warehouseId,
      'messageTo': instance.messageTo,
    };
