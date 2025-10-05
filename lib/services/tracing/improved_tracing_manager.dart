import 'dart:collection';
import 'dart:async';
import 'package:uuid/uuid.dart';

import 'tracing_context.dart';
import '../../utils/logger.dart';

/// 增强的追踪上下文，支持并发操作
class EnhancedTracingContext extends TracingContext {
  /// 唯一标识符
  final String id;

  /// 父操作ID（用于构建操作链）
  final String? parentId;

  /// 操作开始时间
  final DateTime startTime;

  /// 操作结束时间
  final DateTime? endTime;

  const EnhancedTracingContext({
    required this.id,
    this.parentId,
    required this.startTime,
    this.endTime,
    required super.source,
    required super.action,
    super.description,
    super.entityId,
  });

  @override
  EnhancedTracingContext copyWith({
    String? id,
    String? parentId,
    DateTime? startTime,
    DateTime? endTime,
    String? source,
    String? action,
    String? description,
    String? entityId,
  }) {
    return EnhancedTracingContext(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      source: source ?? this.source,
      action: action ?? this.action,
      description: description ?? this.description,
      entityId: entityId ?? this.entityId,
    );
  }

  /// 标记操作完成
  EnhancedTracingContext markCompleted() {
    return copyWith(endTime: DateTime.now());
  }

  /// 计算操作耗时
  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'id': id,
      if (parentId != null) 'parentId': parentId,
      'startTime': startTime.toIso8601String(),
      if (endTime != null) 'endTime': endTime!.toIso8601String(),
      if (duration != null) 'duration': duration!.inMilliseconds,
    };
  }

  @override
  String toString() {
    return 'EnhancedTracingContext(id: $id, parentId: $parentId, source: $source, action: $action, description: $description, duration: ${duration?.inMilliseconds}ms)';
  }
}

/// 改进的追踪管理器，支持并发操作
class ImprovedTracingManager {
  static const _uuid = Uuid();

  /// 活跃的操作上下文（支持并发）
  final Map<String, EnhancedTracingContext> _activeContexts = {};

  /// 已完成的操作历史
  final Queue<EnhancedTracingContext> _completedContexts =
      Queue<EnhancedTracingContext>();

  /// 当前页面上下文栈（用于导航追踪）
  final Queue<TracingContext> _pageContextStack = Queue<TracingContext>();

  /// 最大历史记录数量
  static const int _maxHistorySize = 100;

  /// 获取当前页面上下文
  TracingContext? get currentPageContext =>
      _pageContextStack.isNotEmpty ? _pageContextStack.last : null;

  /// 获取所有活跃的操作
  List<EnhancedTracingContext> get activeOperations =>
      _activeContexts.values.toList();

  /// 获取最近的操作历史
  List<EnhancedTracingContext> get recentHistory => _completedContexts.toList();

  /// 压入页面上下文
  void pushPageContext(TracingContext context) {
    _pageContextStack.addLast(context);
    Logger.debug(
      'ImprovedTracingManager: Pushed page context: $context. Stack size: ${_pageContextStack.length}',
      tag: 'ImprovedTracingManager',
    );
  }

  /// 弹出页面上下文
  void popPageContext() {
    if (_pageContextStack.isNotEmpty) {
      final popped = _pageContextStack.removeLast();
      Logger.debug(
        'ImprovedTracingManager: Popped page context: $popped. Stack size: ${_pageContextStack.length}',
        tag: 'ImprovedTracingManager',
      );
    }
  }

  /// 移除特定页面上下文
  void removePageContext(TracingContext context) {
    if (_pageContextStack.remove(context)) {
      Logger.debug(
        'ImprovedTracingManager: Removed specific page context: $context. Stack size: ${_pageContextStack.length}',
        tag: 'ImprovedTracingManager',
      );
    }
  }

  /// 创建操作上下文
  EnhancedTracingContext createOperationContext({
    required String source,
    required String action,
    String? description,
    String? entityId,
    String? parentId,
  }) {
    final id = _uuid.v4();
    final context = EnhancedTracingContext(
      id: id,
      parentId: parentId,
      startTime: DateTime.now(),
      source: source,
      action: action,
      description: description,
      entityId: entityId,
    );

    return context;
  }

  /// 执行带追踪的操作（支持并发）
  Future<T> scopeOperation<T>(
    EnhancedTracingContext context,
    Future<T> Function() operation,
  ) async {
    // 开始操作
    _activeContexts[context.id] = context;
    Logger.debug(
      'ImprovedTracingManager: Started operation: ${context.description}. Active operations: ${_activeContexts.length}',
      tag: 'ImprovedTracingManager',
    );

    try {
      final result = await operation();

      // 操作成功完成
      final completedContext = context.markCompleted();
      _activeContexts.remove(context.id);
      _addToHistory(completedContext);

      Logger.debug(
        'ImprovedTracingManager: Completed operation: ${completedContext.description}. Duration: ${completedContext.duration?.inMilliseconds}ms',
        tag: 'ImprovedTracingManager',
      );

      return result;
    } catch (error) {
      // 操作失败
      final failedContext = context.markCompleted();
      _activeContexts.remove(context.id);
      _addToHistory(failedContext);

      Logger.error(
        'ImprovedTracingManager: Failed operation: ${failedContext.description}. Duration: ${failedContext.duration?.inMilliseconds}ms. Error: $error',
        tag: 'ImprovedTracingManager',
      );

      rethrow;
    }
  }

