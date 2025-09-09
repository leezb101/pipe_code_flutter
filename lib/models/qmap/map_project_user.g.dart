// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_project_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapProjectUser _$MapProjectUserFromJson(Map<String, dynamic> json) =>
    MapProjectUser(
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      messageTo: json['messageTo'] as bool?,
      realHandler: json['realHandler'] as bool?,
    );

Map<String, dynamic> _$MapProjectUserToJson(MapProjectUser instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'phone': instance.phone,
      'messageTo': instance.messageTo,
      'realHandler': instance.realHandler,
    };
