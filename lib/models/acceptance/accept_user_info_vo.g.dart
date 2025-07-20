// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_user_info_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptUserInfoVO _$AcceptUserInfoVOFromJson(Map<String, dynamic> json) =>
    AcceptUserInfoVO(
      supervisorUsers: (json['supervisorUsers'] as List<dynamic>)
          .map((e) => CommonUserVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      constructionUsers: (json['constructionUsers'] as List<dynamic>)
          .map((e) => CommonUserVO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AcceptUserInfoVOToJson(AcceptUserInfoVO instance) =>
    <String, dynamic>{
      'supervisorUsers': instance.supervisorUsers,
      'constructionUsers': instance.constructionUsers,
    };
