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

    if (tracingContext != null) {
      final contextJson = jsonEncode(tracingContext.toJson());
      final contextBase64 = base64Url.encode(utf8.encode(contextJson));
      options.headers[headerKey] = contextBase64;

      Logger.debug(
        'TracingInterceptor: Added tracing header: $headerKey: $contextBase64',
        tag: 'TracingInterceptor',
      );
    }
    super.onRequest(options, handler);
  }
}