  /// 便利方法：基于当前页面上下文创建操作
  Future<T> scopeActionWithTitle<T>(
    String actionTitle,
    Future<T> Function() action, {
    String? entityId,
    String? parentId,
  }) async {
    final pageContext =
        currentPageContext ??
        const TracingContext(
          source: 'unknown',
          action: 'unknown',
          description: '未知页面',
        );

    // 智能提取页面的有效名称
    String pageBaseName = pageContext.description ?? '未知页面';

    // 1. 去掉 "(via xxx)" 后缀
    final viaMatch = RegExp(r'\s*\(via\s+[^)]+\)').firstMatch(pageBaseName);
    if (viaMatch != null) {
      pageBaseName = pageBaseName.substring(0, viaMatch.start).trim();
    }

    // 2. 处理复合页面名称，如 "验收申请 - 首页"，提取实际的功能页面名称
    final parts = pageBaseName.split(' - ');
    String effectivePageName = pageBaseName;

    if (parts.length > 1) {
      // 如果有多个部分，优先选择非"首页"的部分
      final nonHomeParts = parts.where((part) => part.trim() != '首页').toList();
      if (nonHomeParts.isNotEmpty) {
        effectivePageName = nonHomeParts.first.trim();
      }
    }

    // 3. 生成最终描述
    String finalDescription;
    if (effectivePageName == '首页' || effectivePageName == '未知页面') {
      // 如果页面名称是首页或未知，直接使用操作标题
      finalDescription = actionTitle;
    } else {
      // 否则组合页面名称和操作标题
      finalDescription = '$effectivePageName - $actionTitle';
    }

    final operationContext = createOperationContext(
      source: pageContext.source,
      action: 'user-action',
      description: finalDescription,
      entityId: entityId,
      parentId: parentId,
    );

    return scopeOperation(operationContext, action);
  }

  /// 向后兼容方法：支持老的 TracingContext 参数格式
  Future<T> scopeAction<T>(
    TracingContext context,
    Future<T> Function() action,
  ) async {
    return scopeActionWithTitle(
      context.description ?? '${context.source}_${context.action}',
      action,
    );
  }

  /// 获取当前上下文（向后兼容）
  TracingContext? get currentContext => currentPageContext;

  /// 添加到历史记录
  void _addToHistory(EnhancedTracingContext context) {
    _completedContexts.addLast(context);

    // 保持历史记录大小限制
    while (_completedContexts.length > _maxHistorySize) {
      _completedContexts.removeFirst();
    }
  }

  /// 获取操作链（父子关系）
  List<EnhancedTracingContext> getOperationChain(String operationId) {
    final chain = <EnhancedTracingContext>[];

    // 从历史记录中查找
    final allContexts = [..._completedContexts, ..._activeContexts.values];

    EnhancedTracingContext? current = allContexts
        .cast<EnhancedTracingContext?>()
        .firstWhere((c) => c?.id == operationId, orElse: () => null);

    while (current != null) {
      chain.insert(0, current);
      if (current.parentId != null) {
        current = allContexts.cast<EnhancedTracingContext?>().firstWhere(
          (c) => c?.id == current?.parentId,
          orElse: () => null,
        );
      } else {
        break;
      }
    }

    return chain;
  }

  /// 取消活跃操作
  void cancelOperation(String operationId) {
    final context = _activeContexts.remove(operationId);
    if (context != null) {
      final cancelledContext = context.markCompleted();
      _addToHistory(cancelledContext);
      Logger.debug(
        'ImprovedTracingManager: Cancelled operation: ${cancelledContext.description}',
        tag: 'ImprovedTracingManager',
      );
    }
  }

  /// 清理所有上下文
  void clear() {
    _activeContexts.clear();
    _completedContexts.clear();
    _pageContextStack.clear();
    Logger.debug(
      'ImprovedTracingManager: Cleared all contexts',
      tag: 'ImprovedTracingManager',
    );
  }

  /// 获取性能统计
  Map<String, dynamic> getPerformanceStats() {
    final recentOperations = _completedContexts
        .where(
          (c) =>
              c.endTime != null &&
              DateTime.now().difference(c.endTime!).inMinutes < 5,
        )
        .toList();

    if (recentOperations.isEmpty) {
      return {'message': 'No recent operations'};
    }

    final durations = recentOperations
        .map((c) => c.duration?.inMilliseconds ?? 0)
        .where((d) => d > 0)
        .toList();

    if (durations.isEmpty) {
      return {'message': 'No duration data available'};
    }

    durations.sort();

    return {
      'totalOperations': recentOperations.length,
      'averageDuration': durations.reduce((a, b) => a + b) / durations.length,
      'medianDuration': durations[durations.length ~/ 2],
      'minDuration': durations.first,
      'maxDuration': durations.last,
      'activeOperations': _activeContexts.length,
    };
  }

  /// 私有构造函数，确保单例
  ImprovedTracingManager._internal();

  /// 获取单例实例
  static final ImprovedTracingManager _instance =
      ImprovedTracingManager._internal();

  /// 工厂构造函数，每次调用都返回同一个实例
  factory ImprovedTracingManager() => _instance;
}
