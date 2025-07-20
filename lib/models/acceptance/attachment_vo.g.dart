// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttachmentVO _$AttachmentVOFromJson(Map<String, dynamic> json) => AttachmentVO(
  type: (json['type'] as num).toInt(),
  name: json['name'] as String,
  url: json['url'] as String,
  attachFormat: (json['attachFormat'] as num).toInt(),
);

Map<String, dynamic> _$AttachmentVOToJson(AttachmentVO instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'url': instance.url,
      'attachFormat': instance.attachFormat,
    };
