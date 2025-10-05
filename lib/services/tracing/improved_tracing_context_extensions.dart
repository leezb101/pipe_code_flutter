import '../../../config/service_locator.dart';
import 'improved_tracing_manager.dart';
import 'tracing_context.dart';
import 'tracing_manager.dart';

/// 为 TracingManager 提供向后兼容的扩展方法
/// 这些方法会自动使用 ImprovedTracingManager 来处理操作
extension ImprovedTracingContextExtensions on TracingManager {
  /// 使用改进的追踪系统执行带追踪的操作
  ///
  /// 这个扩展方法提供向后兼容性，现有使用 TracingManager.scopeAction 的代码
  /// 会自动使用 ImprovedTracingManager 进行处理
  Future<T> scopeAction<T>(
    TracingContext context,
    Future<T> Function() action,
  ) async {
    final improvedManager = getIt<ImprovedTracingManager>();

    // 使用改进追踪管理器的便利方法
    return improvedManager.scopeActionWithTitle(
      context.description ?? '${context.source}_${context.action}',
      action,
    );
  }

  /// 便利方法：基于描述执行操作
  Future<T> scopeActionWithDescription<T>(
    String description,
    Future<T> Function() action, {
    String? entityId,
  }) async {
    final improvedManager = getIt<ImprovedTracingManager>();

    return improvedManager.scopeActionWithTitle(
      description,
      action,
      entityId: entityId,
    );
  }
}
