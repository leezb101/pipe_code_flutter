import 'dart:convert';
import 'package:dio/dio.dart';
import 'logger.dart';

/// 专用网络请求日志处理器
/// 提供详细的网络请求和响应日志记录, 并调用Logger进行打印
class NetworkLogger {
  static const String _tag = 'NETWORK';

  /// 格式化JSON
  static String _formatJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  /// 检查是否为敏感头部信息
  static bool _isSensitiveHeader(String key) {
    final lowerKey = key.toLowerCase();
    return lowerKey.contains('authorization') ||
        lowerKey.contains('token') ||
        lowerKey.contains('password') ||
        lowerKey.contains('secret');
  }

  /// 创建Dio拦截器
  static InterceptorsWrapper createNetworkInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final startTime = DateTime.now();
        options.extra['start_time'] = startTime;

        // --- 构建请求日志 ---
        final method = options.method.toUpperCase();
        final url = options.uri.toString();

        var logBuilder = StringBuffer();
        logBuilder.writeln('┌─── 🌐 REQUEST ───');
        logBuilder.writeln('│ $method $url');

        if (options.headers.isNotEmpty) {
          logBuilder.writeln('│ Headers:');
          options.headers.forEach((key, value) {
            final displayValue = _isSensitiveHeader(key)
                ? '***'
                : value.toString();
            logBuilder.writeln('│   $key: $displayValue');
          });
        }

        if (options.queryParameters.isNotEmpty) {
          logBuilder.writeln('│ Query Parameters:');
          options.queryParameters.forEach((key, value) {
            logBuilder.writeln('│   $key: $value');
          });
        }

        if (options.data != null) {
          logBuilder.writeln('│ Body:');
          if (options.data is FormData) {
            logBuilder.writeln(
              '│   FormData with ${options.data.fields.length} fields and ${options.data.files.length} files',
            );
          } else {
            logBuilder.writeln(_formatJson(options.data));
          }
        }
        logBuilder.write('└─── REQUEST END ───');
        Logger.debug(logBuilder.toString(), tag: _tag);

        handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime =
            response.requestOptions.extra['start_time'] as DateTime?;
        final duration = startTime != null
            ? DateTime.now().difference(startTime)
            : Duration.zero;

        // --- 构建响应日志 ---
        final method = response.requestOptions.method.toUpperCase();
        final url = response.requestOptions.uri.toString();
        final statusCode = response.statusCode;
        final statusIcon =
            (statusCode != null && statusCode >= 200 && statusCode < 300)
            ? '✅'
            : '⚠️';

        var logBuilder = StringBuffer();
        logBuilder.writeln('┌─── 🌐 RESPONSE $statusIcon ───');
        logBuilder.writeln('│ $method $url');
        logBuilder.writeln(
          '│ Status: $statusCode | Duration: ${duration.inMilliseconds}ms',
        );

        if (response.data != null) {
          logBuilder.writeln('│ Body:');
          // 特殊处理验证码接口，但不再截断
          if (response.requestOptions.path.contains('/wx/login/getCodeImg') &&
              response.data is Map) {
            final Map data = response.data;
            final String? imageData = data['data'];
            if (imageData != null) {
              Logger.info(
                'Captcha Base64 data received, length: ${imageData.length}',
                tag: 'CAPTCHA',
              );
            }
          }
          logBuilder.writeln(_formatJson(response.data));
        }
        logBuilder.write('└─── RESPONSE END ───');
        Logger.debug(logBuilder.toString(), tag: _tag);

        handler.next(response);
      },
      onError: (error, handler) {
        final startTime = error.requestOptions.extra['start_time'] as DateTime?;
        final duration = startTime != null
            ? DateTime.now().difference(startTime)
            : null;

        // --- 构建错误日志 ---
        final method = error.requestOptions.method.toUpperCase();
        final url = error.requestOptions.uri.toString();

        var logBuilder = StringBuffer();
        logBuilder.writeln('┌─── 🌐 ERROR ❌ ───');
        logBuilder.writeln('│ $method $url');
        logBuilder.writeln('│ Error Type: ${error.type}');
        logBuilder.writeln('│ Message: ${error.message}');
        if (duration != null) {
          logBuilder.writeln('│ Duration: ${duration.inMilliseconds}ms');
        }
        if (error.response != null) {
          logBuilder.writeln('│ Status: ${error.response!.statusCode}');
          if (error.response!.data != null) {
            logBuilder.writeln('│ Response Body:');
            logBuilder.writeln(_formatJson(error.response!.data));
          }
        }
        logBuilder.write('└─── ERROR END ───');
        Logger.error(
          logBuilder.toString(),
          tag: _tag,
          error: error.error,
          stackTrace: error.stackTrace,
        );

        handler.next(error);
      },
    );
  }
}
