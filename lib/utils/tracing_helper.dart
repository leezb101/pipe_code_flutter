import 'package:flutter/widgets.dart';

import '../config/service_locator.dart';
import '../services/tracing/improved_tracing_manager.dart';

/// 一个助手类，用于将tracing上下文的管理从业务中剥离
class TracingHelper {
  /// 执行一个带tracing上下文的异步操作
  ///
  /// 这是一个用于非BLoC页面的便捷"包装器"，它会自动根据[actionTitle]创建一个精确的操作上下文，并使用`ImprovedTracingManager.scopeActionWithTitle`来安全低执行异步业务逻辑[action]。
  ///
  ///[context]:当前的BuildContext， 用于创建上下文
  ///[actionTitle]:操作的标题， 用于描述当前操作
  ///[action]:需要执行的异步操作
  static Future<void> run(
    BuildContext context,
    String actionTitle,
    Future<void> Function() action,
  ) {
    // 直接使用ImprovedTracingManager的scopeActionWithTitle方法
    final tracingManager = getIt<ImprovedTracingManager>();
    return tracingManager.scopeActionWithTitle(actionTitle, action);
  }
}
