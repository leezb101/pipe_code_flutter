/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/recovery/material_categories.dart';
import 'package:pipe_code_flutter/models/recovery/vendors_map.dart';
import 'package:pipe_code_flutter/models/recovery/step3_result.dart';

/// 验证结果
class ValidationResult {
  /// 验证是否通过
  final bool isValid;

  /// 全局错误信息列表
  final List<String> errorMessages;

  /// 字段级别的错误信息 (fieldKey -> errorMessage)
  final Map<String, String> fieldErrors;

  const ValidationResult({
    required this.isValid,
    this.errorMessages = const [],
    this.fieldErrors = const {},
  });

  /// 创建验证成功的结果
  factory ValidationResult.success() {
    return const ValidationResult(isValid: true);
  }

  /// 创建验证失败的结果
  factory ValidationResult.failure({
    List<String>? errorMessages,
    Map<String, String>? fieldErrors,
  }) {
    return ValidationResult(
      isValid: false,
      errorMessages: errorMessages ?? [],
      fieldErrors: fieldErrors ?? {},
    );
  }

  /// 是否有任何错误
  bool get hasErrors => !isValid;

  /// 获取所有错误信息（全局 + 字段）
  List<String> get allErrorMessages {
    final List<String> allErrors = [...errorMessages];
    allErrors.addAll(fieldErrors.values);
    return allErrors;
  }
}

/// Recovery模块数据仓库接口
/// 负责数据获取、缓存管理、数据转换和验证
/// 为Bloc层提供纯数据操作方法
abstract class RecoveryRepository {
  // === 数据获取方法（为Bloc提供数据源）===

  /// 获取供应商映射数据
  /// 输入: 无
  /// 输出: Future<Result<VendorsMap>> - 原始供应商数据
  /// 用途: Bloc获取供应商数据，然后转换为UI需要的格式
  Future<Result<VendorsMap>> getVendorsMap();

  /// 获取物料分类数据
  /// 输入: vendorCode (String?) - 供应商代码（如果API需要）
  /// 输出: Future<Result<MaterialCategoriesList>> - 原始物料分类数据
  /// 用途: Bloc获取物料分类数据，然后根据业务逻辑处理
  Future<Result<MaterialCategoriesList>> getMaterialCategories(
    String vendorCode,
  );

  // === 数据查询方法（基于缓存的快速查询）===

  /// 根据供应商代码获取供应商名称
  /// 输入: vendorCode (String) - 供应商代码
  /// 输出: String? - 供应商名称，可能为null
  /// 用途: Bloc在处理业务逻辑时快速查询供应商信息
  String? getVendorNameByCode(String vendorCode);

  /// 根据分类组别获取分类信息
  /// 输入: group (int) - 分类组别
  /// 输出: MaterialCategory? - 分类信息，可能为null
  /// 用途: Bloc根据用户选择获取分类详情
  MaterialCategory? getCategoryByGroup(int group);

  /// 根据类型编号获取物料类型信息
  /// 输入: type (int) - 类型编号
  /// 输出: MaterialType? - 物料类型信息，可能为null
  /// 用途: Bloc根据用户选择获取类型详情
  MaterialType? getMaterialTypeByType(int type);

  /// 获取指定分类下的所有物料类型
  /// 输入: categoryGroup (int) - 分类组别
  /// 输出: List<MaterialType> - 物料类型列表
  /// 用途: Bloc构建第三级下拉选项时使用
  List<MaterialType> getMaterialTypesByCategory(int categoryGroup);

  /// 获取指定物料类型的检索字段
  /// 输入: materialType (int) - 物料类型编号
  /// 输出: List<RetrieveBack> - 检索字段列表
  /// 用途: Bloc生成动态表单字段时使用
  List<RetrieveBack> getRetrieveBacksByType(int materialType);

  // === 数据转换方法（为Bloc提供便捷的转换工具）===

  /// 将供应商数据转换为下拉选项
  /// 输入: 无（使用缓存的数据）
  /// 输出: List<VendorOption> - 下拉选项列表
  /// 用途: Bloc转换数据格式供UI使用
  List<VendorOption> getVendorOptions();

  /// 将物料分类转换为下拉选项
  /// 输入: 无（使用缓存的数据）
  /// 输出: List<MaterialCategoryOption> - 分类下拉选项列表
  /// 用途: Bloc转换数据格式供UI使用
  List<MaterialCategoryOption> getCategoryOptions();

  /// 将指定分类的物料类型转换为下拉选项
  /// 输入: categoryGroup (int) - 分类组别
  /// 输出: List<MaterialTypeOption> - 类型下拉选项列表
  /// 用途: Bloc转换数据格式供UI使用
  List<MaterialTypeOption> getTypeOptionsByCategory(int categoryGroup);

  // === 数据验证方法（为Bloc提供验证逻辑）===

  /// 验证表单数据
  /// 输入: formData (Map<String, String?>) - 表单数据
  ///      materialType (int) - 物料类型编号
  /// 输出: ValidationResult - 验证结果（包含是否通过和错误信息）
  /// 用途: Bloc在提交前验证用户输入
  ValidationResult validateFormData(
    Map<String, String?> formData,
    int materialType,
  );

  /// 构建提交数据
  /// 输入: materialType (int) - 物料类型编号
  ///      formData (Map<String, String?>) - 用户填写的数据
  /// 输出: Map<String, String?> - 符合API要求的提交数据
  /// 用途: Bloc准备提交数据时使用
  Map<String, String?> buildSubmissionData(
    int materialType,
    Map<String, String?> formData,
  );

  // === 缓存管理方法===

  /// 检查数据是否已缓存
  /// 输入: 无
  /// 输出: bool - 是否有可用的缓存数据
  /// 用途: Bloc判断是否需要重新加载数据
  bool get hasValidCache;

  /// 清除缓存
  /// 输入: 无
  /// 输出: 无
  /// 用途: Bloc需要强制刷新数据时调用
  void clearCache();

  /// 预加载数据到缓存
  /// 输入: 无
  /// 输出: Future<Result<bool>> - 预加载结果
  /// 用途: 应用启动时或Bloc初始化时预加载数据
  Future<Result<bool>> preloadData();

  // === 两步提交方法 ===

  /// Step3: 提交表单字段，获取确认信息
  /// 输入: vendorCode (String) - 选择的供应商代码
  ///      materialType (int) - 选择的物料类型编号
  ///      formData (Map<String, String?>) - 用户填写的动态表单数据
  /// 输出: Future<Result<Step3Result>> - Step3结果，包含确认信息和headerKey
  /// 用途: Bloc处理表单提交，获取服务端确认信息供用户确认
  Future<Result<Step3Result>> submitStep3Fields(
    String vendorCode,
    int materialType,
    Map<String, String?> formData,
  );

  /// Step4: 最终提交，包含QR码
  /// 输入: qrCode (String) - 扫描的QR码字符串
  ///      headerKey (String) - Step3返回的header key
  /// 输出: Future<Result<void>> - 最终提交结果
  /// 用途: 用户确认后进行最终提交
  Future<Result<void>> submitStep4Fields(String qrCode, String headerKey);
}
