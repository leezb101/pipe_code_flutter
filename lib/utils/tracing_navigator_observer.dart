import 'package:flutter/material.dart';
import '../config/service_locator.dart';
import '../config/tracing_route_mappings.dart';
import '../services/tracing/tracing_context.dart';
import '../services/tracing/tracing_manager.dart';

/// 监听 Flutter 导航事件，并自动管理 [TracingManager] 中的上下文堆栈。
///
/// 这个版本的 Observer 更加健壮，通过维护一个 Route 到 Context 的映射，
/// 能够精确处理 go_router 复杂的导航场景（如 `go` 替换）。
class TracingNavigatorObserver extends NavigatorObserver {
  final TracingManager _tracingManager = getIt<TracingManager>();

  /// 使用Expando将上下文附加到 Route 对象，避免内存泄露。
  /// Expando 允许我们将数据与对象关联起来，而不会组织该对象被垃圾回收
  final Expando<TracingContext> _routeContexts = Expando<TracingContext>();

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    // _addContextFromRoute(route);
    // _updateContextForRoute(route);
    _createAndPushContextForRoute(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _removeAndPopContextForRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    // _tracingManager.popContext();
    // if (newRoute != null) {
    // _addContextFromRoute(newRoute);
    // _updateContextForRoute(newRoute);
    // }
    if (oldRoute != null) {
      _removeAndPopContextForRoute(oldRoute);
    }
    if (newRoute != null) {
      _createAndPushContextForRoute(newRoute);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    // 在某些情况下，例如 `context.go` 替换根路由，`didRemove` 会被调用
    // 而 `didPush` 或 `didReplace` 可能不会。这里我们尝试添加新的上下文。
    // 注意：这可能需要根据具体的路由库行为进行调整。
    // 这里的逻辑假设当旧路由被移除后，新的路由（栈顶）就是当前页面。
    // if (navigator != null && navigator!.widget.pages.isNotEmpty) {
    //   final newRoute = navigator!.widget.pages.last.createRoute(
    //     navigator!.context,
    //   );
    //   _addContextFromRoute(newRoute);
    // }
    _removeAndPopContextForRoute(route);
  }

  /// 为给定的路由创建、关联并压入一个新的追踪上下文
  void _createAndPushContextForRoute(Route<dynamic> route) {
    final routeName = route.settings.name;
    if (routeName != null) {
      final tracingInfo = tracingRouteMappings[routeName];
      if (tracingInfo != null) {
        final context = TracingContext(
          source: tracingInfo.source,
          action: 'enter_page',
          description: tracingInfo.description,
        );
        _routeContexts[route] = context;
        _tracingManager.pushContext(context);
      }
    }
  }

  /// 为给定的路由移除关联，并从管理起中精确低移除对应的上下文
  void _removeAndPopContextForRoute(Route<dynamic> route) {
    final contextToRemove = _routeContexts[route];
    if (contextToRemove != null) {
      // 调用 TracingManager 的新方法来移除这个特定的上下文实例
      _tracingManager.removeContext(contextToRemove);
      // 清除关联（尽管Expando会自动处理，但显式清除是好习惯）
      _routeContexts[route] = null;
    }
  }
}
