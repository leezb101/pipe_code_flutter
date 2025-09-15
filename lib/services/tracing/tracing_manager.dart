import 'tracing_context.dart';
import '../../utils/logger.dart';

/// 全局追踪上下文处理器（单例）
class TracingManager {
  /// 私有构造函数，确保单例
  TracingManager._internal();

  /// 获取单例实例
  static final TracingManager _instance = TracingManager._internal();

  /// 工厂构造函数，每次调用都返回同一个实例
  factory TracingManager() => _instance;

  /// 使用List作为栈来管理上下文，以支持嵌套导航和临时操作
  final List<TracingContext> _contextStack = [];

  /// 供NavigatorObserver使用，压入新的上下文
  void pushContext(TracingContext context) {
    _contextStack.add(context);
    Logger.debug(
      'TracingManager: Pushed context: $context. Stack size: ${_contextStack.length}',
      tag: 'TracingManager',
    );
  }

  /// 供NavigatorObserver使用，弹出当前上下文
  /// 如果栈为空则不进行任何操作
  void popContext() {
    if (_contextStack.isNotEmpty) {
      final poppedContext = _contextStack.removeLast();
      Logger.debug(
        'TracingManager: Popped context: $poppedContext. Stack size: ${_contextStack.length}',
        tag: 'TracingManager',
      );
    }
  }

  TracingContext? get currentContext =>
      _contextStack.isNotEmpty ? _contextStack.last : null;

  /// 需要处理精细化日志的地方
  Future<T> scopeAction<T>(
    TracingContext context,
    Future<T> Function() action,
  ) async {
    pushContext(context);
    try {
      return await action();
    } finally {
      popContext();
    }
  }

  /// 便利方法，根据标题包装一个操作
  ///
  /// 此方法会自动获取当前页面上下文，结合传入的actionTitle
  /// [actionTitle]：操作的标题，通常是按钮的文本
  /// [action]：要执行的异步函数
  Future<T> scopeActionWithTitle<T>(
    String actionTitle,
    Future<T> Function() action,
  ) async {
    final pageContext = currentContext;
    if (pageContext == null) {
      // 如果没有上下文，直接进行操作（这种情况极其罕见）
      return await action();
    }
    final actionContext = pageContext.copyWith(
      action: 'click_button',
      description: '${pageContext.description} - $actionTitle',
    );
    return await scopeAction(actionContext, action);
  }
}
