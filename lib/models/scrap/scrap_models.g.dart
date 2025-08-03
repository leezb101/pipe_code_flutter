// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrap_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScrapDetailVO _$ScrapDetailVOFromJson(Map<String, dynamic> json) =>
    ScrapDetailVO(
      materialList:
          (json['materialList'] as List<dynamic>?)
              ?.map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachmentList:
          (json['attachmentList'] as List<dynamic>?)
              ?.map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$ScrapDetailVOToJson(ScrapDetailVO instance) =>
    <String, dynamic>{
      'materialList': instance.materialList,
      'attachmentList': instance.attachmentList,
    };
