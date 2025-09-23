// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cut_request_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CutRequestVo _$CutRequestVoFromJson(Map<String, dynamic> json) => CutRequestVo(
  cutMaterialSubVOS: (json['cutMaterialSubVOS'] as List<dynamic>)
      .map((e) => CutMaterialSubVO.fromJson(e as Map<String, dynamic>))
      .toList(),
  qrCode: json['qrCode'] as String,
  img: json['img'] as String,
  description: json['description'] as String?,
  descriptionVoice: (json['descriptionVoice'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CutRequestVoToJson(CutRequestVo instance) =>
    <String, dynamic>{
      'cutMaterialSubVOS': instance.cutMaterialSubVOS,
      'qrCode': instance.qrCode,
      'img': instance.img,
      'description': instance.description,
      'descriptionVoice': instance.descriptionVoice,
    };
