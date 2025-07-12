import 'package:flutter/foundation.dart';
import 'dart:convert';

enum LogLevel { debug, info, warning, error }

class Logger {
  static const String _name = 'PipeCodeLogger';

  // ANSI color codes for console output
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _gray = '\x1B[37m';

  /// Debug level logging - only shown in development mode
  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Info level logging - only shown in development mode
  static void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Warning level logging - shown in all environments
  static void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Error level logging - shown in all environments
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Skip debug and info logs in production unless in debug mode
    if ((level == LogLevel.debug || level == LogLevel.info) && !kDebugMode) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelString = _getLevelString(level);
    final color = _getLevelColor(level);
    final tagString = tag != null ? '[$tag] ' : '';

    final logMessage =
        '$color[$timestamp] [$_name] $levelString $tagString$message$_reset';

    // Use debugPrint to avoid issues in release mode
    debugPrint(logMessage);

    if (error != null) {
      debugPrint(
        '$color[$timestamp] [$_name] $levelString ${tagString}Error: $error$_reset',
      );
    }

    if (stackTrace != null && level == LogLevel.error) {
      debugPrint(
        '$color[$timestamp] [$_name] $levelString ${tagString}StackTrace: $stackTrace$_reset',
      );
    }
  }

  static String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARN]';
      case LogLevel.error:
        return '[ERROR]';
    }
  }

  static String _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return _gray;
      case LogLevel.info:
        return _blue;
      case LogLevel.warning:
        return _yellow;
      case LogLevel.error:
        return _red;
    }
  }

  /// Log QR scan related operations
  static void qrScan(String message, {String? deviceCode}) {
    final tag = deviceCode != null ? 'QR_SCAN:$deviceCode' : 'QR_SCAN';
    debug(message, tag: tag);
  }

  /// Log API related operations
  static void api(String message, {String? endpoint}) {
    final tag = endpoint != null ? 'API:$endpoint' : 'API';
    debug(message, tag: tag);
  }

  /// Log business logic operations
  static void business(String message, {String? module}) {
    final tag = module != null ? 'BUSINESS:$module' : 'BUSINESS';
    info(message, tag: tag);
  }

  /// Log user actions
  static void userAction(String message, {String? action}) {
    final tag = action != null ? 'USER:$action' : 'USER';
    info(message, tag: tag);
  }

  /// Log authentication related operations
  static void auth(String message) {
    info(message, tag: 'AUTH');
  }

  /// Log navigation related operations
  static void navigation(String message, {String? route}) {
    final tag = route != null ? 'NAV:$route' : 'NAV';
    debug(message, tag: tag);
  }

  /// Enhanced network logging methods
  
  /// Log network request details
  static void networkRequest(String method, String url, {
    Map<String, dynamic>? headers,
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) {
    final details = <String>[];
    details.add('$method $url');
    
    if (queryParams != null && queryParams.isNotEmpty) {
      details.add('Query: $queryParams');
    }
    if (headers != null && headers.isNotEmpty) {
      // Filter sensitive headers
      final filteredHeaders = Map<String, dynamic>.from(headers);
      filteredHeaders.removeWhere((key, value) => 
          key.toLowerCase().contains('authorization') ||
          key.toLowerCase().contains('token'));
      details.add('Headers: $filteredHeaders');
    }
    if (body != null) {
      details.add('Body: ${_truncateData(body.toString())}');
    }
    
    debug('REQUEST: ${details.join(' | ')}', tag: 'NETWORK');
  }

  /// Log network response details
  static void networkResponse(String method, String url, int? statusCode, 
      {Duration? duration, dynamic responseBody, Map<String, List<String>>? headers}) {
    final details = <String>[];
    details.add('$method $url');
    details.add('Status: ${statusCode ?? 'UNKNOWN'}');
    
    if (duration != null) {
      details.add('Duration: ${duration.inMilliseconds}ms');
    }
    
    // Check for special headers like img_code
    if (headers != null) {
      final imgCode = headers['img_code']?.first;
      if (imgCode != null) {
        details.add('ImgCode: $imgCode');
      }
    }
    
    if (responseBody != null) {
      details.add('Response: ${_truncateData(responseBody.toString())}');
    }
    
    final icon = (statusCode != null && statusCode >= 200 && statusCode < 300) ? '✅' : '❌';
    debug('RESPONSE $icon: ${details.join(' | ')}', tag: 'NETWORK');
  }

  /// Log network errors
  static void networkError(String method, String url, String errorType, 
      {String? message, int? statusCode, Duration? duration}) {
    final details = <String>[];
    details.add('$method $url');
    details.add('Error: $errorType');
    
    if (statusCode != null) {
      details.add('Status: $statusCode');
    }
    if (duration != null) {
      details.add('Duration: ${duration.inMilliseconds}ms');
    }
    if (message != null) {
      details.add('Message: $message');
    }
    
    error('NETWORK ERROR ❌: ${details.join(' | ')}', tag: 'NETWORK');
  }

  /// Log captcha-specific operations
  static void captcha(String message, {String? imgCode, int? dataSize}) {
    final details = <String>[message];
    
    if (imgCode != null) {
      details.add('ImgCode: $imgCode');
    }
    if (dataSize != null) {
      details.add('DataSize: ${dataSize}B');
    }
    
    info('CAPTCHA 🔑: ${details.join(' | ')}', tag: 'AUTH');
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration, {String? details}) {
    final message = '$operation took ${duration.inMilliseconds}ms';
    final fullMessage = details != null ? '$message - $details' : message;
    debug('PERFORMANCE ⚡: $fullMessage', tag: 'PERF');
  }

  /// Truncate data for logging to avoid excessive output
  static String _truncateData(String data, {int maxLength = 200}) {
    if (data.length <= maxLength) return data;
    return '${data.substring(0, maxLength)}...(${data.length} chars total)';
  }

  /// Log JSON data with formatting
  static void json(String tag, dynamic data, {LogLevel level = LogLevel.debug}) {
    try {
      final jsonString = data is String ? data : 
          const JsonEncoder.withIndent('  ').convert(data);
      _log(level, 'JSON Data:\n$jsonString', tag: tag);
    } catch (e) {
      _log(level, 'Failed to format JSON: $e', tag: tag);
    }
  }
}
