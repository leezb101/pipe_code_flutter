/*
 * @Author: LeeZB
 * @Date: 2025-08-31 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-31 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/models/common/material_status_enum.dart';
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
    this.batchCode,
    this.primaryText,
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
    this.status,
    this.statusName,
    this.validStatus,
  });

  /// 材料名称
  final String materialName;

  /// 材料编码
  final String? materialCode;

  /// 材料ID
  final String? materialId;

  /// 批次码
  final String? batchCode;

  /// 主要显示文本（如果为null，则使用materialName）
  final String? primaryText;

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

  /// 材料状态代码
  final int? status;

  /// 材料状态名称
  final String? statusName;

  final MaterialStatusEnum? validStatus;

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
                        primaryText ?? materialName,
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
                      if (batchCode != null) ...[
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Text(
                          '批次: $batchCode',
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
                      // 添加材料状态标签（显示在最底部）
                      if (statusName != null) ...[
                        const SizedBox(height: AppTheme.spacingSmall),
                        Row(
                          children: [
                            // 根据状态有效性显示图标
                            if (validStatus != null) ...[
                              Icon(
                                _isStatusValid() ? Icons.check : Icons.close,
                                size: 14,
                                color: _isStatusValid()
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                              ),
                              const SizedBox(width: AppTheme.spacingXSmall),
                            ],
                            Expanded(
                              child: Text(
                                statusName!,
                                style: AppTheme.bodySmall.copyWith(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
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

  /// 判断当前状态是否有效
  bool _isStatusValid() {
    if (validStatus == null || status == null) {
      return true; // 如果没有validStatus限制，默认为有效
    }

    // 将status转换为MaterialStatusEnum进行比较
    final currentStatus = MaterialStatusEnum.fromCode(status!);
    return currentStatus == validStatus;
  }

  /// 根据状态获取对应颜色
  Color _getStatusColor() {
    if (status == null) {
      return AppTheme.grey600;
    }

    // 如果设置了validStatus，则根据状态有效性返回颜色
    if (validStatus != null) {
      return _isStatusValid() ? AppTheme.successColor : AppTheme.errorColor;
    }

    // 原有的状态颜色逻辑（保持向后兼容）
    switch (status!) {
      case 1: // 正常
        return AppTheme.successColor;
      case 2: // 警告
        return AppTheme.warningColor;
      case 3: // 异常
        return AppTheme.errorColor;
      case 0: // 处理中
        return AppTheme.infoColor;
      default:
        return AppTheme.grey600;
    }
  }
}

/// 错误材料列表项组件
class ErrorMaterialListItem extends StatelessWidget {
  const ErrorMaterialListItem({
    super.key,
    required this.qrCode,
    this.vendorCode,
    this.vendorName,
    this.errorMessage,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.trailing,
  });

  /// 材料二维码（厂家产品唯一编号）
  final String qrCode;

  /// 厂家编码
  final String? vendorCode;

  /// 厂家名称
  final String? vendorName;

  /// 错误消息
  final String? errorMessage;

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

  @override
  Widget build(BuildContext context) {
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
              color:
                  backgroundColor ?? AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: borderColor ?? AppTheme.errorColor,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // 错误图标
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    icon ?? Icons.error_outline,
                    size: 20,
                    color: iconColor ?? AppTheme.errorColor,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),

                // 材料信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        qrCode,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      if (vendorCode != null) ...[
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Text(
                          '厂家编码: $vendorCode',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.grey700,
                          ),
                        ),
                      ],
                      if (vendorName != null) ...[
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Text(
                          '厂家名称: $vendorName',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.grey700,
                          ),
                        ),
                      ],
                      if (errorMessage != null) ...[
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSmall,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                          ),
                          child: Text(
                            errorMessage!,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 尾部内容
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 错误材料展示区域组件
class ErrorMaterialSection extends StatelessWidget {
  const ErrorMaterialSection({
    super.key,
    required this.errors,
    this.title = '异常材料',
    this.icon,
    this.onErrorItemTap,
    this.collapsible = true,
    this.initialExpanded = true,
  });

  /// 错误材料列表
  final List<dynamic> errors; // 支持 SyncVendorDataError 或其他错误模型

  /// 区域标题
  final String title;

  /// 区域图标
  final IconData? icon;

  /// 错误项点击回调
  final Function(dynamic error)? onErrorItemTap;

  /// 是否可折叠
  final bool collapsible;

  /// 初始是否展开
  final bool initialExpanded;

  @override
  Widget build(BuildContext context) {
    if (errors.isEmpty) {
      return const SizedBox.shrink();
    }

    final content = Column(
      children: errors.map((error) {
        return ErrorMaterialListItem(
          qrCode: _getQrCode(error),
          vendorCode: _getVendorCode(error),
          vendorName: _getVendorName(error),
          errorMessage: _getErrorMessage(error),
          onTap: () => onErrorItemTap?.call(error),
        );
      }).toList(),
    );

    if (!collapsible) {
      return UnifiedCard(
        title: title,
        icon: icon ?? Icons.warning_amber_rounded,
        iconColor: AppTheme.errorColor,
        borderColor: AppTheme.errorColor,
        backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
        child: content,
      );
    }

    return UnifiedCard(
      title: null,
      borderColor: AppTheme.errorColor,
      backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
      child: ExpansionTile(
        initiallyExpanded: initialExpanded,
        title: Row(
          children: [
            Icon(
              icon ?? Icons.warning_amber_rounded,
              size: 20,
              color: AppTheme.errorColor,
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Text(
              title,
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSmall,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Text(
                '${errors.length}',
                style: AppTheme.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: AppTheme.spacingMedium),
        children: [content],
      ),
    );
  }

  String _getQrCode(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['qrCode']?.toString() ??
          error['qr_code']?.toString() ??
          '未知二维码';
    }
    // 假设有 qrCode 属性
    try {
      return (error as dynamic).qrCode?.toString() ?? '未知二维码';
    } catch (e) {
      return '未知二维码';
    }
  }

  String? _getVendorCode(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['code']?.toString();
    }
    try {
      return (error as dynamic).code?.toString();
    } catch (e) {
      return null;
    }
  }

  String? _getVendorName(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['name']?.toString();
    }
    try {
      return (error as dynamic).name?.toString();
    } catch (e) {
      return null;
    }
  }

  String? _getErrorMessage(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['msg']?.toString() ?? error['message']?.toString();
    }
    try {
      return (error as dynamic).msg?.toString();
    } catch (e) {
      return null;
    }
  }
}

/// 材料业务页面集成组件
/// 用于在业务页面中统一展示正常材料和错误材料
class MaterialBusinessDisplay extends StatelessWidget {
  const MaterialBusinessDisplay({
    super.key,
    required this.materialInfoForBusiness,
    required this.onMaterialTap,
    this.onErrorMaterialTap,
    this.businessType,
    this.showErrorSection = true,
    this.errorSectionCollapsible = true,
    this.errorSectionInitialExpanded = true,
    this.materialItemBuilder,
  });

  /// 材料业务数据
  final dynamic materialInfoForBusiness; // MaterialInfoForBusiness 或类似结构

  /// 正常材料点击回调
  final Function(dynamic material) onMaterialTap;

  /// 错误材料点击回调
  final Function(dynamic error)? onErrorMaterialTap;

  /// 业务类型
  final String? businessType;

  /// 是否显示错误区域
  final bool showErrorSection;

  /// 错误区域是否可折叠
  final bool errorSectionCollapsible;

  /// 错误区域初始是否展开
  final bool errorSectionInitialExpanded;

  /// 自定义材料项构建器
  final Widget Function(dynamic material)? materialItemBuilder;

  @override
  Widget build(BuildContext context) {
    final normals = _getNormals();
    final errors = _getErrors();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 正常材料列表
        if (normals.isNotEmpty) ...[
          ...normals.map((material) {
            if (materialItemBuilder != null) {
              return materialItemBuilder!(material);
            }
            return _buildDefaultMaterialItem(material);
          }),
        ],

        // 错误材料区域
        if (showErrorSection && errors.isNotEmpty) ...[
          if (normals.isNotEmpty) const SizedBox(height: AppTheme.spacingLarge),
          ErrorMaterialSection(
            errors: errors,
            collapsible: errorSectionCollapsible,
            initialExpanded: errorSectionInitialExpanded,
            onErrorItemTap: onErrorMaterialTap,
          ),
        ],
      ],
    );
  }

  List<dynamic> _getNormals() {
    if (materialInfoForBusiness == null) return [];

    if (materialInfoForBusiness is Map<String, dynamic>) {
      final normals = materialInfoForBusiness['normals'];
      return normals is List ? normals : [];
    }

    try {
      final normals = (materialInfoForBusiness as dynamic).normals;
      return normals is List ? normals : [];
    } catch (e) {
      return [];
    }
  }

  List<dynamic> _getErrors() {
    if (materialInfoForBusiness == null) return [];

    if (materialInfoForBusiness is Map<String, dynamic>) {
      final errors = materialInfoForBusiness['errors'];
      return errors is List ? errors : [];
    }

    try {
      final errors = (materialInfoForBusiness as dynamic).errors;
      return errors is List ? errors : [];
    } catch (e) {
      return [];
    }
  }

  Widget _buildDefaultMaterialItem(dynamic material) {
    // 尝试从material中提取信息
    String materialName = '未知材料';
    String? materialCode;
    String? batchCode;
    String? materialId;
    int? quantity;
    int? status;
    String? statusName;

    if (material is Map<String, dynamic>) {
      materialName =
          material['baseInfo']?['prodNm'] ??
          material['materialName'] ??
          materialName;
      materialCode =
          material['baseInfo']?['materialCode'] ?? material['materialCode'];
      batchCode = material['baseInfo']?['batchCode'] ?? material['batchCode'];
      materialId =
          material['baseInfo']?['materialCode'] ??
          material['materialId']?.toString();
      quantity = material['num'] ?? material['quantity'] ?? 1;
      status = material['status'] as int?;
      statusName = material['statusName']?.toString();
    } else {
      try {
        final baseInfo = (material as dynamic).baseInfo;
        materialName = baseInfo?.prodNm ?? materialName;
        materialCode = baseInfo?.materialCode;
        batchCode = baseInfo?.batchCode;
        materialId = baseInfo?.materialCode;
        quantity = 1;
        status = (material as dynamic).status as int?;
        statusName = (material as dynamic).statusName?.toString();
      } catch (e) {
        // 使用默认值
      }
    }

    return MaterialListItem(
      onTap: () => onMaterialTap(material),
      materialName: materialName,
      primaryText: materialCode ?? '无',
      batchCode: batchCode,
      materialId: materialId,
      quantity: quantity,
      businessType: businessType,
      icon: _getBusinessIcon(),
      status: status,
      statusName: statusName,
    );
  }

  IconData _getBusinessIcon() {
    switch (businessType) {
      case 'acceptance':
        return Icons.water_drop;
      case 'signin':
        return Icons.inventory_2;
      case 'signout':
        return Icons.outbound;
      case 'dispatch':
        return Icons.local_shipping;
      case 'install':
        return Icons.build;
      default:
        return Icons.inventory;
    }
  }
}

/// 提交确认对话框组件
/// 用于在存在错误材料时提示用户确认
class SubmitConfirmationDialog extends StatelessWidget {
  const SubmitConfirmationDialog({
    super.key,
    required this.normalCount,
    required this.errorCount,
    required this.onConfirm,
    this.onCancel,
    this.title = '提交确认',
    this.businessType,
  });

  /// 正常材料数量
  final int normalCount;

  /// 错误材料数量
  final int errorCount;

  /// 确认回调
  final VoidCallback onConfirm;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 对话框标题
  final String title;

  /// 业务类型
  final String? businessType;

  @override
  Widget build(BuildContext context) {
    final hasErrors = errorCount > 0;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            hasErrors
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            color: hasErrors ? AppTheme.warningColor : AppTheme.successColor,
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本次操作包含：',
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // 正常材料信息
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: AppTheme.successColor),
              const SizedBox(width: AppTheme.spacingSmall),
              Text('正常材料：$normalCount 项', style: AppTheme.bodyMedium),
            ],
          ),

          // 错误材料信息
          if (hasErrors) ...[
            const SizedBox(height: AppTheme.spacingSmall),
            Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: AppTheme.errorColor),
                const SizedBox(width: AppTheme.spacingSmall),
                Text(
                  '异常材料：$errorCount 项',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: AppTheme.warningColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      '异常材料不会被提交，请确认材料状态后再进行提交。',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            '确认要提交吗？',
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          child: Text(
            '取消',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.grey600),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: hasErrors
                ? AppTheme.warningColor
                : AppTheme.primaryColor,
          ),
          child: Text(
            '确认提交',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
