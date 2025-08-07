/*
 * @Author: LeeZB
 * @Date: 2025-08-07 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-07 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pipe_code_flutter/models/notification/notification_message_vo.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

/// 通知处理器接口
/// 定义了处理通知消息的契约
abstract class NotificationHandler {
  /// 处理器唯一标识
  String get handlerId;

  /// 处理通知消息
  Future<void> handleNotification(NotificationMessageVO message);

  /// 检查是否支持处理该类型的消息
  bool supports(NotificationMessageVO message);

  /// 处理器优先级 (数字越大优先级越高)
  int get priority => 0;
}

/// 通知分发器
/// 负责将通知消息分发给合适的处理器
class NotificationDispatcher {
  static const String _tag = 'NOTIFICATION_DISPATCHER';
  
  final Map<String, NotificationHandler> _handlers = {};
  final StreamController<NotificationMessageVO> _messageController = StreamController.broadcast();
  final StreamController<NotificationDispatchEvent> _eventController = StreamController.broadcast();

  /// 消息流，用于监听所有通知消息
  Stream<NotificationMessageVO> get messageStream => _messageController.stream;

  /// 事件流，用于监听分发事件
  Stream<NotificationDispatchEvent> get eventStream => _eventController.stream;

  /// 注册通知处理器
  void registerHandler(NotificationHandler handler) {
    if (_handlers.containsKey(handler.handlerId)) {
      Logger.warning(
        'Handler ${handler.handlerId} is already registered, replacing...',
        tag: _tag,
      );
    }
    
    _handlers[handler.handlerId] = handler;
    Logger.info('Registered notification handler: ${handler.handlerId}', tag: _tag);
    
    // 发送注册事件
    _eventController.add(
      NotificationDispatchEvent.handlerRegistered(handler.handlerId),
    );
  }

  /// 注销通知处理器
  void unregisterHandler(String handlerId) {
    if (_handlers.remove(handlerId) != null) {
      Logger.info('Unregistered notification handler: $handlerId', tag: _tag);
      
      // 发送注销事件
      _eventController.add(
        NotificationDispatchEvent.handlerUnregistered(handlerId),
      );
    }
  }

  /// 分发通知消息
  Future<void> dispatch(NotificationMessageVO message) async {
    try {
      Logger.info(
        'Dispatching notification: ${message.id} (${message.type})',
        tag: _tag,
      );

      // 发送消息到流
      _messageController.add(message);

      // 获取支持的处理器，按优先级排序
      final supportedHandlers = _handlers.values
          .where((handler) => handler.supports(message))
          .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));

      if (supportedHandlers.isEmpty) {
        Logger.warning(
          'No handlers found for notification type: ${message.type}',
          tag: _tag,
        );
        
        // 发送无处理器事件
        _eventController.add(
          NotificationDispatchEvent.noHandlersFound(message),
        );
        return;
      }

      // 并发处理通知
      final results = await Future.wait(
        supportedHandlers.map((handler) => _handleWithHandler(handler, message)),
      );

      // 检查处理结果
      final successCount = results.where((r) => r).length;
      final failureCount = results.length - successCount;

      Logger.info(
        'Notification ${message.id} processed by ${supportedHandlers.length} handlers: '
        '$successCount success, $failureCount failure',
        tag: _tag,
      );

      // 发送分发完成事件
      _eventController.add(
        NotificationDispatchEvent.dispatchCompleted(
          message: message,
          handlerCount: supportedHandlers.length,
          successCount: successCount,
          failureCount: failureCount,
        ),
      );
    } catch (e) {
      Logger.error(
        'Failed to dispatch notification ${message.id}: ${e.toString()}',
        tag: _tag,
      );
      
      // 发送分发错误事件
      _eventController.add(
        NotificationDispatchEvent.dispatchError(message, e.toString()),
      );
    }
  }

  /// 使用指定处理器处理消息
  Future<bool> _handleWithHandler(
    NotificationHandler handler,
    NotificationMessageVO message,
  ) async {
    try {
      final startTime = DateTime.now();
      
      await handler.handleNotification(message);
      
      final duration = DateTime.now().difference(startTime);
      Logger.debug(
        'Handler ${handler.handlerId} processed notification ${message.id} in ${duration.inMilliseconds}ms',
        tag: _tag,
      );
      
      return true;
    } catch (e) {
      Logger.error(
        'Handler ${handler.handlerId} failed to process notification ${message.id}: ${e.toString()}',
        tag: _tag,
      );
      return false;
    }
  }

  /// 获取所有已注册的处理器
  List<String> get registeredHandlers => _handlers.keys.toList();

  /// 检查处理器是否已注册
  bool isHandlerRegistered(String handlerId) => _handlers.containsKey(handlerId);

  /// 清理资源
  void dispose() {
    _handlers.clear();
    _messageController.close();
    _eventController.close();
    Logger.info('Notification dispatcher disposed', tag: _tag);
  }
}

/// 通知分发事件
/// 用于跟踪分发过程中的各种事件
@immutable
class NotificationDispatchEvent {
  final NotificationDispatchEventType type;
  final String? handlerId;
  final NotificationMessageVO? message;
  final String? error;
  final int? handlerCount;
  final int? successCount;
  final int? failureCount;

  const NotificationDispatchEvent._({
    required this.type,
    this.handlerId,
    this.message,
    this.error,
    this.handlerCount,
    this.successCount,
    this.failureCount,
  });

  factory NotificationDispatchEvent.handlerRegistered(String handlerId) =>
      NotificationDispatchEvent._(
        type: NotificationDispatchEventType.handlerRegistered,
        handlerId: handlerId,
      );

  factory NotificationDispatchEvent.handlerUnregistered(String handlerId) =>
      NotificationDispatchEvent._(
        type: NotificationDispatchEventType.handlerUnregistered,
        handlerId: handlerId,
      );

  factory NotificationDispatchEvent.noHandlersFound(NotificationMessageVO message) =>
      NotificationDispatchEvent._(
        type: NotificationDispatchEventType.noHandlersFound,
        message: message,
      );

  factory NotificationDispatchEvent.dispatchCompleted({
    required NotificationMessageVO message,
    required int handlerCount,
    required int successCount,
    required int failureCount,
  }) =>
      NotificationDispatchEvent._(
        type: NotificationDispatchEventType.dispatchCompleted,
        message: message,
        handlerCount: handlerCount,
        successCount: successCount,
        failureCount: failureCount,
      );

  factory NotificationDispatchEvent.dispatchError(
    NotificationMessageVO message,
    String error,
  ) =>
      NotificationDispatchEvent._(
        type: NotificationDispatchEventType.dispatchError,
        message: message,
        error: error,
      );

  @override
  String toString() {
    switch (type) {
      case NotificationDispatchEventType.handlerRegistered:
        return 'HandlerRegistered(handlerId: $handlerId)';
      case NotificationDispatchEventType.handlerUnregistered:
        return 'HandlerUnregistered(handlerId: $handlerId)';
      case NotificationDispatchEventType.noHandlersFound:
        return 'NoHandlersFound(messageId: ${message?.id})';
      case NotificationDispatchEventType.dispatchCompleted:
        return 'DispatchCompleted(messageId: ${message?.id}, handlers: $handlerCount, success: $successCount, failure: $failureCount)';
      case NotificationDispatchEventType.dispatchError:
        return 'DispatchError(messageId: ${message?.id}, error: $error)';
    }
  }
}

/// 通知分发事件类型
enum NotificationDispatchEventType {
  handlerRegistered, // 处理器已注册
  handlerUnregistered, // 处理器已注销
  noHandlersFound, // 未找到合适的处理器
  dispatchCompleted, // 分发完成
  dispatchError, // 分发错误
}

/// 通知处理器基类
/// 提供基本的处理器实现
abstract class BaseNotificationHandler implements NotificationHandler {
  @override
  String get handlerId;

  @override
  Future<void> handleNotification(NotificationMessageVO message) async {
    if (!supports(message)) {
      throw UnsupportedError('Handler $handlerId does not support message type ${message.type}');
    }
    
    await doHandle(message);
  }

  /// 子类实现具体的处理逻辑
  @protected
  Future<void> doHandle(NotificationMessageVO message);

  @override
  bool supports(NotificationMessageVO message) {
    return getSupportedTypes().contains(message.type);
  }

  /// 获取支持的消息类型
  @protected
  List<String> getSupportedTypes();
}