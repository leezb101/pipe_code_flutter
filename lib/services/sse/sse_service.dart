/*
 * @Author: LeeZB
 * @Date: 2025-08-07 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-07 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:pipe_code_flutter/config/app_config.dart';
import 'package:pipe_code_flutter/models/notification/sse_message_vo.dart';
import 'package:pipe_code_flutter/models/notification/notification_message_vo.dart';
import 'package:pipe_code_flutter/services/notification/message_parser.dart';
import 'package:pipe_code_flutter/services/sse/sse_auth_helper.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

/// SSE连接状态
enum SseConnectionState {
  disconnected, // 未连接
  connecting, // 连接中
  connected, // 已连接
  reconnecting, // 重连中
  error, // 连接错误
}

/// SSE服务
/// 基于HTTP Client实现的服务端事件流连接服务
class SseService {
  static const String _tag = 'SSE_SERVICE';
  
  HttpClient? _httpClient;
  HttpClientRequest? _request;
  HttpClientResponse? _response;
  StreamSubscription? _responseSubscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  
  SseConnectionState _connectionState = SseConnectionState.disconnected;
  String? _lastEventId;
  DateTime? _lastMessageTime;
  int _retryCount = 0;
  
  // 连接配置
  static const Duration _connectionTimeout = Duration(seconds: 30);
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const int _maxRetryCount = 5;
  
  // 消息处理回调
  void Function(NotificationMessageVO)? _onMessageReceived;
  void Function(SseConnectionState)? _onConnectionStateChanged;
  void Function(String)? _onError;

  /// 获取当前连接状态
  SseConnectionState get connectionState => _connectionState;

  /// 检查是否已连接
  bool get isConnected => _connectionState == SseConnectionState.connected;

  /// 获取最后消息时间
  DateTime? get lastMessageTime => _lastMessageTime;

  /// 设置消息接收回调
  void setOnMessageReceived(void Function(NotificationMessageVO) callback) {
    _onMessageReceived = callback;
  }

  /// 设置连接状态变化回调
  void setOnConnectionStateChanged(void Function(SseConnectionState) callback) {
    _onConnectionStateChanged = callback;
  }

  /// 设置错误回调
  void setOnError(void Function(String) callback) {
    _onError = callback;
  }

  /// 建立SSE连接
  Future<bool> connect() async {
    if (_connectionState == SseConnectionState.connecting ||
        _connectionState == SseConnectionState.connected) {
      Logger.warning('SSE connection already in progress', tag: _tag);
      return true;
    }

    // 检查认证状态
    final hasPermission = await SseAuthHelper.hasNotificationPermission();
    if (!hasPermission) {
      final error = 'User does not have notification permission';
      Logger.warning(error, tag: _tag);
      _onError?.call(error);
      return false;
    }

    _updateConnectionState(SseConnectionState.connecting);
    _retryCount = 0;

    try {
      // 获取认证头
      final authHeaders = await SseAuthHelper.getAuthHeaders();
      if (authHeaders.isEmpty) {
        throw Exception('Failed to get authentication headers');
      }

      // 构建SSE URL
      final sseUrl = _buildSseUrl();
      Logger.info('Connecting to SSE: $sseUrl', tag: _tag);

      // 创建HTTP客户端
      _httpClient = HttpClient();
      
      // 创建请求
      final uri = Uri.parse(sseUrl);
      _request = await _httpClient!.getUrl(uri);
      
      // 设置请求头
      _request!.headers.set('Accept', 'text/event-stream');
      _request!.headers.set('Cache-Control', 'no-cache');
      _request!.headers.set('Connection', 'keep-alive');
      
      // 添加认证头
      authHeaders.forEach((key, value) {
        _request!.headers.set(key, value);
      });

      // 发送请求
      _response = await _request!.close().timeout(_connectionTimeout);

      // 检查响应状态
      if (_response!.statusCode != 200) {
        throw Exception('HTTP ${_response!.statusCode}: ${_response!.reasonPhrase}');
      }

      // 开始处理响应流
      _startProcessingResponse();

      // 启动心跳检测
      _startHeartbeat();

      _updateConnectionState(SseConnectionState.connected);
      Logger.info('SSE connection established successfully', tag: _tag);
      return true;
    } catch (e) {
      final error = 'Failed to connect to SSE: ${e.toString()}';
      Logger.error(error, tag: _tag);
      _updateConnectionState(SseConnectionState.error);
      _onError?.call(error);
      
      // 尝试重连
      _scheduleReconnect();
      return false;
    }
  }

  /// 断开SSE连接
  Future<void> disconnect() async {
    if (_connectionState == SseConnectionState.disconnected) {
      return;
    }

    Logger.info('Disconnecting SSE connection', tag: _tag);
    _updateConnectionState(SseConnectionState.disconnected);

    // 取消订阅
    await _responseSubscription?.cancel();
    _responseSubscription = null;

    // 关闭响应
    _response?.detachSocket().then((socket) {
      socket.destroy();
    });
    _response = null;

    // 关闭请求
    _request = null;

    // 关闭HTTP客户端
    _httpClient?.close();
    _httpClient = null;

    // 停止定时器
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    // 重置状态
    _retryCount = 0;
    _lastMessageTime = null;

    Logger.info('SSE connection disconnected', tag: _tag);
  }

  /// 重新连接
  Future<bool> reconnect() async {
    Logger.info('Reconnecting SSE...', tag: _tag);
    await disconnect();
    return connect();
  }

  /// 开始处理响应流
  void _startProcessingResponse() {
    if (_response == null) return;

    _responseSubscription = _response!
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) => _processSseLine(line),
          onError: (error) => _handleSseError(error),
          onDone: () => _handleSseDone(),
        );
  }

  /// 处理SSE行数据
  void _processSseLine(String line) {
    if (line.trim().isEmpty) {
      // 空行表示消息结束，处理累积的数据
      _processAccumulatedData();
      return;
    }

    // 解析SSE字段
    if (line.startsWith('data: ')) {
      _currentData = line.substring(6);
    } else if (line.startsWith('event: ')) {
      _currentEventType = line.substring(7);
    } else if (line.startsWith('id: ')) {
      _lastEventId = line.substring(4);
    } else if (line.startsWith('retry: ')) {
      // 处理重试时间
      final retryMs = int.tryParse(line.substring(7));
      if (retryMs != null) {
        // 可以根据服务器建议的重试时间调整
      }
    }
  }

  String? _currentEventType;
  String? _currentData;

  /// 处理累积的数据
  void _processAccumulatedData() {
    if (_currentEventType != null && _currentData != null) {
      try {
        Logger.debug('Received SSE event: $_currentEventType', tag: _tag);

        // 更新最后消息时间
        _lastMessageTime = DateTime.now();

        // 创建SSE消息对象
        final sseMessage = SseMessageVO(
          id: _lastEventId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          event: _currentEventType!,
          data: _currentData!,
          timestamp: _lastMessageTime,
        );

        // 解析消息
        final parser = MessageParserFactory.getParser(_currentEventType!);
        if (parser == null) {
          Logger.warning('No parser found for event type: $_currentEventType', tag: _tag);
          return;
        }

        final parseResult = parser.parse(sseMessage);
        if (parseResult.isFailure) {
          Logger.warning('Failed to parse message: ${parseResult.error}', tag: _tag);
          return;
        }

        // 检查消息是否已过期
        if (parseResult.message!.isExpired) {
          Logger.debug('Message expired, skipping: ${parseResult.message!.id}', tag: _tag);
          return;
        }

        // 回调处理消息
        _onMessageReceived?.call(parseResult.message!);

        // 重置重试计数
        _retryCount = 0;
      } catch (e) {
        Logger.error('Error processing SSE message: ${e.toString()}', tag: _tag);
        _onError?.call('Failed to process SSE message: ${e.toString()}');
      } finally {
        // 重置累积数据
        _currentEventType = null;
        _currentData = null;
      }
    }
  }

  /// 处理SSE错误
  void _handleSseError(dynamic error) {
    final errorMessage = error.toString();
    Logger.error('SSE connection error: $errorMessage', tag: _tag);
    
    _updateConnectionState(SseConnectionState.error);
    _onError?.call('SSE connection error: $errorMessage');
    
    // 尝试重连
    _scheduleReconnect();
  }

  /// 处理SSE连接完成
  void _handleSseDone() {
    Logger.info('SSE connection closed', tag: _tag);
    
    _updateConnectionState(SseConnectionState.disconnected);
    
    // 如果不是主动断开，尝试重连
    if (_connectionState != SseConnectionState.disconnected) {
      _scheduleReconnect();
    }
  }

  /// 安排重连
  void _scheduleReconnect() {
    if (_retryCount >= _maxRetryCount) {
      Logger.error('Max retry count reached, stopping reconnection', tag: _tag);
      _updateConnectionState(SseConnectionState.disconnected);
      _onError?.call('Failed to reconnect after $_maxRetryCount attempts');
      return;
    }

    _retryCount++;
    final delay = _reconnectDelay * _retryCount;
    
    Logger.info(
      'Scheduling reconnect attempt $_retryCount in ${delay.inSeconds} seconds',
      tag: _tag,
    );

    _updateConnectionState(SseConnectionState.reconnecting);
    
    _reconnectTimer = Timer(delay, () async {
      await connect();
    });
  }

  /// 启动心跳检测
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_connectionState == SseConnectionState.connected) {
        final now = DateTime.now();
        if (_lastMessageTime != null) {
          final timeSinceLastMessage = now.difference(_lastMessageTime!);
          if (timeSinceLastMessage > _heartbeatInterval * 2) {
            Logger.warning(
              'No message received for ${timeSinceLastMessage.inSeconds} seconds, reconnecting...',
              tag: _tag,
            );
            _scheduleReconnect();
          }
        }
      }
    });
  }

  /// 更新连接状态
  void _updateConnectionState(SseConnectionState newState) {
    if (_connectionState != newState) {
      Logger.info(
        'SSE connection state changed: ${_connectionState.name} -> ${newState.name}',
        tag: _tag,
      );
      _connectionState = newState;
      _onConnectionStateChanged?.call(newState);
    }
  }

  /// 构建SSE URL
  String _buildSseUrl() {
    final baseUrl = AppConfig.sseBaseUrl;
    
    // 构建查询参数
    final queryParams = <String, String>{};
    
    // 添加时间戳防止缓存
    queryParams['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
    
    // 构建URL
    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '$baseUrl?$queryString';
  }

  /// 获取连接统计信息
  Map<String, dynamic> getConnectionStats() {
    return {
      'state': _connectionState.name,
      'isConnected': isConnected,
      'retryCount': _retryCount,
      'lastMessageTime': _lastMessageTime?.toIso8601String(),
      'lastEventId': _lastEventId,
    };
  }

  /// 手动触发心跳检测
  void triggerHeartbeat() {
    if (_connectionState == SseConnectionState.connected) {
      Logger.debug('Manual heartbeat triggered', tag: _tag);
      // 这里可以发送心跳消息到服务器
    }
  }

  /// 释放资源
  void dispose() {
    disconnect();
    _onMessageReceived = null;
    _onConnectionStateChanged = null;
    _onError = null;
  }
}