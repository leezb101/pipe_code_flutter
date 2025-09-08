/*
 * @Author: LeeZB
 * @Date: 2025-08-31 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-31 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';

/// 统一的应用主题设计系统
class AppTheme {
  // =============== 颜色系统 ===============

  /// 主色调
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color primaryColorLight = Color(0xFF42A5F5);
  static const Color primaryColorDark = Color(0xFF0D47A1);

  /// 业务功能颜色
  static const Color acceptanceColor = Color(0xFF9C27B0); // 验收 - 紫色
  static const Color dispatchColor = Color(0xFF3498DB); // 调度 - 蓝色
  static const Color installColor = Color(0xFF4CAF50); // 安装 - 绿色
  static const Color signoutColor = Color(0xFFFF9800); // 出库 - 橙色
  static const Color signinColor = Color(0xFF2196F3); // 入库 - 蓝色
  static const Color returnColor = Color(0xFFE91E63); // 退库 - 粉红色
  static const Color inventoryColor = Color(0xFFf39C12); // 盘点 - 黄色
  static const Color cutColor = Color(0xFF795548); // 切割 - 棕色

  /// 状态颜色
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  /// 灰色系
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // =============== 尺寸系统 ===============

  /// 圆角
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  /// 间距
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 24.0;

  /// 阴影
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // =============== 字体系统 ===============

  /// 标题字体样式
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2C3E50),
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2C3E50),
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2C3E50),
  );

  /// 正文字体样式
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  /// 标签字体样式
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF616161),
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF616161),
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Color(0xFF616161),
  );

  // =============== 阴影系统 ===============

  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  // =============== 工具方法 ===============

  /// 根据业务类型获取对应颜色
  static Color getBusinessColor(String businessType) {
    switch (businessType.toLowerCase()) {
      case 'acceptance':
      case '验收':
        return acceptanceColor;
      case 'dispatch':
      case '调度':
        return dispatchColor;
      case 'install':
      case '安装':
        return installColor;
      case 'signout':
      case '出库':
        return signoutColor;
      case 'signin':
      case '入库':
        return signinColor;
      case 'return':
      case '退库':
        return returnColor;
      case 'inventory':
      case '盘点':
        return inventoryColor;
      case 'cut':
      case '切割':
        return cutColor;
      case 'warehouse':
      case '仓库':
        return primaryColor;
      case 'project':
      case '项目':
        return Color(0xFF4CAF50); // 绿色
      default:
        return primaryColor;
    }
  }

  /// 获取浅色版本的业务颜色（用于背景）
  static Color getBusinessColorLight(String businessType) {
    final baseColor = getBusinessColor(businessType);
    return baseColor.withValues(alpha: 0.1);
  }

  /// 获取中等深度的业务颜色（用于边框）
  static Color getBusinessColorMedium(String businessType) {
    final baseColor = getBusinessColor(businessType);
    return baseColor.withValues(alpha: 0.3);
  }
}
