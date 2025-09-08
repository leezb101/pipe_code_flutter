/*
 * @Author: LeeZB
 * @Date: 2025-08-07 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-07 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:async';
import 'dart:convert';
import 'package:eventflux/eventflux.dart';
import 'package:pipe_code_flutter/config/app_config.dart';
import 'package:pipe_code_flutter/models/notification/sse_message_vo.dart';
import 'package:pipe_code_flutter/models/notification/notification_message_vo.dart';
import 'package:pipe_code_flutter/services/notification/message_parser.dart';
import 'package:pipe_code_flutter/services/notification/event_type_converter.dart';
import 'package:pipe_code_flutter/services/notification/notification_center.dart';
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
/// 基于EventFlux实现的服务端事件流连接服务
class SseService {
  static const String _tag = 'SSE_SERVICE';

  EventFlux? _eventFlux;
  StreamSubscription<EventFluxData>? _messageSubscription;

  SseConnectionState _connectionState = SseConnectionState.disconnected;
  String? _lastEventId;
  DateTime? _lastMessageTime;
  int _retryCount = 0;

  // 连接配置
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

      // 创建EventFlux实例
      _eventFlux = EventFlux.spawn();

      // 建立连接
      _eventFlux!.connect(
        EventFluxConnectionType.get,
        sseUrl,
        header: authHeaders,
        onSuccessCallback: (response) {
          _updateConnectionState(SseConnectionState.connected);
          Logger.info('SSE connection established successfully', tag: _tag);

          // 开始监听消息流
          _startListeningToMessages(response);
        },
        onConnectionClose: () {
          Logger.info('SSE connection closed', tag: _tag);
          _updateConnectionState(SseConnectionState.disconnected);
        },
        onError: (error) {
          final errorMessage = 'SSE connection error: ${error.toString()}';
          Logger.error(errorMessage, tag: _tag);
          _updateConnectionState(SseConnectionState.error);
          _onError?.call(errorMessage);
        },
        autoReconnect: true,
        reconnectConfig: ReconnectConfig(
          mode: ReconnectMode.linear,
          interval: const Duration(seconds: 5),
          maxAttempts: _maxRetryCount,
        ),
      );

      return true;
    } catch (e) {
      final error = 'Failed to connect to SSE: ${e.toString()}';
      Logger.error(error, tag: _tag);
      _updateConnectionState(SseConnectionState.error);
      _onError?.call(error);
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

    // 取消消息订阅
    await _messageSubscription?.cancel();
    _messageSubscription = null;

    // 断开EventFlux连接
    _eventFlux?.disconnect();
    _eventFlux = null;

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

  /// 开始监听消息流
  void _startListeningToMessages(EventFluxResponse? response) {
    _messageSubscription = response?.stream?.listen(
      (data) {
        Logger.warning('SSE message received:\n $data \n', tag: _tag);
        if (data.id == '' || data.data == '') {
          return;
        }
        _processSseMessage(data);
      },
      onError: (error) {
        final errorMessage = 'SSE message error: ${error.toString()}';
        Logger.error(errorMessage, tag: _tag);
        _onError?.call(errorMessage);
      },
      onDone: () {
        Logger.info('SSE message stream closed', tag: _tag);
        _updateConnectionState(SseConnectionState.disconnected);
      },
    );
  }

  /// 处理SSE消息
  void _processSseMessage(EventFluxData data) {
    try {
      Logger.debug('Received SSE message: ${data.data}', tag: _tag);

      // 更新最后消息时间
      _lastMessageTime = DateTime.now();

      final dataContent = jsonDecode(data.data) as Map<String, dynamic>;
      // EventFlux已经解析了SSE格式，我们直接处理数据
      // 使用EventFluxData中的event和data字段
      // 将后端的事件类型（可能为int）转换为语义化字符串，供解析器选择
      final rawType = dataContent['type'];
      final convertedType = EventTypeConverter.convert(
        rawType,
        hint: data.event,
      );

      final sseMessage = SseMessageVO(
        msgId: data.id,
        type: rawType is int ? rawType : int.tryParse(rawType.toString()) ?? -1,
        name: data.event,
        extra: dataContent['extra'] as Map<String, dynamic>?,
        timestamp: _lastMessageTime,
      );

      // 解析消息
      final parser = MessageParserFactory.getParser(convertedType);
      if (parser == null) {
        Logger.warning(
          'No parser found for event type: ${sseMessage.type}',
          tag: _tag,
        );
        return;
      }

      final parseResult = parser.parse(sseMessage);
      if (parseResult.isFailure) {
        Logger.warning(
          'Failed to parse message: ${parseResult.error}',
          tag: _tag,
        );
        return;
      }

      // 检查消息是否已过期
      if (parseResult.message!.isExpired) {
        Logger.debug(
          'Message expired, skipping: ${parseResult.message!.id}',
          tag: _tag,
        );
        return;
      }

      // 回调处理消息
      final msg = parseResult.message!;
      _onMessageReceived?.call(msg);

      // 将todo消息发布到全局通知中心（用于批量刷新与浮窗）
      if (msg.type.toLowerCase() == 'todo') {
        NotificationCenter.instance.publish(msg);
      }

      // 重置重试计数
      _retryCount = 0;
    } catch (e) {
      Logger.error('Error processing SSE message: ${e.toString()}', tag: _tag);
      _onError?.call('Failed to process SSE message: ${e.toString()}');
    }
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
