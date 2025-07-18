import 'package:flutter/foundation.dart';
import 'dart:convert';

// 日志级别枚举
enum LogLevel { debug, info, warning, error }

/// 一个简单、清晰且能打印完整信息的日志记录器
class Logger {
  static const String _name = 'PipeCodeLogger';

  // 定义一个单行日志的最大长度，超过则换行
  static const int _maxLogWidth = 800;

  /// 打印分段日志，避免被IDE截断
  static void _printWrapped(String text) {
    final pattern = RegExp('.{1,$_maxLogWidth}'); // 正则表达式，用于分割字符串
    pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
  }

  /// 内部日志处理核心方法
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // 在非Debug模式下，不打印 debug 和 info 级别的日志
    if (!kDebugMode && (level == LogLevel.debug || level == LogLevel.info)) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelString = _getLevelString(level);
    final tagString = tag != null ? '[$tag]' : '';

    // 组合成完整的日志信息
    final logMessage = '[$timestamp] [$_name] $levelString $tagString $message';
    _printWrapped(logMessage); // 使用分段打印

    if (error != null) {
      final errorLog =
          '[$timestamp] [$_name] $levelString $tagString ERROR: $error';
      _printWrapped(errorLog);
    }

    if (stackTrace != null && level == LogLevel.error) {
      final stackTraceLog =
          '[$timestamp] [$_name] $levelString $tagString STACKTRACE:\n$stackTrace';
      _printWrapped(stackTraceLog);
    }
  }

  // --- 公共日志方法 ---

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

  /// 打印格式化后的JSON数据，不会被截断
  static void json(
    String tag,
    dynamic data, {
    LogLevel level = LogLevel.debug,
  }) {
    try {
      final jsonString = data is String
          ? data
          : const JsonEncoder.withIndent('  ').convert(data);
      _log(level, 'JSON Data:\n$jsonString', tag: tag);
    } catch (e) {
      _log(LogLevel.error, 'Failed to format JSON: $e', tag: tag);
    }
  }

  // --- 辅助方法 ---

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

  // --- 业务快捷方式 (已加回 qrScan) ---
  static void api(String message, {String? endpoint}) {
    debug(message, tag: endpoint != null ? 'API:$endpoint' : 'API');
  }

  static void auth(String message) {
    info(message, tag: 'AUTH');
  }

  static void captcha(String message, {String? imgCode, int? dataSize}) {
    final details = <String>[message];
    if (imgCode != null) details.add('ImgCode: $imgCode');
    if (dataSize != null) details.add('DataSize: ${dataSize}B');
    info('CAPTCHA 🔑: ${details.join(' | ')}', tag: 'AUTH');
  }

  /// Log QR scan related operations
  static void qrScan(String message, {String? deviceCode}) {
    final tag = deviceCode != null ? 'QR_SCAN:$deviceCode' : 'QR_SCAN';
    debug(message, tag: tag);
  }
}
