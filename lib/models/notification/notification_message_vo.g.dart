// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_message_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationMessageVO _$NotificationMessageVOFromJson(
  Map<String, dynamic> json,
) => NotificationMessageVO(
  id: json['id'] as String,
  type: json['type'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  sender: json['sender'] as String?,
  priority:
      $enumDecodeNullable(_$NotificationPriorityEnumMap, json['priority']) ??
      NotificationPriority.normal,
  category: json['category'] as String?,
  action: json['action'] == null
      ? null
      : NotificationActionVO.fromJson(json['action'] as Map<String, dynamic>),
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$NotificationMessageVOToJson(
  NotificationMessageVO instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'title': instance.title,
  'content': instance.content,
  'sender': instance.sender,
  'priority': _$NotificationPriorityEnumMap[instance.priority]!,
  'category': instance.category,
  'action': instance.action,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt?.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};
