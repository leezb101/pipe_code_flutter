// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_info_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignInInfoVO _$SignInInfoVOFromJson(Map<String, dynamic> json) => SignInInfoVO(
  materiaList: (json['materiaList'] as List<dynamic>)
      .map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
      .toList(),
  imageList: (json['imageList'] as List<dynamic>)
      .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
      .toList(),
  warehouseId: (json['warehouseId'] as num).toInt(),
);

Map<String, dynamic> _$SignInInfoVOToJson(SignInInfoVO instance) =>
    <String, dynamic>{
      'materiaList': instance.materiaList,
      'imageList': instance.imageList,
      'warehouseId': instance.warehouseId,
    };
