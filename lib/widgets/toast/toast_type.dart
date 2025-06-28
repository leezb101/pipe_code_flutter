/*
 * @Author: LeeZB
 * @Date: 2025-06-28 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

extension ToastTypeExtension on ToastType {
  Color get backgroundColor {
    switch (this) {
      case ToastType.success:
        return const Color(0xFF4CAF50);
      case ToastType.error:
        return const Color(0xFFF44336);
      case ToastType.warning:
        return const Color(0xFFFF9800);
      case ToastType.info:
        return const Color(0xFF2196F3);
    }
  }

  Color get textColor {
    return Colors.white;
  }

  IconData get icon {
    switch (this) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  String get label {
    switch (this) {
      case ToastType.success:
        return '成功';
      case ToastType.error:
        return '错误';
      case ToastType.warning:
        return '警告';
      case ToastType.info:
        return '提示';
    }
  }
}