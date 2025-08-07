// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sse_message_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SseMessageVO _$SseMessageVOFromJson(Map<String, dynamic> json) => SseMessageVO(
  id: json['id'] as String,
  event: json['event'] as String,
  data: json['data'] as String,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$SseMessageVOToJson(SseMessageVO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event': instance.event,
      'data': instance.data,
      'timestamp': instance.timestamp?.toIso8601String(),
    };
