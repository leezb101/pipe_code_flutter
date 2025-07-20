// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'do_accept_sign_in_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoAcceptSignInVO _$DoAcceptSignInVOFromJson(Map<String, dynamic> json) =>
    DoAcceptSignInVO(
      acceptId: (json['acceptId'] as num).toInt(),
      materiaList: (json['materiaList'] as List<dynamic>)
          .map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageList: (json['imageList'] as List<dynamic>)
          .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DoAcceptSignInVOToJson(DoAcceptSignInVO instance) =>
    <String, dynamic>{
      'acceptId': instance.acceptId,
      'materiaList': instance.materiaList,
      'imageList': instance.imageList,
    };
