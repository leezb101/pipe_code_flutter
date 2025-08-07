/*
 * @Author: LeeZB
 * @Date: 2025-08-07 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-07 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:async';
import 'package:flutter/material.dart' as flutter;
import 'package:pipe_code_flutter/services/notification/notification_manager.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

/// 应用生命周期状态
enum AppLifecycleState {
  foreground, // 前台
  background, // 后台
  paused, // 暂停
  detached, // 分离（应用被终止）
}

/// 后台通知处理器
/// 负责处理应用生命周期状态变化时的通知系统行为
class BackgroundNotificationHandler {
  static const String _tag = 'BACKGROUND_NOTIFICATION_HANDLER';
  
  static BackgroundNotificationHandler? _instance;
  
  final NotificationManager _notificationManager;
  final List<AppLifecycleState> _stateHistory = [];
  
  AppLifecycleState _currentState = AppLifecycleState.foreground;
  Timer? _backgroundTimer;
  Timer? _reconnectTimer;
  
  // 配置参数
  static const Duration _backgroundCheckInterval = Duration(seconds: 30);
  static const Duration _backgroundMaxDuration = Duration(minutes: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);
  
  // 后台状态跟踪
  DateTime? _backgroundStartTime;
  bool _isInBackground = false;
  int _backgroundReconnectAttempts = 0;
  static const int _maxBackgroundReconnectAttempts = 3;

  /// 获取单例实例
  static BackgroundNotificationHandler get instance {
    _instance ??= BackgroundNotificationHandler._internal();
    return _instance!;
  }

  BackgroundNotificationHandler._internal()
      : _notificationManager = NotificationManager.instance {
    _initialize();
  }

  /// 获取当前应用状态
  AppLifecycleState get currentState => _currentState;

  /// 检查是否在后台
  bool get isInBackground => _isInBackground;

  /// 获取后台持续时间
  Duration? get backgroundDuration {
    if (_backgroundStartTime == null) return null;
    return DateTime.now().difference(_backgroundStartTime!);
  }

  /// 初始化
  void _initialize() {
    Logger.info('Background notification handler initialized', tag: _tag);
  }

  /// 处理应用生命周期变化
  Future<void> handleLifecycleChange(AppLifecycleState newState) async {
    if (_currentState == newState) {
      return; // 状态未变化
    }

    Logger.info(
      'App lifecycle state changed: ${_currentState.name} -> ${newState.name}',
      tag: _tag,
    );

    // 记录状态历史
    _stateHistory.add(newState);
    if (_stateHistory.length > 10) {
      _stateHistory.removeAt(0); // 保持历史记录在合理范围内
    }

    // 处理状态转换
    await _handleStateTransition(_currentState, newState);

    // 更新当前状态
    _currentState = newState;
  }

  /// 处理状态转换
  Future<void> _handleStateTransition(
    AppLifecycleState oldState,
    AppLifecycleState newState,
  ) async {
    try {
      // 前台 -> 后台
      if (oldState == AppLifecycleState.foreground && 
          (newState == AppLifecycleState.background || newState == AppLifecycleState.paused)) {
        await _handleForegroundToBackground();
      }
      // 后台 -> 前台
      else if ((oldState == AppLifecycleState.background || oldState == AppLifecycleState.paused) && 
               newState == AppLifecycleState.foreground) {
        await _handleBackgroundToForeground();
      }
      // 应用终止
      else if (newState == AppLifecycleState.detached) {
        await _handleAppTermination();
      }
    } catch (e) {
      Logger.error(
        'Error handling state transition from ${oldState.name} to ${newState.name}: ${e.toString()}',
        tag: _tag,
      );
    }
  }

  /// 处理前台到后台的转换
  Future<void> _handleForegroundToBackground() async {
    Logger.info('App moving to background', tag: _tag);

    _isInBackground = true;
    _backgroundStartTime = DateTime.now();
    _backgroundReconnectAttempts = 0;

    try {
      if (_notificationManager.isRunning) {
        // 检查是否应该保持连接
        if (_shouldKeepConnectionInBackground()) {
          Logger.info('Keeping SSE connection alive in background', tag: _tag);
          _startBackgroundMonitoring();
        } else {
          Logger.info('Suspending SSE connection in background', tag: _tag);
          await _notificationManager.stop();
        }
      }
    } catch (e) {
      Logger.error(
        'Error handling foreground to background transition: ${e.toString()}',
        tag: _tag,
      );
    }
  }

  /// 处理后台到前台的转换
  Future<void> _handleBackgroundToForeground() async {
    Logger.info('App moving to foreground', tag: _tag);

    _isInBackground = false;
    _backgroundStartTime = null;
    _backgroundReconnectAttempts = 0;

    try {
      // 停止后台监控
      _stopBackgroundMonitoring();

      // 重新启动通知系统
      if (_notificationManager.state != NotificationManagerState.running) {
        Logger.info('Restarting notification system after background', tag: _tag);
        final success = await _notificationManager.start();
        if (!success) {
          Logger.warning('Failed to restart notification system', tag: _tag);
        }
      } else {
        Logger.info('Notification system already running', tag: _tag);
      }
    } catch (e) {
      Logger.error(
        'Error handling background to foreground transition: ${e.toString()}',
        tag: _tag,
      );
    }
  }

  /// 处理应用终止
  Future<void> _handleAppTermination() async {
    Logger.info('App terminating, cleaning up...', tag: _tag);

    try {
      // 停止所有定时器
      _stopBackgroundMonitoring();
      _reconnectTimer?.cancel();
      _reconnectTimer = null;

      // 停止通知系统
      await _notificationManager.stop();

      // 清理资源
      _stateHistory.clear();
      _isInBackground = false;
      _backgroundStartTime = null;
      _backgroundReconnectAttempts = 0;

      Logger.info('App termination cleanup completed', tag: _tag);
    } catch (e) {
      Logger.error(
        'Error handling app termination: ${e.toString()}',
        tag: _tag,
      );
    }
  }

  /// 判断是否应该在后台保持连接
  bool _shouldKeepConnectionInBackground() {
    // 根据业务需求决定是否在后台保持连接
    // 这里可以根据配置或用户设置来决定
    return false; // 默认情况下不在后台保持连接以节省电量
  }

  /// 启动后台监控
  void _startBackgroundMonitoring() {
    _stopBackgroundMonitoring(); // 确保之前的监控已停止

    _backgroundTimer = Timer.periodic(
      _backgroundCheckInterval,
      (timer) => _monitorBackgroundConnection(),
    );

    Logger.info('Background monitoring started', tag: _tag);
  }

  /// 停止后台监控
  void _stopBackgroundMonitoring() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    Logger.info('Background monitoring stopped', tag: _tag);
  }

  /// 监控后台连接状态
  Future<void> _monitorBackgroundConnection() async {
    try {
      if (!_isInBackground) return;

      final backgroundDuration = this.backgroundDuration;
      if (backgroundDuration == null) return;

      // 检查后台持续时间是否超过最大限制
      if (backgroundDuration > _backgroundMaxDuration) {
        Logger.warning(
          'Background duration exceeded limit (${backgroundDuration.inMinutes} minutes), stopping connection',
          tag: _tag,
        );
        await _notificationManager.stop();
        _stopBackgroundMonitoring();
        return;
      }

      // 检查连接状态
      if (!_notificationManager.isRunning) {
        if (_backgroundReconnectAttempts < _maxBackgroundReconnectAttempts) {
          Logger.info(
            'Attempting to reconnect in background (attempt ${_backgroundReconnectAttempts + 1})',
            tag: _tag,
          );
          _backgroundReconnectAttempts++;
          
          // 延迟重连以避免频繁尝试
          _reconnectTimer = Timer(_reconnectDelay, () async {
            await _notificationManager.start();
          });
        } else {
          Logger.warning(
            'Max background reconnect attempts reached, stopping monitoring',
            tag: _tag,
          );
          _stopBackgroundMonitoring();
        }
      } else {
        // 重置重连计数
        _backgroundReconnectAttempts = 0;
      }
    } catch (e) {
      Logger.error(
        'Error monitoring background connection: ${e.toString()}',
        tag: _tag,
      );
    }
  }

  /// 手动唤醒应用（用于处理后台消息）
  Future<void> wakeupForNotification() async {
    try {
      Logger.info('Waking up app for notification processing', tag: _tag);

      // 停止后台监控
      _stopBackgroundMonitoring();

      // 确保通知系统正在运行
      if (!_notificationManager.isRunning) {
        await _notificationManager.start();
      }

      // 这里可以添加其他唤醒逻辑，比如显示通知、播放声音等
    } catch (e) {
      Logger.error(
        'Error waking up app for notification: ${e.toString()}',
        tag: _tag,
      );
    }
  }

  /// 获取状态统计信息
  Map<String, dynamic> getStats() {
    return {
      'currentState': _currentState.name,
      'isInBackground': _isInBackground,
      'backgroundDuration': backgroundDuration?.inSeconds,
      'stateHistory': _stateHistory.map((s) => s.name).toList(),
      'backgroundReconnectAttempts': _backgroundReconnectAttempts,
      'notificationManagerState': _notificationManager.state.name,
      'isNotificationManagerRunning': _notificationManager.isRunning,
    };
  }

  /// 强制停止后台监控
  void forceStopBackgroundMonitoring() {
    Logger.info('Force stopping background monitoring', tag: _tag);
    _stopBackgroundMonitoring();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _backgroundReconnectAttempts = 0;
  }

  /// 重置状态
  void reset() {
    Logger.info('Resetting background notification handler', tag: _tag);
    
    _currentState = AppLifecycleState.foreground;
    _isInBackground = false;
    _backgroundStartTime = null;
    _backgroundReconnectAttempts = 0;
    _stateHistory.clear();
    
    forceStopBackgroundMonitoring();
  }

  /// 释放资源
  void dispose() {
    Logger.info('Disposing background notification handler', tag: _tag);
    
    forceStopBackgroundMonitoring();
    _stateHistory.clear();
    _instance = null;
  }
}

/// 应用生命周期观察器
/// 用于监听应用生命周期变化并通知BackgroundNotificationHandler
class AppLifecycleObserver extends flutter.WidgetsBindingObserver {
  final BackgroundNotificationHandler _handler;

  AppLifecycleObserver(this._handler);

  @override
  void didChangeAppLifecycleState(flutter.AppLifecycleState state) {
    // 转换Flutter的AppLifecycleState为我们的状态
    final handlerState = _convertAppLifecycleState(state);
    _handler.handleLifecycleChange(handlerState);
  }

  /// 转换Flutter的AppLifecycleState
  AppLifecycleState _convertAppLifecycleState(flutter.AppLifecycleState state) {
    switch (state) {
      case flutter.AppLifecycleState.paused:
        return AppLifecycleState.paused;
      case flutter.AppLifecycleState.resumed:
        return AppLifecycleState.foreground;
      case flutter.AppLifecycleState.inactive:
        return AppLifecycleState.background;
      case flutter.AppLifecycleState.detached:
        return AppLifecycleState.detached;
      case flutter.AppLifecycleState.hidden:
        return AppLifecycleState.background;
    }
  }
}