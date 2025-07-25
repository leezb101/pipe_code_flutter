// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'do_signout_request_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoSignoutRequestVo _$DoSignoutRequestVoFromJson(Map<String, dynamic> json) =>
    DoSignoutRequestVo(
      materialList: (json['materialList'] as List<dynamic>)
          .map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageList: (json['imageList'] as List<dynamic>)
          .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      messageTo: (json['messageTo'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$DoSignoutRequestVoToJson(DoSignoutRequestVo instance) =>
    <String, dynamic>{
      'materialList': instance.materialList,
      'imageList': instance.imageList,
      'messageTo': instance.messageTo,
    };
