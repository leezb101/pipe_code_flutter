import 'package:flutter/widgets.dart';
import '../config/service_locator.dart';
import '../services/tracing/improved_tracing_manager.dart';
import '../services/tracing/tracing_context.dart';

extension ImprovedTracingContextX on BuildContext {
  /// 根据给定的操作标题创建操作上下文（新版本，支持并发）
  EnhancedTracingContext createEnhancedActionContext(
    String actionTitle, {
    String? entityId,
    String? parentId,
  }) {
    final manager = getIt<ImprovedTracingManager>();
    final pageContext =
        manager.currentPageContext ??
        const TracingContext(
          source: 'unknown',
          action: 'unknown',
          description: '未知页面',
        );

    return manager.createOperationContext(
      source: pageContext.source,
      action: 'user-action',
      description: pageContext.description != null
          ? '${pageContext.description} - $actionTitle'
          : actionTitle,
      entityId: entityId,
      parentId: parentId,
    );
  }

  /// 执行带追踪的操作（新版本，支持并发）
  Future<T> executeTracedOperation<T>(
    String actionTitle,
    Future<T> Function() operation, {
    String? entityId,
    String? parentId,
  }) async {
    final manager = getIt<ImprovedTracingManager>();
    return manager.scopeActionWithTitle(
      actionTitle,
      operation,
      entityId: entityId,
      parentId: parentId,
    );
  }

  /// 兼容性方法：保持与现有代码的兼容性
  TracingContext createActionContext(String actionTitle) {
    final manager = getIt<ImprovedTracingManager>();
    final pageContext =
        manager.currentPageContext ??
        const TracingContext(
          source: 'unknown',
          action: 'unknown',
          description: '未知页面',
        );

    return TracingContext(
      source: pageContext.source,
      action: 'user-action',
      description: pageContext.description != null
          ? '${pageContext.description} - $actionTitle'
          : actionTitle,
    );
  }
}
