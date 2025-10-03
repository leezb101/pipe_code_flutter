import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import '../services/tracing/tracing_manager.dart';

class TracingInterceptor extends Interceptor {
  final String headerKey;

  TracingInterceptor({this.headerKey = 'trace-link'});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final tracingContext = TracingManager().currentContext;

    Logger.debug(
      'TracingInterceptor - Current context: ${tracingContext?.description}',
      tag: 'TracingInterceptor',
    );

    if (tracingContext != null) {
      final contextJson = jsonEncode(tracingContext.toJson());
      final description = tracingContext.description ?? '未知操作';
      final contextUriEncode = Uri.encodeComponent(contextJson);
      options.headers[headerKey] = Uri.encodeComponent(description);
      options.headers['trace-from'] = 'App';

      Logger.debug(
        'TracingInterceptor - Added tracing header: $headerKey: $contextUriEncode',
        tag: 'TracingInterceptor',
      );
    }
    super.onRequest(options, handler);
  }
}
