// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_detail_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReturnDetailVo _$ReturnDetailVoFromJson(Map<String, dynamic> json) =>
    ReturnDetailVo(
      materialList:
          (json['materialList'] as List<dynamic>?)
              ?.map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      imageList:
          (json['imageList'] as List<dynamic>?)
              ?.map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      returnType: (json['returnType'] as num?)?.toInt() ?? 1,
      returnRemark: json['returnRemark'] as String? ?? '',
    );

Map<String, dynamic> _$ReturnDetailVoToJson(ReturnDetailVo instance) =>
    <String, dynamic>{
      'materialList': instance.materialList,
      'imageList': instance.imageList,
      'returnType': instance.returnType,
      'returnRemark': instance.returnRemark,
    };
