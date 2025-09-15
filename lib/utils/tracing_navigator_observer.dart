import 'package:flutter/material.dart';
import '../config/tracing_route_mappings.dart';
import '../services/tracing/tracing_context.dart';
import '../services/tracing/tracing_manager.dart';
import 'logger.dart';

class TracingNavigatorObserver extends NavigatorObserver {
  final TracingManager _tracingManager = TracingManager();

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _addContextFromRoute(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _tracingManager.popContext();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _tracingManager.popContext();
    if (newRoute != null) {
      _addContextFromRoute(newRoute);
    }
  }

  void _addContextFromRoute(Route<dynamic> route) {
    final routePath = route.settings.name;
    if (routePath == null) return;

    final tracingInfo = tracingRouteMappings[routePath];

    if (tracingInfo != null) {
      // 如果找到路由对应的追踪信息，则创建并压入新的上下文
      final context = TracingContext(
        source: tracingInfo.source,
        action: 'enter_page',
        description: tracingInfo.description,
      );
      _tracingManager.pushContext(context);
      Logger.debug(
        'TracingNavigatorObserver: Pushed context for route $routePath: $context',
        tag: 'TracingNavigatorObserver',
      );
    }
  }
}
