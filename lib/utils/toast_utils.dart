/*
 * @Author: LeeZB
 * @Date: 2025-06-28 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-24 18:15:29
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pipe_code_flutter/config/routes.dart';
import '../widgets/toast/ios_toast.dart';
import '../widgets/toast/toast_type.dart';

class ToastUtils {
  static final List<OverlayEntry> _activeToasts = [];
  static const int _maxConcurrentToasts = 3;

  // 防重复显示的消息缓存
  static final Map<String, DateTime> _recentMessages = {};
  static const Duration _duplicateWindow = Duration(
    milliseconds: 1000,
  ); // 1秒内不重复显示相同消息

  /// 显示成功提示
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool showIcon = true,
    bool isGlobal = false,
  }) {
    _showToast(
      context,
      message: message,
      type: ToastType.success,
      duration: duration,
      showIcon: showIcon,
      isGlobal: isGlobal,
    );
  }

  /// 显示错误提示
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    bool showIcon = true,
    bool isGlobal = false,
  }) {
    _showToast(
      context,
      message: message,
      type: ToastType.error,
      duration: duration,
      showIcon: showIcon,
      isGlobal: isGlobal,
    );
  }

  /// 显示警告提示
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool showIcon = true,
    bool isGlobal = false,
  }) {
    _showToast(
      context,
      message: message,
      type: ToastType.warning,
      duration: duration,
      showIcon: showIcon,
      isGlobal: isGlobal,
    );
  }

  /// 显示信息提示
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool showIcon = true,
    bool isGlobal = false,
  }) {
    _showToast(
      context,
      message: message,
      type: ToastType.info,
      duration: duration,
      showIcon: showIcon,
      isGlobal: isGlobal,
    );
  }

  /// 通用显示提示方法
  static void _showToast(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
    bool showIcon = true,
    bool isGlobal = false,
  }) {
    final overlayContext = (isGlobal && navigatorKey.currentContext != null)
        ? navigatorKey.currentContext!
        : context;

    if (!overlayContext.mounted) return;

    // 检查是否为重复消息
    final now = DateTime.now();
    final messageKey = '${type.name}_$message';

    if (_recentMessages.containsKey(messageKey)) {
      final lastShown = _recentMessages[messageKey]!;
      if (now.difference(lastShown) < _duplicateWindow) {
        // 在重复显示窗口内，忽略重复消息
        return;
      }
    }

    // 记录当前消息
    _recentMessages[messageKey] = now;

    // 清理过期的消息记录
    _recentMessages.removeWhere(
      (key, time) => now.difference(time) > _duplicateWindow,
    );

    // 如果超过最大数量，移除最老的 toast
    if (_activeToasts.length >= _maxConcurrentToasts) {
      final oldestToast = _activeToasts.removeAt(0);
      if (oldestToast.mounted) {
        oldestToast.remove();
      }
    }

    // 震动反馈
    if (type == ToastType.error) {
      HapticFeedback.heavyImpact();
    } else if (type == ToastType.warning) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    final overlay = Overlay.of(overlayContext);
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (context) {
        // 计算垂直偏移量，让多个 toast 错开显示
        final double topOffset = 60.0 + (_activeToasts.length * 80.0);
        return Positioned(
          top: topOffset,
          left: 20,
          right: 20,
          child: IOSToast(
            message: message,
            type: type,
            duration: duration,
            showIcon: showIcon,
            onDismissed: () {
              if (entry != null && entry.mounted) {
                entry.remove();
                _activeToasts.remove(entry);
              }
            },
          ),
        );
      },
    );

    _activeToasts.add(entry);
    overlay.insert(entry);
  }

  /// 手动移除所有显示的 toast
  static void dismissAll() {
    for (final toast in _activeToasts) {
      if (toast.mounted) {
        toast.remove();
      }
    }
    _activeToasts.clear();
  }

  /// 清除重复消息缓存（用于页面切换时重置）
  static void clearDuplicateCache() {
    _recentMessages.clear();
  }

  /// 手动移除最新的 toast
  static void dismiss() {
    if (_activeToasts.isNotEmpty) {
      final latestToast = _activeToasts.removeLast();
      if (latestToast.mounted) {
        latestToast.remove();
      }
    }
  }

  /// 批量显示多个消息（立即显示，错开位置）
  static void showMessages(
    BuildContext context,
    List<String> messages, {
    ToastType type = ToastType.error,
    Duration duration = const Duration(seconds: 3),
  }) {
    for (final message in messages) {
      _showToast(context, message: message, type: type, duration: duration);
    }
  }

  /// 顺序显示多个消息（带延迟）
  static Future<void> showMessagesSequentially(
    BuildContext context,
    List<String> messages, {
    ToastType type = ToastType.error,
    Duration delayBetween = const Duration(milliseconds: 800),
    Duration duration = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < messages.length; i++) {
      if (i > 0) {
        await Future.delayed(delayBetween);
      }
      if (context.mounted) {
        _showToast(
          context,
          message: messages[i],
          type: type,
          duration: duration,
        );
      }
    }
  }
}

/// 扩展方法，让 BuildContext 可以直接调用 toast 方法
extension ToastExtension on BuildContext {
  void showSuccessToast(
    String message, {
    Duration? duration,
    bool showIcon = true,
    bool isGlobal = false,
  }) {
    ToastUtils.showSuccess(
      this,
      message,
      duration: duration ?? const Duration(seconds: 3),
      showIcon: showIcon,
      isGlobal: isGlobal,
    );
  }

  void showErrorToast(
    String message, {
    Duration? duration,
    bool showIcon = true,
    bool isGlobal = false,
  }) {
    ToastUtils.showError(
      this,
      message,
      duration: duration ?? const Duration(seconds: 4),
      showIcon: showIcon,
      isGlobal: isGlobal,
    );
  }

  void showWarningToast(
    String message, {
    Duration? duration,
    bool showIcon = true,
    bool isGlobal = false,
  }) {
    ToastUtils.showWarning(
      this,
      message,
      duration: duration ?? const Duration(seconds: 3),
      showIcon: showIcon,
      isGlobal: isGlobal,
    );
  }

  void showInfoToast(
    String message, {
    Duration? duration,
    bool showIcon = true,
    bool isGlobal = false,
  }) {
    ToastUtils.showInfo(
      this,
      message,
      duration: duration ?? const Duration(seconds: 3),
      showIcon: showIcon,
      isGlobal: isGlobal,
    );
  }
}
