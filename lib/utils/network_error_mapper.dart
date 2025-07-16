/*
 * @Author: LeeZB
 * @Date: 2025-07-15 19:14:50
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-15 19:14:50
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:dio/dio.dart';
import 'logger.dart';

/// 网络错误映射器
/// 负责将DioException转换为用户友好的错误信息
/// 同时记录详细的开发日志
class NetworkErrorMapper {
  /// 默认错误消息映射
  static const Map<int, String> _statusCodeMessages = {
    400: '请求参数错误',
    401: '未授权访问',
    403: '禁止访问',
    404: '请求的资源不存在',
    405: '请求方法不被允许',
    408: '请求超时',
    429: '请求过于频繁，请稍后再试',
    500: '服务器内部错误',
    502: '网关错误',
    503: '服务暂时不可用',
    504: '网关超时',
  };

  /// 将DioException转换为用户友好的错误信息
  static String mapError(DioException error) {
    try {
      // 记录原始错误信息用于开发调试
      _logOriginalError(error);
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return '连接超时，请检查网络连接';
        case DioExceptionType.sendTimeout:
          return '请求发送超时，请重试';
        case DioExceptionType.receiveTimeout:
          return '响应接收超时，请重试';
        case DioExceptionType.badResponse:
          return _handleBadResponse(error);
        case DioExceptionType.cancel:
          return '请求已取消';
        case DioExceptionType.connectionError:
          return '网络连接错误，请检查网络设置';
        case DioExceptionType.badCertificate:
          return '证书验证失败';
        case DioExceptionType.unknown:
          return '网络请求失败，请稍后重试';
      }
    } catch (e) {
      // 如果错误映射过程中出现异常，记录日志但不抛出
      Logger.error('错误映射过程中发生异常', tag: 'NetworkErrorMapper', error: e);
      return '网络请求失败，请稍后重试';
    }
  }

  /// 处理badResponse类型的错误
  static String _handleBadResponse(DioException error) {
    final response = error.response;
    
    if (response == null) {
      return '服务器响应异常';
    }

    final statusCode = response.statusCode ?? 0;
    
    // 尝试从响应中解析错误信息
    String? serverMessage;
    try {
      serverMessage = _extractServerMessage(response);
    } catch (e) {
      Logger.error('解析服务器错误消息时发生类型转换错误: statusCode=$statusCode, responseType=${response.data.runtimeType.toString()}', 
        tag: 'NetworkErrorMapper', 
        error: e
      );
    }

    // 如果成功解析到服务器消息，使用服务器消息
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    // 否则使用状态码映射
    final mappedMessage = _statusCodeMessages[statusCode];
    if (mappedMessage != null) {
      return mappedMessage;
    }

    // 最后回退到通用错误消息
    return '服务器错误 ($statusCode)';
  }

  /// 安全地从响应中提取服务器错误消息
  static String? _extractServerMessage(Response response) {
    final data = response.data;
    
    if (data == null) {
      return null;
    }

    // 如果响应数据是Map类型
    if (data is Map<String, dynamic>) {
      // 尝试常见的错误消息字段
      final possibleMessageFields = ['message', 'msg', 'error', 'detail'];
      
      for (final field in possibleMessageFields) {
        final value = data[field];
        if (value != null) {
          return value.toString();
        }
      }
    }
    
    // 如果响应数据是String类型
    if (data is String) {
      return data;
    }

    // 其他情况返回null
    return null;
  }

  /// 记录原始错误信息用于开发调试
  static void _logOriginalError(DioException error) {
    final errorDetails = [
      'type: ${error.type.toString()}',
      'message: ${error.message}',
      'statusCode: ${error.response?.statusCode}',
      'method: ${error.requestOptions.method}',
      'url: ${error.requestOptions.uri.toString()}',
      'responseDataType: ${error.response?.data.runtimeType.toString()}',
    ].join(', ');

    Logger.error('网络请求错误详情: $errorDetails', 
      tag: 'NetworkError',
      error: error
    );
  }

  /// 为特定接口添加自定义错误映射
  /// 预留扩展空间，后续可以根据不同接口定制错误信息
  static String mapErrorForEndpoint(DioException error, String endpoint) {
    // 记录接口特定的错误信息
    Logger.error('接口 $endpoint 发生错误', 
      tag: 'NetworkError',
      error: error
    );

    // 这里可以根据不同的endpoint返回不同的错误信息
    // 示例：
    switch (endpoint) {
      case '/wx/login/getCodeImg':
        if (error.response?.statusCode == 503) {
          return '验证码服务暂时不可用，请稍后重试';
        }
        break;
      case '/wx/sms/':
        if (error.response?.statusCode == 429) {
          return '短信发送过于频繁，请稍后再试';
        }
        break;
    }

    // 默认使用通用错误映射
    return mapError(error);
  }

  /// 检查是否为网络连接问题
  static bool isNetworkConnectivityError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
           error.type == DioExceptionType.connectionTimeout;
  }

  /// 检查是否为服务器错误（5xx）
  static bool isServerError(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode != null && statusCode >= 500 && statusCode < 600;
  }

  /// 检查是否为客户端错误（4xx）
  static bool isClientError(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode != null && statusCode >= 400 && statusCode < 500;
  }
}