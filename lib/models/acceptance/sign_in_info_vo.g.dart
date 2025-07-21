// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_info_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignInInfoVO _$SignInInfoVOFromJson(Map<String, dynamic> json) => SignInInfoVO(
  materialList: (json['materialList'] as List<dynamic>)
      .map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
      .toList(),
  imageList: (json['imageList'] as List<dynamic>)
      .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
      .toList(),
  warehouseId: (json['warehouseId'] as num).toInt(),
);

Map<String, dynamic> _$SignInInfoVOToJson(SignInInfoVO instance) =>
    <String, dynamic>{
      'materialList': instance.materialList,
      'imageList': instance.imageList,
      'warehouseId': instance.warehouseId,
    };
