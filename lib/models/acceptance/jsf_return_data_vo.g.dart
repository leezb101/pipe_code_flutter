// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jsf_return_data_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsfReturnDataVO _$JsfReturnDataVOFromJson(Map<String, dynamic> json) =>
    JsfReturnDataVO(
      lng: json['lng'] as String?,
      lat: json['lat'] as String?,
      materialList: (json['materialList'] as List<dynamic>)
          .map((e) => JsfMaterialVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageList: (json['imageList'] as List<dynamic>)
          .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      returnType: (json['returnType'] as num).toInt(),
      returnRemark: json['returnRemark'] as String?,
      returnRemarkVoice:
          (json['returnRemarkVoice'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$JsfReturnDataVOToJson(JsfReturnDataVO instance) =>
    <String, dynamic>{
      'lng': instance.lng,
      'lat': instance.lat,
      'materialList': instance.materialList,
      'imageList': instance.imageList,
      'returnType': instance.returnType,
      'returnRemark': instance.returnRemark,
      'returnRemarkVoice': instance.returnRemarkVoice,
    };
