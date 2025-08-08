import 'dart:async';
import 'package:pipe_code_flutter/models/notification/notification_message_vo.dart';

/// 轻量级全局通知中心：发布/聚合/暂存新到的通知（尤其todo）
class NotificationCenter {
  NotificationCenter._();
  static final NotificationCenter instance = NotificationCenter._();

  // 500ms 聚合缓冲
  final List<NotificationMessageVO> _todoBuffer = [];
  Timer? _debounceTimer;
  final _batchedTodoCtrl =
      StreamController<List<NotificationMessageVO>>.broadcast();

  /// 对外：聚合后的 todo 批量流
  Stream<List<NotificationMessageVO>> get todoStream => _batchedTodoCtrl.stream;

  // 简单的待消费队列（仅内存，App重启后清空）
  final List<NotificationMessageVO> _pending = [];
  final _pendingCtrl =
      StreamController<List<NotificationMessageVO>>.broadcast();

  /// 对外：待处理队列流（任何变化都会推送完整拷贝）
  Stream<List<NotificationMessageVO>> get pendingStream => _pendingCtrl.stream;

  /// 发布新消息（由 SseService 调用）
  void publish(NotificationMessageVO message) {
    if (message.type.toLowerCase() == 'todo') {
      // 去重（按id）
      if (_todoBuffer.any((m) => m.id == message.id)) return;
      _todoBuffer.add(message);

      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (_todoBuffer.isEmpty) return;
        final batch = List<NotificationMessageVO>.from(_todoBuffer);
        _todoBuffer.clear();
        if (!_batchedTodoCtrl.isClosed) {
          _batchedTodoCtrl.add(batch);
        }
      });
    }
  }

  /// 暂存（用户选择“稍后处理”）
  void addPending(NotificationMessageVO message) {
    if (_pending.any((m) => m.id == message.id)) return; // 去重
    _pending.add(message);
    if (!_pendingCtrl.isClosed) {
      _pendingCtrl.add(List.unmodifiable(_pending));
    }
  }

  List<NotificationMessageVO> get pending => List.unmodifiable(_pending);

  void removePendingById(String id) {
    _pending.removeWhere((m) => m.id == id);
    if (!_pendingCtrl.isClosed) {
      _pendingCtrl.add(List.unmodifiable(_pending));
    }
  }

  void clearPending() {
    _pending.clear();
    if (!_pendingCtrl.isClosed) {
      _pendingCtrl.add(const []);
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _batchedTodoCtrl.close();
    _pendingCtrl.close();
  }
}
