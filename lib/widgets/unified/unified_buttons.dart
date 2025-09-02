/*
 * @Author: LeeZB
 * @Date: 2025-08-31 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-31 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';

/// 统一的按钮样式枚举
enum UnifiedButtonType {
  primary, // 主要按钮
  secondary, // 次要按钮
  outlined, // 边框按钮
  text, // 文本按钮
  success, // 成功按钮
  warning, // 警告按钮
  danger, // 危险按钮
}

/// 统一的按钮尺寸枚举
enum UnifiedButtonSize {
  small, // 小按钮
  medium, // 中等按钮
  large, // 大按钮
}

/// 统一的按钮组件
class UnifiedButton extends StatelessWidget {
  const UnifiedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = UnifiedButtonType.primary,
    this.size = UnifiedButtonSize.medium,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation,
    this.businessType,
  });

  /// 按钮文本
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 按钮类型
  final UnifiedButtonType type;

  /// 按钮尺寸
  final UnifiedButtonSize size;

  /// 图标
  final IconData? icon;

  /// 图标位置
  final IconPosition iconPosition;

  /// 是否加载中
  final bool isLoading;

  /// 是否全宽
  final bool isFullWidth;

  /// 背景颜色（覆盖默认颜色）
  final Color? backgroundColor;

  /// 前景色（覆盖默认颜色）
  final Color? foregroundColor;

  /// 边框颜色（覆盖默认颜色）
  final Color? borderColor;

  /// 圆角半径
  final double? borderRadius;

  /// 阴影高度
  final double? elevation;

  /// 业务类型（用于自动应用颜色主题）
  final String? businessType;

  @override
  Widget build(BuildContext context) {
    final buttonConfig = _getButtonConfig();

    Widget button = _buildButton(buttonConfig);

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  _ButtonConfig _getButtonConfig() {
    final sizeConfig = _getSizeConfig();
    final colorConfig = _getColorConfig();

    return _ButtonConfig(
      padding: sizeConfig.padding,
      height: sizeConfig.height,
      fontSize: sizeConfig.fontSize,
      iconSize: sizeConfig.iconSize,
      backgroundColor: backgroundColor ?? colorConfig.backgroundColor,
      foregroundColor: foregroundColor ?? colorConfig.foregroundColor,
      borderColor: borderColor ?? colorConfig.borderColor,
      borderRadius: borderRadius ?? AppTheme.radiusMedium,
      elevation:
          elevation ??
          (type == UnifiedButtonType.outlined || type == UnifiedButtonType.text
              ? 0
              : AppTheme.elevationSmall),
    );
  }

  _SizeConfig _getSizeConfig() {
    switch (size) {
      case UnifiedButtonSize.small:
        return _SizeConfig(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          height: 36,
          fontSize: 14,
          iconSize: 16,
        );
      case UnifiedButtonSize.medium:
        return _SizeConfig(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          height: 44,
          fontSize: 16,
          iconSize: 18,
        );
      case UnifiedButtonSize.large:
        return _SizeConfig(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          height: 52,
          fontSize: 18,
          iconSize: 20,
        );
    }
  }

  _ColorConfig _getColorConfig() {
    // 如果指定了业务类型，使用业务颜色
    if (businessType != null) {
      final businessColor = AppTheme.getBusinessColor(businessType!);
      return _getBusinessColorConfig(businessColor);
    }

    // 否则使用默认颜色配置
    switch (type) {
      case UnifiedButtonType.primary:
        return _ColorConfig(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          borderColor: AppTheme.primaryColor,
        );
      case UnifiedButtonType.secondary:
        return _ColorConfig(
          backgroundColor: AppTheme.grey100,
          foregroundColor: AppTheme.grey700,
          borderColor: AppTheme.grey300,
        );
      case UnifiedButtonType.outlined:
        return _ColorConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.primaryColor,
          borderColor: AppTheme.primaryColor,
        );
      case UnifiedButtonType.text:
        return _ColorConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.primaryColor,
          borderColor: Colors.transparent,
        );
      case UnifiedButtonType.success:
        return _ColorConfig(
          backgroundColor: AppTheme.successColor,
          foregroundColor: Colors.white,
          borderColor: AppTheme.successColor,
        );
      case UnifiedButtonType.warning:
        return _ColorConfig(
          backgroundColor: AppTheme.warningColor,
          foregroundColor: Colors.white,
          borderColor: AppTheme.warningColor,
        );
      case UnifiedButtonType.danger:
        return _ColorConfig(
          backgroundColor: AppTheme.errorColor,
          foregroundColor: Colors.white,
          borderColor: AppTheme.errorColor,
        );
    }
  }

  _ColorConfig _getBusinessColorConfig(Color businessColor) {
    switch (type) {
      case UnifiedButtonType.primary:
        return _ColorConfig(
          backgroundColor: businessColor,
          foregroundColor: Colors.white,
          borderColor: businessColor,
        );
      case UnifiedButtonType.secondary:
        return _ColorConfig(
          backgroundColor: businessColor.withValues(alpha: 0.1),
          foregroundColor: businessColor,
          borderColor: businessColor.withValues(alpha: 0.3),
        );
      case UnifiedButtonType.outlined:
        return _ColorConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: businessColor,
          borderColor: businessColor,
        );
      case UnifiedButtonType.text:
        return _ColorConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: businessColor,
          borderColor: Colors.transparent,
        );
      default:
        return _getColorConfig();
    }
  }

  Widget _buildButton(_ButtonConfig config) {
    if (type == UnifiedButtonType.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: config.foregroundColor,
          padding: config.padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.borderRadius),
          ),
        ),
        child: _buildButtonContent(config),
      );
    } else if (type == UnifiedButtonType.outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: config.foregroundColor,
          backgroundColor: config.backgroundColor,
          side: BorderSide(color: config.borderColor),
          padding: config.padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.borderRadius),
          ),
          elevation: config.elevation,
        ),
        child: _buildButtonContent(config),
      );
    } else {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: config.backgroundColor,
          foregroundColor: config.foregroundColor,
          padding: config.padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.borderRadius),
          ),
          elevation: config.elevation,
        ),
        child: _buildButtonContent(config),
      );
    }
  }

  Widget _buildButtonContent(_ButtonConfig config) {
    if (isLoading) {
      return SizedBox(
        width: config.iconSize,
        height: config.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(config.foregroundColor),
        ),
      );
    }

    if (icon == null) {
      return Text(
        text,
        style: TextStyle(
          fontSize: config.fontSize,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    List<Widget> children = [
      Icon(icon, size: config.iconSize),
      SizedBox(width: AppTheme.spacingSmall),
      Text(
        text,
        style: TextStyle(
          fontSize: config.fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];

    if (iconPosition == IconPosition.right) {
      children = children.reversed.toList();
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

/// 图标位置枚举
enum IconPosition { left, right }

/// 按钮配置类
class _ButtonConfig {
  final EdgeInsetsGeometry padding;
  final double height;
  final double fontSize;
  final double iconSize;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final double borderRadius;
  final double elevation;

  _ButtonConfig({
    required this.padding,
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderRadius,
    required this.elevation,
  });
}

/// 尺寸配置类
class _SizeConfig {
  final EdgeInsetsGeometry padding;
  final double height;
  final double fontSize;
  final double iconSize;

  _SizeConfig({
    required this.padding,
    required this.height,
    required this.fontSize,
    required this.iconSize,
  });
}

/// 颜色配置类
class _ColorConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  _ColorConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });
}

/// 统一的操作按钮组
class UnifiedActionButtons extends StatelessWidget {
  const UnifiedActionButtons({
    super.key,
    this.primaryButton,
    this.secondaryButton,
    this.tertiaryButton,
    this.spacing,
    this.padding,
    this.backgroundColor,
    this.showShadow = true,
    this.isFullWidth = false,
  });

  /// 主要按钮
  final UnifiedButton? primaryButton;

  /// 次要按钮
  final UnifiedButton? secondaryButton;

  /// 第三个按钮
  final UnifiedButton? tertiaryButton;

  /// 按钮间距
  final double? spacing;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 背景颜色
  final Color? backgroundColor;

  /// 是否显示阴影
  final bool showShadow;

  /// 按钮是否全宽
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      if (tertiaryButton != null) tertiaryButton!,
      if (secondaryButton != null) secondaryButton!,
      if (primaryButton != null) primaryButton!,
    ];

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveSpacing = spacing ?? AppTheme.spacingMedium;
    final effectivePadding =
        padding ?? const EdgeInsets.all(AppTheme.spacingLarge);

    Widget content = SafeArea(
      child: Row(
        children: [
          for (int i = 0; i < buttons.length; i++) ...[
            if (isFullWidth) Expanded(child: buttons[i]) else buttons[i],
            if (i < buttons.length - 1) SizedBox(width: effectiveSpacing),
          ],
        ],
      ),
    );

    content = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: showShadow ? AppTheme.shadowMedium : null,
      ),
      child: content,
    );

    return content;
  }
}
