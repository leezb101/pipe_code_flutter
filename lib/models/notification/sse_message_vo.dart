/*
 * @Author: LeeZB
 * @Date: 2025-08-07 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-07 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'sse_message_vo.g.dart';

/// SSE消息基础对象
/// 用于封装从SSE接收到的原始消息
@JsonSerializable()
class SseMessageVO extends Equatable {
  const SseMessageVO({
    required this.msgId,
    required this.type,
    required this.name,
    this.extra,
    this.timestamp,
  });

  /// 消息唯一标识
  final String msgId;

  /// 事件类型
  final int type;

  /// 消息名称 (JSON字符串)
  final String name;

  /// 具体业务内容
  final Map<String, dynamic>? extra;

  /// 消息时间戳
  @JsonKey(fromJson: _timestampFromJson)
  final DateTime? timestamp;

  factory SseMessageVO.fromJson(Map<String, dynamic> json) =>
      _$SseMessageVOFromJson(json);

  /// timestamp字段自定义解析：无或空时用当前时间
  static DateTime _timestampFromJson(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) {
      return DateTime.now();
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    if (value is int) {
      // 支持时间戳为毫秒
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    throw ArgumentError('Invalid timestamp value: $value');
  }

  Map<String, dynamic> toJson() => _$SseMessageVOToJson(this);

  SseMessageVO copyWith({
    String? msgId,
    int? type,
    String? name,
    Map<String, dynamic>? extra,
    DateTime? timestamp,
  }) {
    return SseMessageVO(
      msgId: msgId ?? this.msgId,
      type: type ?? this.type,
      name: name ?? this.name,
      extra: extra ?? this.extra,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [msgId, type, name, extra, timestamp];
}
