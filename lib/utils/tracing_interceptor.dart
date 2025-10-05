import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import '../config/service_locator.dart';
import '../services/tracing/improved_tracing_manager.dart';

class TracingInterceptor extends Interceptor {
  final String headerKey;

  TracingInterceptor({this.headerKey = 'trace-link'});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 使用改进的追踪管理器获取当前上下文
    final improvedTracingManager = getIt<ImprovedTracingManager>();

    // 优先获取当前活跃操作的上下文，如果没有则使用页面上下文
    final activeOperations = improvedTracingManager.activeOperations;
    final pageContext = improvedTracingManager.currentPageContext;

    // 选择最具体的上下文：活跃操作 > 页面上下文
    String? contextDescription;
    Map<String, dynamic>? contextJson;

    if (activeOperations.isNotEmpty) {
      // 使用最近开始的活跃操作（通常是当前正在执行的操作）
      final latestOperation = activeOperations.reduce(
        (a, b) => a.startTime.isAfter(b.startTime) ? a : b,
      );
      contextDescription = latestOperation.description;
      contextJson = {
        'source': latestOperation.source,
        'action': latestOperation.action,
        'description': latestOperation.description,
        'operationId': latestOperation.id,
      };
    } else if (pageContext != null) {
      // 后备：使用页面上下文
      contextDescription = pageContext.description;
      contextJson = pageContext.toJson();
    }

    Logger.debug(
      'TracingInterceptor - Current context: $contextDescription',
      tag: 'TracingInterceptor',
    );

    if (contextDescription != null && contextJson != null) {
      final contextJsonString = jsonEncode(contextJson);
      final contextUriEncode = Uri.encodeComponent(contextJsonString);
      options.headers[headerKey] = Uri.encodeComponent(contextDescription);
      options.headers['trace-from'] = 'App';

      Logger.debug(
        'TracingInterceptor - Added tracing header: $headerKey: $contextUriEncode',
        tag: 'TracingInterceptor',
      );
    }
    super.onRequest(options, handler);
  }
}
