/*
 * @Author: LeeZB
 * @Date: 2025-08-31 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-31 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';

/// 统一的卡片组件
class UnifiedCard extends StatelessWidget {
  const UnifiedCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.iconColor,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.businessType,
  });

  /// 卡片内容
  final Widget child;

  /// 卡片标题
  final String? title;

  /// 标题图标
  final IconData? icon;

  /// 图标颜色
  final Color? iconColor;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 阴影高度
  final double? elevation;

  /// 圆角半径
  final double? borderRadius;

  /// 背景颜色
  final Color? backgroundColor;

  /// 边框颜色
  final Color? borderColor;

  /// 边框宽度
  final double? borderWidth;

  /// 业务类型（用于自动应用颜色主题）
  final String? businessType;

  @override
  Widget build(BuildContext context) {
    final effectiveElevation = elevation ?? AppTheme.elevationSmall;
    final effectiveBorderRadius = borderRadius ?? AppTheme.radiusMedium;
    final effectivePadding =
        padding ?? const EdgeInsets.all(AppTheme.spacingLarge);

    // 根据业务类型自动计算颜色
    Color? effectiveIconColor = iconColor;
    Color? effectiveBorderColor = borderColor;

    if (businessType != null) {
      final businessColor = AppTheme.getBusinessColor(businessType!);
      effectiveIconColor ??= businessColor;
      effectiveBorderColor ??= AppTheme.getBusinessColorMedium(businessType!);
    }

    return Container(
      margin: margin,
      child: Card(
        elevation: effectiveElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          side: effectiveBorderColor != null
              ? BorderSide(color: effectiveBorderColor, width: borderWidth ?? 1)
              : BorderSide.none,
        ),
        color: backgroundColor,
        child: Padding(
          padding: effectivePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null || icon != null) ...[
                _buildHeader(effectiveIconColor),
                const SizedBox(height: AppTheme.spacingLarge),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color? iconColor) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 24, color: iconColor ?? AppTheme.primaryColor),
          const SizedBox(width: AppTheme.spacingSmall),
        ],
        if (title != null)
          Expanded(child: Text(title!, style: AppTheme.titleMedium)),
      ],
    );
  }
}

/// 信息展示行组件
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.labelStyle,
    this.valueStyle,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  /// 标签文本
  final String label;

  /// 值文本
  final String value;

  /// 图标
  final IconData? icon;

  /// 图标颜色
  final Color? iconColor;

  /// 标签样式
  final TextStyle? labelStyle;

  /// 值样式
  final TextStyle? valueStyle;

  /// 对齐方式
  final CrossAxisAlignment crossAxisAlignment;

  /// 间距
  final double? spacing;

  /// 背景颜色
  final Color? backgroundColor;

  /// 圆角
  final double? borderRadius;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? AppTheme.spacingSmall;
    final effectiveLabelStyle = labelStyle ?? AppTheme.labelLarge;
    final effectiveValueStyle = valueStyle ?? AppTheme.bodyMedium;

    Widget content = Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: iconColor ?? AppTheme.grey600),
          SizedBox(width: effectiveSpacing),
        ],
        Expanded(flex: 3, child: Text(label, style: effectiveLabelStyle)),
        SizedBox(width: effectiveSpacing),
        Expanded(flex: 4, child: Text(value, style: effectiveValueStyle)),
      ],
    );

    if (backgroundColor != null) {
      content = Container(
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingMedium),
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppTheme.radiusSmall,
          ),
        ),
        child: content,
      );
    } else if (padding != null || margin != null) {
      content = Container(padding: padding, margin: margin, child: content);
    }

    return content;
  }
}

/// 材料列表项组件
class MaterialListItem extends StatelessWidget {
  const MaterialListItem({
    super.key,
    required this.materialName,
    this.materialCode,
    this.materialId,
    this.spec,
    this.weight,
    this.quantity,
    this.unit = '个',
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.trailing,
    this.businessType,
    this.showQuantityBadge = true,
  });

  /// 材料名称
  final String materialName;

  /// 材料编码
  final String? materialCode;

  /// 材料ID
  final String? materialId;

  /// 规格
  final String? spec;

  /// 重量
  final String? weight;

  /// 数量
  final int? quantity;

  /// 单位
  final String unit;

  /// 图标
  final IconData? icon;

  /// 图标颜色
  final Color? iconColor;

  /// 背景颜色
  final Color? backgroundColor;

  /// 边框颜色
  final Color? borderColor;

  /// 点击回调
  final VoidCallback? onTap;

  /// 尾部组件
  final Widget? trailing;

  /// 业务类型
  final String? businessType;

  /// 是否显示数量徽章
  final bool showQuantityBadge;

  @override
  Widget build(BuildContext context) {
    // 根据业务类型自动计算颜色
    Color effectiveBackgroundColor = backgroundColor ?? AppTheme.grey50;
    Color effectiveBorderColor = borderColor ?? AppTheme.grey200;
    Color effectiveIconColor = iconColor ?? AppTheme.primaryColor;

    if (businessType != null) {
      effectiveBackgroundColor =
          backgroundColor ?? AppTheme.getBusinessColorLight(businessType!);
      effectiveBorderColor =
          borderColor ?? AppTheme.getBusinessColorMedium(businessType!);
      effectiveIconColor =
          iconColor ?? AppTheme.getBusinessColor(businessType!);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: effectiveBorderColor),
            ),
            child: Row(
              children: [
                // 图标
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSmall),
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    icon ?? Icons.water_drop,
                    size: 20,
                    color: effectiveIconColor,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),

                // 材料信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materialName,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (materialCode != null) ...[
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Text(
                          materialCode!,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                      if (materialId != null) ...[
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Text(
                          'ID: $materialId',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                      if (spec != null) ...[
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Text(
                          '规格: $spec',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                      if (weight != null) ...[
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Text(
                          '重量: $weight',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 尾部内容
                if (trailing != null)
                  trailing!
                else if (quantity != null && showQuantityBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: effectiveIconColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Text(
                      '$quantity$unit',
                      style: AppTheme.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 用户信息展示组件
class UserInfoWidget extends StatelessWidget {
  const UserInfoWidget({
    super.key,
    required this.name,
    this.title,
    this.phone,
    this.department,
    this.avatar,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.onTap,
    this.trailing,
    this.showPushOption = false,
    this.isPushSelected = false,
    this.onPushChanged,
  });

  /// 用户名称
  final String name;

  /// 职位/职务
  final String? title;

  /// 电话
  final String? phone;

  /// 部门
  final String? department;

  /// 头像（可以是网络地址或本地资源）
  final String? avatar;

  /// 背景颜色
  final Color? backgroundColor;

  /// 边框颜色
  final Color? borderColor;

  /// 文本颜色
  final Color? textColor;

  /// 点击回调
  final VoidCallback? onTap;

  /// 尾部组件
  final Widget? trailing;

  /// 是否显示推送选项
  final bool showPushOption;

  /// 推送是否被选中
  final bool isPushSelected;

  /// 推送状态变化回调
  final ValueChanged<bool>? onPushChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: borderColor ?? AppTheme.grey200),
            ),
            child: Row(
              children: [
                // 头像
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  backgroundImage: avatar != null
                      ? NetworkImage(avatar!)
                      : null,
                  child: avatar == null
                      ? Text(
                          name.isNotEmpty ? name[0] : 'U',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppTheme.spacingMedium),

                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if (title != null) ...[
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Text(
                          title!,
                          style: AppTheme.bodySmall.copyWith(
                            color:
                                textColor?.withValues(alpha: 0.7) ??
                                AppTheme.grey600,
                          ),
                        ),
                      ],
                      if (department != null) ...[
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Text(
                          department!,
                          style: AppTheme.bodySmall.copyWith(
                            color:
                                textColor?.withValues(alpha: 0.7) ??
                                AppTheme.grey600,
                          ),
                        ),
                      ],
                      if (phone != null) ...[
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Text(
                          phone!,
                          style: AppTheme.bodySmall.copyWith(
                            color:
                                textColor?.withValues(alpha: 0.7) ??
                                AppTheme.grey600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 尾部内容
                if (trailing != null)
                  trailing!
                else if (showPushOption)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isPushSelected,
                        onChanged: onPushChanged != null
                            ? (bool? value) => onPushChanged!(value ?? false)
                            : null,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Text('推送', style: AppTheme.bodySmall),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
