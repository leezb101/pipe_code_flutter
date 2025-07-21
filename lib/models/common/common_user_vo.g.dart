// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_user_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommonUserVO _$CommonUserVOFromJson(Map<String, dynamic> json) => CommonUserVO(
  userId: (json['userId'] as num).toInt(),
  name: json['name'] as String,
  phone: json['phone'] as String,
  messageTo: json['messageTo'] as bool,
  realHandler: json['realHandler'] as bool,
);

Map<String, dynamic> _$CommonUserVOToJson(CommonUserVO instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'phone': instance.phone,
      'messageTo': instance.messageTo,
      'realHandler': instance.realHandler,
    };
