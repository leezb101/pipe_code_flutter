/*
 * @Author: LeeZB
 * @Date: 2025-08-07 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-07 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'notification_action_vo.dart';

part 'notification_message_vo.g.dart';

/// 通知消息对象
/// 用于封装解析后的具体通知内容
@JsonSerializable()
class NotificationMessageVO extends Equatable {
  const NotificationMessageVO({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.sender,
    this.priority = NotificationPriority.normal,
    this.category,
    this.action,
    this.metadata,
    this.createdAt,
    this.expiresAt,
  });

  /// 消息唯一标识
  final String id;

  /// 消息类型
  final String type;

  /// 消息标题
  final String title;

  /// 消息内容
  final String content;

  /// 发送者
  final String? sender;

  /// 消息优先级
  final NotificationPriority priority;

  /// 消息分类
  final String? category;

  /// 关联的操作
  final NotificationActionVO? action;

  /// 扩展元数据
  final Map<String, dynamic>? metadata;

  /// 创建时间
  final DateTime? createdAt;

  /// 过期时间
  final DateTime? expiresAt;

  factory NotificationMessageVO.fromJson(Map<String, dynamic> json) =>
      _$NotificationMessageVOFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationMessageVOToJson(this);

  NotificationMessageVO copyWith({
    String? id,
    String? type,
    String? title,
    String? content,
    String? sender,
    NotificationPriority? priority,
    String? category,
    NotificationActionVO? action,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return NotificationMessageVO(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      action: action ?? this.action,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// 检查消息是否已过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 检查消息是否需要立即处理
  bool get isUrgent => priority == NotificationPriority.urgent;

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        content,
        sender,
        priority,
        category,
        action,
        metadata,
        createdAt,
        expiresAt,
      ];
}

/// 通知优先级枚举
enum NotificationPriority {
  low, // 低优先级
  normal, // 普通优先级
  high, // 高优先级
  urgent, // 紧急
}