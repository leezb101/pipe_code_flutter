// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sse_message_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SseMessageVO _$SseMessageVOFromJson(Map<String, dynamic> json) => SseMessageVO(
  msgId: json['msgId'] as String,
  type: (json['type'] as num).toInt(),
  name: json['name'] as String,
  extra: json['extra'] as Map<String, dynamic>?,
  timestamp: SseMessageVO._timestampFromJson(json['timestamp']),
);

Map<String, dynamic> _$SseMessageVOToJson(SseMessageVO instance) =>
    <String, dynamic>{
      'msgId': instance.msgId,
      'type': instance.type,
      'name': instance.name,
      'extra': instance.extra,
      'timestamp': instance.timestamp?.toIso8601String(),
    };
