/*
 * @Author: LeeZB
 * @Date: 2025-07-12 18:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-12 18:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'logger.dart';

/// 专用网络请求日志处理器
/// 提供详细的网络请求和响应日志记录
class NetworkLogger {
  static const String _tag = 'NETWORK';
  
  // ANSI颜色代码
  static const String _reset = '\x1B[0m';
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _cyan = '\x1B[36m';
  static const String _magenta = '\x1B[35m';
  static const String _gray = '\x1B[37m';

  /// 记录网络请求开始
  static void logRequest(RequestOptions options) {
    if (!kDebugMode) return;

    final method = options.method.toUpperCase();
    final url = options.uri.toString();
    final timestamp = DateTime.now().toIso8601String();
    
    final requestId = _generateRequestId(options);
    
    debugPrint('$_blue┌─── 🌐 REQUEST [$requestId] $_reset');
    debugPrint('$_blue│ $_cyan$method $_blue$url$_reset');
    debugPrint('$_blue│ Time: $_gray$timestamp$_reset');
    
    // 记录请求头
    if (options.headers.isNotEmpty) {
      debugPrint('$_blue│ Headers:$_reset');
      options.headers.forEach((key, value) {
        // 过滤敏感信息
        final displayValue = _isSensitiveHeader(key) ? '***' : value.toString();
        debugPrint('$_blue│   $_gray$key: $_reset$displayValue');
      });
    }
    
    // 记录Query参数
    if (options.queryParameters.isNotEmpty) {
      debugPrint('$_blue│ Query Parameters:$_reset');
      options.queryParameters.forEach((key, value) {
        debugPrint('$_blue│   $_gray$key: $_reset$value');
      });
    }
    
    // 记录请求体
    if (options.data != null) {
      debugPrint('$_blue│ Body:$_reset');
      final bodyString = _formatRequestBody(options.data);
      if (bodyString.isNotEmpty) {
        bodyString.split('\n').forEach((line) {
          debugPrint('$_blue│   $_reset$line');
        });
      }
    }
    
    debugPrint('$_blue└─── REQUEST END$_reset');
    debugPrint('');
  }

  /// 记录网络响应
  static void logResponse(Response response, Duration duration) {
    if (!kDebugMode) return;

    final method = response.requestOptions.method.toUpperCase();
    final url = response.requestOptions.uri.toString();
    final statusCode = response.statusCode;
    final requestId = _generateRequestId(response.requestOptions);
    
    // 根据状态码选择颜色
    String statusColor;
    String statusIcon;
    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      statusColor = _green;
      statusIcon = '✅';
    } else if (statusCode != null && statusCode >= 400) {
      statusColor = _red;
      statusIcon = '❌';
    } else {
      statusColor = _yellow;
      statusIcon = '⚠️';
    }
    
    debugPrint('$statusColor┌─── 🌐 RESPONSE [$requestId] $statusIcon $_reset');
    debugPrint('$statusColor│ $_cyan$method $_blue$url$_reset');
    debugPrint('$statusColor│ Status: $statusColor$statusCode$_reset');
    debugPrint('$statusColor│ Duration: $_magenta${duration.inMilliseconds}ms$_reset');
    
    // 记录响应头
    if (response.headers.map.isNotEmpty) {
      debugPrint('$statusColor│ Headers:$_reset');
      response.headers.map.forEach((key, values) {
        final value = values.isNotEmpty ? values.first : '';
        debugPrint('$statusColor│   $_gray$key: $_reset$value');
        
        // 特别标记验证码相关的header
        if (key.toLowerCase() == 'img_code') {
          debugPrint('$statusColor│   $_green🔑 Captcha Code Found: $_yellow$value$_reset');
        }
      });
    }
    
    // 记录响应体
    if (response.data != null) {
      debugPrint('$statusColor│ Body:$_reset');
      final bodyString = _formatResponseBody(response.data, response.requestOptions.path);
      if (bodyString.isNotEmpty) {
        bodyString.split('\n').forEach((line) {
          debugPrint('$statusColor│   $_reset$line');
        });
      }
    }
    
    debugPrint('$statusColor└─── RESPONSE END$_reset');
    debugPrint('');
    
    // 记录到Logger系统
    Logger.api(
      '$statusIcon $method $url - ${statusCode ?? 'NO_STATUS'} (${duration.inMilliseconds}ms)',
      endpoint: response.requestOptions.path,
    );
  }

  /// 记录网络错误
  static void logError(DioException error, Duration? duration) {
    if (!kDebugMode) return;

    final method = error.requestOptions.method.toUpperCase();
    final url = error.requestOptions.uri.toString();
    final requestId = _generateRequestId(error.requestOptions);
    
    debugPrint('$_red┌─── 🌐 ERROR [$requestId] ❌ $_reset');
    debugPrint('$_red│ $_cyan$method $_blue$url$_reset');
    debugPrint('$_red│ Error Type: $_yellow${error.type}$_reset');
    debugPrint('$_red│ Message: $_reset${error.message}');
    
    if (duration != null) {
      debugPrint('$_red│ Duration: $_magenta${duration.inMilliseconds}ms$_reset');
    }
    
    if (error.response != null) {
      debugPrint('$_red│ Status: $_red${error.response!.statusCode}$_reset');
      if (error.response!.data != null) {
        debugPrint('$_red│ Response Body:$_reset');
        final bodyString = _formatResponseBody(error.response!.data, error.requestOptions.path);
        bodyString.split('\n').forEach((line) {
          debugPrint('$_red│   $_reset$line');
        });
      }
    }
    
    debugPrint('$_red└─── ERROR END$_reset');
    debugPrint('');
    
    // 记录到Logger系统
    Logger.error(
      'Network Error: $method $url - ${error.type}',
      tag: _tag,
      error: error,
    );
  }

  /// 格式化请求体
  static String _formatRequestBody(dynamic data) {
    if (data == null) return '';
    
    try {
      if (data is Map || data is List) {
        return _formatJson(data);
      } else if (data is FormData) {
        return 'FormData with ${data.fields.length} fields and ${data.files.length} files';
      } else {
        return data.toString();
      }
    } catch (e) {
      return 'Failed to format request body: $e';
    }
  }

  /// 格式化响应体
  static String _formatResponseBody(dynamic data, String? path) {
    if (data == null) return '';
    
    try {
      if (data is Map || data is List) {
        final jsonString = _formatJson(data);
        
        // 特殊处理验证码接口
        if (path?.contains('/wx/login/getCodeImg') == true && data is Map) {
          final dataField = data['data'];
          if (dataField is String && dataField.isNotEmpty) {
            // 截断base64数据显示
            final truncatedData = dataField.length > 50 
                ? '${dataField.substring(0, 50)}...(${dataField.length} chars total)'
                : dataField;
            
            final modifiedData = Map.from(data);
            modifiedData['data'] = truncatedData;
            
            return '${_formatJson(modifiedData)}\n$_green🖼️ Base64 Image Data: ${dataField.length} characters$_reset';
          }
        }
        
        return jsonString;
      } else {
        return data.toString();
      }
    } catch (e) {
      return 'Failed to format response body: $e';
    }
  }

  /// 格式化JSON
  static String _formatJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  /// 完整打印JSON数据（用于调试）
  /// 这个方法专门用于完整查看API响应，不会被截断
  static void printFullJson(dynamic data, {String title = 'JSON_DATA'}) {
    if (!kDebugMode) return;
    
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(data);
      
      debugPrint('$_cyan┌─── 📋 $title $_reset');
      debugPrint('$_cyan│$_reset');
      
      // 按行分割打印，确保完整显示
      jsonString.split('\n').forEach((line) {
        debugPrint('$_cyan│ $_reset$line');
      });
      
      debugPrint('$_cyan│$_reset');
      debugPrint('$_cyan└─── END $title $_reset');
      debugPrint('');
      
    } catch (e) {
      debugPrint('$_red❌ Failed to print JSON: $e$_reset');
      debugPrint('$_yellow📝 Raw data: ${data.toString()}$_reset');
    }
  }


  /// 生成请求ID
  static String _generateRequestId(RequestOptions options) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final method = options.method.substring(0, 1);
    final pathHash = options.path.hashCode.abs() % 1000;
    return '$method$pathHash-$timestamp';
  }

  /// 检查是否为敏感头部信息
  static bool _isSensitiveHeader(String key) {
    final lowerKey = key.toLowerCase();
    return lowerKey.contains('authorization') ||
           lowerKey.contains('token') ||
           lowerKey.contains('password') ||
           lowerKey.contains('secret');
  }

  /// 创建自定义网络拦截器
  static InterceptorsWrapper createNetworkInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final startTime = DateTime.now();
        options.extra['start_time'] = startTime;
        
        logRequest(options);
        handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime = response.requestOptions.extra['start_time'] as DateTime?;
        final duration = startTime != null 
            ? DateTime.now().difference(startTime)
            : Duration.zero;
            
        logResponse(response, duration);
        handler.next(response);
      },
      onError: (error, handler) {
        final startTime = error.requestOptions.extra['start_time'] as DateTime?;
        final duration = startTime != null 
            ? DateTime.now().difference(startTime)
            : null;
            
        logError(error, duration);
        handler.next(error);
      },
    );
  }

  /// 验证图形验证码响应的特殊处理
  static void logCaptchaResponse(Response response) {
    if (!kDebugMode) return;
    
    debugPrint('$_magenta┌─── 🔍 CAPTCHA ANALYSIS $_reset');
    
    // 检查header中的img_code
    final imgCode = response.headers.value('img_code');
    if (imgCode != null) {
      debugPrint('$_magenta│ $_green✅ img_code header found: $_yellow$imgCode$_reset');
    } else {
      debugPrint('$_magenta│ $_red❌ img_code header NOT found$_reset');
      debugPrint('$_magenta│ $_gray Available headers:$_reset');
      response.headers.map.forEach((key, values) {
        debugPrint('$_magenta│   $_gray$key: ${values.first}$_reset');
      });
    }
    
    // 检查响应体中的data字段
    if (response.data is Map) {
      final data = response.data as Map;
      final imageData = data['data'];
      if (imageData is String && imageData.isNotEmpty) {
        debugPrint('$_magenta│ $_green✅ Base64 image data found: ${imageData.length} characters$_reset');
        
        // 验证base64格式
        try {
          base64Decode(imageData);
          debugPrint('$_magenta│ $_green✅ Base64 data is valid$_reset');
        } catch (e) {
          debugPrint('$_magenta│ $_red❌ Base64 data is invalid: $e$_reset');
        }
      } else {
        debugPrint('$_magenta│ $_red❌ No valid image data in response body$_reset');
      }
    }
    
    debugPrint('$_magenta└─── CAPTCHA ANALYSIS END$_reset');
    debugPrint('');
  }
}