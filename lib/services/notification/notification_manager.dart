/*
 * @Author: LeeZB
 * @Date: 2025-08-07 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-07 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:async';
import 'package:pipe_code_flutter/config/app_config.dart';
import 'package:pipe_code_flutter/models/notification/notification_message_vo.dart';
import 'package:pipe_code_flutter/services/notification/notification_dispatcher.dart';
import 'package:pipe_code_flutter/services/sse/sse_auth_helper.dart';
import 'package:pipe_code_flutter/services/sse/sse_service.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

/// 通知管理器状态
enum NotificationManagerState {
  idle, // 空闲
  starting, // 启动中
  running, // 运行中
  stopping, // 停止中
  stopped, // 已停止
  error, // 错误
}

/// 通知管理器
/// 负责协调SSE连接、消息处理和通知分发的中心组件
class NotificationManager {
  static const String _tag = 'NOTIFICATION_MANAGER';
  
  static NotificationManager? _instance;
  
  final SseService _sseService;
  final NotificationDispatcher _dispatcher;
  
  NotificationManagerState _state = NotificationManagerState.idle;
  Timer? _healthCheckTimer;
  Timer? _authRefreshTimer;
  
  // 统计信息
  int _totalMessagesReceived = 0;
  int _totalMessagesProcessed = 0;
  int _totalMessagesFailed = 0;
  DateTime? _startTime;
  DateTime? _lastActivityTime;

  /// 获取单例实例
  static NotificationManager get instance {
    _instance ??= NotificationManager._internal();
    return _instance!;
  }

  NotificationManager._internal()
      : _sseService = SseService(),
        _dispatcher = NotificationDispatcher() {
    _initialize();
  }

  /// 获取当前状态
  NotificationManagerState get state => _state;

  /// 检查是否正在运行
  bool get isRunning => _state == NotificationManagerState.running;

  /// 获取统计信息
  Map<String, dynamic> get stats {
    return {
      'state': _state.name,
      'isRunning': isRunning,
      'totalMessagesReceived': _totalMessagesReceived,
      'totalMessagesProcessed': _totalMessagesProcessed,
      'totalMessagesFailed': _totalMessagesFailed,
      'successRate': _totalMessagesReceived > 0 
          ? '${(_totalMessagesProcessed / _totalMessagesReceived * 100).toStringAsFixed(2)}%'
          : '0%',
      'startTime': _startTime?.toIso8601String(),
      'lastActivityTime': _lastActivityTime?.toIso8601String(),
      'uptime': _startTime != null 
          ? '${DateTime.now().difference(_startTime!)}' 
          : '0s',
      'sseConnection': _sseService.getConnectionStats(),
      'registeredHandlers': _dispatcher.registeredHandlers,
    };
  }

  /// 初始化
  void _initialize() {
    // 设置SSE服务回调
    _sseService.setOnMessageReceived(_handleMessageReceived);
    _sseService.setOnConnectionStateChanged(_handleConnectionStateChanged);
    _sseService.setOnError(_handleError);

    // 监听分发器事件
    _dispatcher.eventStream.listen(_handleDispatcherEvent);

    Logger.info('Notification manager initialized', tag: _tag);
  }

  /// 启动通知系统
  Future<bool> start() async {
    if (_state == NotificationManagerState.running || 
        _state == NotificationManagerState.starting) {
      Logger.warning('Notification manager is already starting or running', tag: _tag);
      return true;
    }

    _updateState(NotificationManagerState.starting);

    try {
      Logger.info('Starting notification manager...', tag: _tag);

      // 检查用户权限
      final hasPermission = await SseAuthHelper.hasNotificationPermission();
      if (!hasPermission) {
        final error = 'User does not have notification permission';
        Logger.warning(error, tag: _tag);
        _updateState(NotificationManagerState.error);
        return false;
      }

      // 获取用户信息
      final userInfo = await SseAuthHelper.getCurrentUser();
      if (userInfo == null) {
        final error = 'Failed to get user information';
        Logger.warning(error, tag: _tag);
        _updateState(NotificationManagerState.error);
        return false;
      }

      Logger.info(
        'Starting notification system for user: ${userInfo.name} (${userInfo.id})',
        tag: _tag,
      );

      // 启动SSE连接
      final connected = await _sseService.connect();
      if (!connected) {
        final error = 'Failed to establish SSE connection';
        Logger.error(error, tag: _tag);
        _updateState(NotificationManagerState.error);
        return false;
      }

      // 启动定时器
      _startHealthCheck();
      _startAuthRefresh();

      // 更新状态
      _startTime = DateTime.now();
      _updateState(NotificationManagerState.running);

      Logger.info('Notification manager started successfully', tag: _tag);
      return true;
    } catch (e) {
      final error = 'Failed to start notification manager: ${e.toString()}';
      Logger.error(error, tag: _tag);
      _updateState(NotificationManagerState.error);
      return false;
    }
  }

  /// 停止通知系统
  Future<void> stop() async {
    if (_state == NotificationManagerState.stopped || 
        _state == NotificationManagerState.stopping) {
      return;
    }

    _updateState(NotificationManagerState.stopping);

    try {
      Logger.info('Stopping notification manager...', tag: _tag);

      // 停止定时器
      _healthCheckTimer?.cancel();
      _healthCheckTimer = null;
      _authRefreshTimer?.cancel();
      _authRefreshTimer = null;

      // 断开SSE连接
      await _sseService.disconnect();

      // 更新状态
      _updateState(NotificationManagerState.stopped);

      Logger.info('Notification manager stopped', tag: _tag);
    } catch (e) {
      final error = 'Failed to stop notification manager: ${e.toString()}';
      Logger.error(error, tag: _tag);
      _updateState(NotificationManagerState.error);
    }
  }

  /// 重启通知系统
  Future<bool> restart() async {
    Logger.info('Restarting notification manager...', tag: _tag);
    await stop();
    return start();
  }

  /// 处理消息接收
  Future<void> _handleMessageReceived(NotificationMessageVO message) async {
    try {
      _totalMessagesReceived++;
      _lastActivityTime = DateTime.now();

      Logger.debug(
        'Received notification: ${message.id} (${message.type})',
        tag: _tag,
      );

      // 分发消息
      await _dispatcher.dispatch(message);

      _totalMessagesProcessed++;
    } catch (e) {
      _totalMessagesFailed++;
      Logger.error(
        'Failed to handle message ${message.id}: ${e.toString()}',
        tag: _tag,
      );
    }
  }

  /// 处理连接状态变化
  void _handleConnectionStateChanged(SseConnectionState connectionState) {
    Logger.info(
      'SSE connection state changed: ${connectionState.name}',
      tag: _tag,
    );

    // 根据连接状态调整管理器状态
    if (connectionState == SseConnectionState.connected && 
        _state == NotificationManagerState.starting) {
      _updateState(NotificationManagerState.running);
    } else if (connectionState == SseConnectionState.error && 
               _state == NotificationManagerState.running) {
      _updateState(NotificationManagerState.error);
    }
  }

  /// 处理错误
  void _handleError(String error) {
    Logger.error('Notification manager error: $error', tag: _tag);
    
    if (_state == NotificationManagerState.running) {
      _updateState(NotificationManagerState.error);
    }
  }

  /// 处理分发器事件
  void _handleDispatcherEvent(NotificationDispatchEvent event) {
    // 可以在这里记录分发事件或进行其他处理
    Logger.debug('Dispatcher event: $event', tag: _tag);
  }

  /// 启动健康检查
  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(
      AppConfig.sseHeartbeatInterval,
      (timer) => _performHealthCheck(),
    );
  }

  /// 执行健康检查
  Future<void> _performHealthCheck() async {
    try {
      if (_state == NotificationManagerState.running) {
        // 检查SSE连接状态
        if (!_sseService.isConnected) {
          Logger.warning('SSE connection lost during health check', tag: _tag);
          await _sseService.reconnect();
        }

        // 检查认证状态
        final isAuthValid = await SseAuthHelper.isAuthenticated();
        if (!isAuthValid) {
          Logger.warning('Authentication expired during health check', tag: _tag);
          await stop();
        }

        // 记录健康检查结果
        Logger.debug('Health check completed', tag: _tag);
      }
    } catch (e) {
      Logger.error('Health check failed: ${e.toString()}', tag: _tag);
    }
  }

  /// 启动认证刷新
  void _startAuthRefresh() {
    _authRefreshTimer?.cancel();
    _authRefreshTimer = Timer.periodic(
      const Duration(minutes: 5), // 每5分钟刷新一次
      (timer) => _refreshAuthentication(),
    );
  }

  /// 刷新认证信息
  Future<void> _refreshAuthentication() async {
    try {
      if (_state == NotificationManagerState.running) {
        final refreshed = await SseAuthHelper.refreshAuthInfo();
        if (refreshed) {
          Logger.debug('Authentication refreshed', tag: _tag);
        } else {
          Logger.warning('Authentication refresh failed', tag: _tag);
          await stop();
        }
      }
    } catch (e) {
      Logger.error('Failed to refresh authentication: ${e.toString()}', tag: _tag);
    }
  }

  /// 更新状态
  void _updateState(NotificationManagerState newState) {
    if (_state != newState) {
      Logger.info(
        'Notification manager state changed: ${_state.name} -> ${newState.name}',
        tag: _tag,
      );
      _state = newState;
    }
  }

  /// 注册通知处理器
  void registerHandler(NotificationHandler handler) {
    _dispatcher.registerHandler(handler);
    Logger.info('Registered notification handler: ${handler.handlerId}', tag: _tag);
  }

  /// 注销通知处理器
  void unregisterHandler(String handlerId) {
    _dispatcher.unregisterHandler(handlerId);
    Logger.info('Unregistered notification handler: $handlerId', tag: _tag);
  }

  /// 获取连接状态
  SseConnectionState getSseConnectionState() {
    return _sseService.connectionState;
  }

  /// 手动触发心跳
  void triggerHeartbeat() {
    _sseService.triggerHeartbeat();
  }

  /// 重置统计信息
  void resetStats() {
    _totalMessagesReceived = 0;
    _totalMessagesProcessed = 0;
    _totalMessagesFailed = 0;
    _startTime = DateTime.now();
    Logger.info('Notification manager stats reset', tag: _tag);
  }

  /// 释放资源
  void dispose() {
    stop();
    _sseService.dispose();
    _dispatcher.dispose();
    _instance = null;
    Logger.info('Notification manager disposed', tag: _tag);
  }
}