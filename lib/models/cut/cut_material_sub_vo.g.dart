// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cut_material_sub_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CutMaterialSubVO _$CutMaterialSubVOFromJson(Map<String, dynamic> json) =>
    CutMaterialSubVO(
      qrCode: json['qrCode'] as String,
      len: json['len'] as String,
      img: json['img'] as String? ?? '',
    );

Map<String, dynamic> _$CutMaterialSubVOToJson(CutMaterialSubVO instance) =>
    <String, dynamic>{
      'qrCode': instance.qrCode,
      'len': instance.len,
      'img': instance.img,
    };
