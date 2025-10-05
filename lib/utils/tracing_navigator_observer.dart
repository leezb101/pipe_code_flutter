import 'package:flutter/material.dart';
import '../config/service_locator.dart';
import '../config/tracing_route_mappings.dart';
import '../services/tracing/tracing_context.dart';
import '../services/tracing/improved_tracing_manager.dart';

/// 监听 Flutter 导航事件，并自动管理 [ImprovedTracingManager] 中的上下文。
///
/// 这个版本使用改进的追踪管理器，支持并发操作和更好的上下文管理。
class TracingNavigatorObserver extends NavigatorObserver {
  final ImprovedTracingManager _tracingManager =
      getIt<ImprovedTracingManager>();

  /// 存储 Route 到 TracingContext 的映射，用于页面退出时清理上下文
  final Expando<TracingContext> _routeContexts = Expando<TracingContext>();

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _createNavigationContextForRoute(route, 'push');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _completeNavigationContextForRoute(route, 'pop');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      _completeNavigationContextForRoute(oldRoute, 'replace_out');
    }
    if (newRoute != null) {
      _createNavigationContextForRoute(newRoute, 'replace_in');
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _completeNavigationContextForRoute(route, 'remove');
  }

  /// 为给定的路由创建导航追踪上下文
  void _createNavigationContextForRoute(
    Route<dynamic> route,
    String navigationAction,
  ) {
    final routeName = route.settings.name;
    if (routeName != null) {
      final tracingInfo = tracingRouteMappings[routeName];
      if (tracingInfo != null) {
        // 创建页面上下文
        final context = TracingContext(
          source: tracingInfo.source,
          action: 'enter_page',
          description: '${tracingInfo.description} (via $navigationAction)',
        );

        // 使用改进的追踪管理器压入页面上下文
        _tracingManager.pushPageContext(context);

        // 存储上下文用于后续清理
        _routeContexts[route] = context;
      }
    }
  }

  /// 完成给定路由的导航追踪上下文
  void _completeNavigationContextForRoute(
    Route<dynamic> route,
    String navigationAction,
  ) {
    final context = _routeContexts[route];
    if (context != null) {
      // 从改进的追踪管理器移除页面上下文
      _tracingManager.removePageContext(context);

      // 清除关联
      _routeContexts[route] = null;
    }
  }
}
