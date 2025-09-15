import 'package:flutter/foundation.dart';

@immutable
class TracingInfo {
  /// 路由来源标识
  final String source;

  /// 描述信息
  final String description;

  const TracingInfo({required this.source, required this.description});
}
