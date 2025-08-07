// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_action_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationActionVO _$NotificationActionVOFromJson(
  Map<String, dynamic> json,
) => NotificationActionVO(
  type: json['type'] as String,
  method: json['method'] as String,
  url: json['url'] as String?,
  params: json['params'] as Map<String, dynamic>?,
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  uiAction: json['uiAction'] == null
      ? null
      : UiActionVO.fromJson(json['uiAction'] as Map<String, dynamic>),
  confirmMessage: json['confirmMessage'] as String?,
);

Map<String, dynamic> _$NotificationActionVOToJson(
  NotificationActionVO instance,
) => <String, dynamic>{
  'type': instance.type,
  'method': instance.method,
  'url': instance.url,
  'params': instance.params,
  'headers': instance.headers,
  'uiAction': instance.uiAction,
  'confirmMessage': instance.confirmMessage,
};

UiActionVO _$UiActionVOFromJson(Map<String, dynamic> json) => UiActionVO(
  action: json['action'] as String,
  route: json['route'] as String?,
  params: json['params'] as Map<String, dynamic>?,
  animation: json['animation'] as String?,
);

Map<String, dynamic> _$UiActionVOToJson(UiActionVO instance) =>
    <String, dynamic>{
      'action': instance.action,
      'route': instance.route,
      'params': instance.params,
      'animation': instance.animation,
    };
