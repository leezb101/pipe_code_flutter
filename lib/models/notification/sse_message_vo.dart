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
    required this.id,
    required this.event,
    required this.data,
    this.timestamp,
  });

  /// 消息唯一标识
  final String id;

  /// 事件类型
  final String event;

  /// 消息数据 (JSON字符串)
  final String data;

  /// 消息时间戳
  final DateTime? timestamp;

  factory SseMessageVO.fromJson(Map<String, dynamic> json) =>
      _$SseMessageVOFromJson(json);

  Map<String, dynamic> toJson() => _$SseMessageVOToJson(this);

  SseMessageVO copyWith({
    String? id,
    String? event,
    String? data,
    DateTime? timestamp,
  }) {
    return SseMessageVO(
      id: id ?? this.id,
      event: event ?? this.event,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [id, event, data, timestamp];
}