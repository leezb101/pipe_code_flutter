import 'dart:collection';
import 'package:path/path.dart';

import 'tracing_context.dart';
import '../../utils/logger.dart';

/// 全局追踪上下文处理器（单例）
class TracingManager {
  /// 使用双端队列实现堆栈，性能更优
  final Queue<TracingContext> _contextStack = Queue<TracingContext>();

  /// 获取当前上下文堆栈(仅用于调试)
  List<TracingContext> get stack => _contextStack.toList();

  /// 获取当前上下文，即堆栈顶部
  TracingContext? get currentContext =>
      _contextStack.isNotEmpty ? _contextStack.last : null;

  /// 压入一个新的上下文到堆栈
  void pushContext(TracingContext context) {
    _contextStack.addLast(context);
    Logger.debug(
      'TracingManager: Pushed context: $context. Stack size: ${_contextStack.length}',
      tag: 'TracingManager',
    );
  }

  /// 从堆栈顶部弹出一个上下文，如果堆栈为空则不进行任何操作
  void popContext() {
    if (_contextStack.isNotEmpty) {
      final poped = _contextStack.removeLast();
      Logger.debug(
        'TracingManager: Popped context: $poped. Stack size: ${_contextStack.length}',
        tag: 'TracingManager',
      );
    }
  }

  /// 从堆栈中移除一个特定的上下文实例
  /// 对于处理复杂场景的导航（如go_router的替换）有用
  /// 因为被移除的路由对应的上下文不一定在栈顶
  void removeContext(TracingContext context) {
    // 从后向前搜索并移除，因为导航相关的上下文通常在栈顶附近
    if (_contextStack.remove(context)) {
      Logger.debug(
        'TracingManager: Removed specific context: $context. Stack size: ${_contextStack.length}',
        tag: 'TracingManager',
      );
    }
  }

  Future<T> scopeAction<T>(
    TracingContext context,
    Future<T> Function() action,
  ) async {
    pushContext(context);
    try {
      return await action();
    } finally {
      if (currentContext == context) {
        popContext();
      } else {
        // 这是一个异常情况，可能意味着scopeAction内部发生了意外的导航
        Logger.warning(
          'TracingManager: mismatched context on scopeAction pop. Expected $context but found $currentContext',
          tag: 'TracingManager',
        );
        // 作为安全措施，尝试移除指定的上下文
        removeContext(context);
      }
    }
  }

  /// [scopeAction]的便利版本，用于快速包装由UI标题触发的操作
  Future<T> scopeActionWithTitle<T>(
    String actionTitle,
    Future<T> Function() action,
  ) async {
    final pageContext =
        currentContext ??
        const TracingContext(
          source: '未知页面',
          action: 'unknown',
          description: '未知页面',
        );
    final actionContext = pageContext.copyWith(
      action: 'ui-action',
      description: '${pageContext.description} - $actionTitle',
    );

    return scopeAction(actionContext, action);
  }

  void clear() {
    _contextStack.clear();
    Logger.debug(
      'TracingManager: Cleared all contexts. Stack size: ${_contextStack.length}',
      tag: 'TracingManager',
    );
  }

  /// 私有构造函数，确保单例
  TracingManager._internal();

  /// 获取单例实例
  static final TracingManager _instance = TracingManager._internal();

  /// 工厂构造函数，每次调用都返回同一个实例
  factory TracingManager() => _instance;
}
