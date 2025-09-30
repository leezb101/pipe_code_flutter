/*
 * @Author: LeeZB
 * @Date: 2025-09-30 17:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-30 17:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import '../widgets/unified/unified_components.dart';

/// 材料业务辅助工具类
/// 提供材料业务相关的通用功能，如错误材料检查、提交确认等
class MaterialBusinessHelper {
  /// 检查MaterialInfoForBusiness是否包含错误材料
  static bool hasErrors(dynamic materialInfoForBusiness) {
    if (materialInfoForBusiness == null) return false;

    try {
      final errors = _getErrors(materialInfoForBusiness);
      return errors.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 获取正常材料数量
  static int getNormalCount(dynamic materialInfoForBusiness) {
    if (materialInfoForBusiness == null) return 0;

    try {
      final normals = _getNormals(materialInfoForBusiness);
      return normals.length;
    } catch (e) {
      return 0;
    }
  }

  /// 获取错误材料数量
  static int getErrorCount(dynamic materialInfoForBusiness) {
    if (materialInfoForBusiness == null) return 0;

    try {
      final errors = _getErrors(materialInfoForBusiness);
      return errors.length;
    } catch (e) {
      return 0;
    }
  }

  /// 获取正常材料列表
  static List<dynamic> getNormals(dynamic materialInfoForBusiness) {
    if (materialInfoForBusiness == null) return [];
    return _getNormals(materialInfoForBusiness);
  }

  /// 获取错误材料列表
  static List<dynamic> getErrors(dynamic materialInfoForBusiness) {
    if (materialInfoForBusiness == null) return [];
    return _getErrors(materialInfoForBusiness);
  }

  /// 显示提交确认对话框
  /// 当存在错误材料时，会提示用户确认
  static Future<bool?> showSubmitConfirmation(
    BuildContext context, {
    required dynamic materialInfoForBusiness,
    String title = '提交确认',
    String? businessType,
  }) async {
    final normalCount = getNormalCount(materialInfoForBusiness);
    final errorCount = getErrorCount(materialInfoForBusiness);

    return await showDialog<bool>(
      context: context,
      builder: (context) => SubmitConfirmationDialog(
        normalCount: normalCount,
        errorCount: errorCount,
        title: title,
        businessType: businessType,
        onConfirm: () {}, // 对话框内部会处理
        onCancel: () {}, // 对话框内部会处理
      ),
    );
  }

  /// 创建MaterialBusinessDisplay组件的便捷方法
  static Widget buildMaterialDisplay({
    required dynamic materialInfoForBusiness,
    required Function(dynamic material) onMaterialTap,
    Function(dynamic error)? onErrorMaterialTap,
    String? businessType,
    bool showErrorSection = true,
    bool errorSectionCollapsible = true,
    bool errorSectionInitialExpanded = true,
    Widget Function(dynamic material)? materialItemBuilder,
  }) {
    return MaterialBusinessDisplay(
      materialInfoForBusiness: materialInfoForBusiness,
      onMaterialTap: onMaterialTap,
      onErrorMaterialTap: onErrorMaterialTap,
      businessType: businessType,
      showErrorSection: showErrorSection,
      errorSectionCollapsible: errorSectionCollapsible,
      errorSectionInitialExpanded: errorSectionInitialExpanded,
      materialItemBuilder: materialItemBuilder,
    );
  }

  /// 为业务页面提供统一的提交前检查
  /// 返回 true 表示可以继续提交，false 表示用户取消
  static Future<bool> checkBeforeSubmit(
    BuildContext context, {
    required dynamic materialInfoForBusiness,
    String title = '提交确认',
    String? businessType,
  }) async {
    final hasErrorMaterials = hasErrors(materialInfoForBusiness);

    if (!hasErrorMaterials) {
      // 没有错误材料，直接提交
      return true;
    }

    // 有错误材料，显示确认对话框
    final result = await showSubmitConfirmation(
      context,
      materialInfoForBusiness: materialInfoForBusiness,
      title: title,
      businessType: businessType,
    );

    return result == true;
  }

  // 私有方法：从MaterialInfoForBusiness中提取normals
  static List<dynamic> _getNormals(dynamic materialInfoForBusiness) {
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

  // 私有方法：从MaterialInfoForBusiness中提取errors
  static List<dynamic> _getErrors(dynamic materialInfoForBusiness) {
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
}

/// 提交确认结果枚举
enum SubmitConfirmationResult {
  /// 确认提交
  confirmed,

  /// 取消提交
  cancelled,

  /// 错误
  error,
}

/// 业务页面集成扩展
/// 为各种页面widget提供便捷的材料业务功能
extension MaterialBusinessPageExtension on State {
  /// 检查是否有错误材料
  bool hasMaterialErrors(dynamic materialInfoForBusiness) {
    return MaterialBusinessHelper.hasErrors(materialInfoForBusiness);
  }

  /// 显示材料提交确认
  Future<bool> showMaterialSubmitConfirmation(
    dynamic materialInfoForBusiness, {
    String title = '提交确认',
    String? businessType,
  }) async {
    return await MaterialBusinessHelper.checkBeforeSubmit(
      context,
      materialInfoForBusiness: materialInfoForBusiness,
      title: title,
      businessType: businessType,
    );
  }

  /// 构建材料展示组件
  Widget buildMaterialBusinessDisplay({
    required dynamic materialInfoForBusiness,
    required Function(dynamic material) onMaterialTap,
    Function(dynamic error)? onErrorMaterialTap,
    String? businessType,
    bool showErrorSection = true,
    Widget Function(dynamic material)? materialItemBuilder,
  }) {
    return MaterialBusinessHelper.buildMaterialDisplay(
      materialInfoForBusiness: materialInfoForBusiness,
      onMaterialTap: onMaterialTap,
      onErrorMaterialTap: onErrorMaterialTap,
      businessType: businessType,
      showErrorSection: showErrorSection,
      materialItemBuilder: materialItemBuilder,
    );
  }
}
