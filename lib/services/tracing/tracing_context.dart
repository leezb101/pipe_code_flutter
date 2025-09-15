import 'package:flutter/foundation.dart';

@immutable
class TracingContext {
  /// 操作来源标识(必需)
  ///
  /// 用一个唯一的字符串来标识操作发起的页面或组件
  final String source;

  /// 具体操作（按钮）标识(必需)
  ///
  /// 用一个唯一的字符串来标识具体的操作按钮
  final String action;

  /// 额外信息(可选)
  ///
  /// 用于补充描述操作的额外信息
  final String? description;

  /// 可选的关联实体ID
  ///
  /// 用于关联操作的具体实体，如用户ID、订单ID等
  final String? entityId;

  const TracingContext({
    required this.source,
    required this.action,
    this.description,
    this.entityId,
  });

  TracingContext copyWith({
    String? source,
    String? action,
    String? description,
    String? entityId,
  }) {
    return TracingContext(
      source: source ?? this.source,
      action: action ?? this.action,
      description: description ?? this.description,
      entityId: entityId ?? this.entityId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'action': action,
      if (description != null) 'description': description,
      if (entityId != null) 'entityId': entityId,
    }..removeWhere((key, value) => value == null);
  }

  @override
  String toString() {
    return 'TracingContext(source: $source, action: $action, description: $description, entityId: $entityId)';
  }
}
