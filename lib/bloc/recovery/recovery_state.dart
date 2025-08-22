/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/recovery/material_categories.dart';
import 'package:pipe_code_flutter/models/recovery/vendors_map.dart';
import 'package:pipe_code_flutter/models/recovery/step3_result.dart';
import 'package:pipe_code_flutter/repositories/interfaces/recovery_repository.dart';

/// Recovery模块的状态基类
abstract class RecoveryState extends Equatable {
  const RecoveryState();

  @override
  List<Object?> get props => [];
}

/// 初始状态 - Bloc刚创建时的状态
class RecoveryInitial extends RecoveryState {
  const RecoveryInitial();
}

/// 加载中状态 - 正在获取基础数据时的状态
class RecoveryLoading extends RecoveryState {
  /// 加载提示信息
  final String? message;

  const RecoveryLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// 基础数据加载完成状态 - 供应商数据加载完成，显示供应商下拉框
class RecoveryVendorsLoaded extends RecoveryState {
  /// 供应商选项列表
  final List<VendorOption> vendorOptions;

  /// 默认选中的供应商（可能为空）
  final VendorOption? selectedVendor;

  /// 一次性消费的错误信息
  final String? errorMessage;

  const RecoveryVendorsLoaded({
    required this.vendorOptions,
    this.selectedVendor,
    this.errorMessage,
  });

  /// 创建新的状态副本，只更新指定字段
  RecoveryVendorsLoaded copyWith({
    List<VendorOption>? vendorOptions,
    VendorOption? selectedVendor,
    String? errorMessage,
  }) {
    return RecoveryVendorsLoaded(
      vendorOptions: vendorOptions ?? this.vendorOptions,
      selectedVendor: selectedVendor ?? this.selectedVendor,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [vendorOptions, selectedVendor, errorMessage];
}

/// 材料分类加载完成状态 - 用户选择供应商后显示材料分类下拉框
class RecoveryCategoriesLoaded extends RecoveryState {
  /// 供应商选项列表
  final List<VendorOption> vendorOptions;

  /// 当前选中的供应商
  final VendorOption selectedVendor;

  /// 材料分类选项列表
  final List<MaterialCategoryOption> categoryOptions;

  /// 默认选中的分类（可能为空）
  final MaterialCategoryOption? selectedCategory;

  /// 一次性消费的错误信息
  final String? errorMessage;

  const RecoveryCategoriesLoaded({
    required this.vendorOptions,
    required this.selectedVendor,
    required this.categoryOptions,
    this.selectedCategory,
    this.errorMessage,
  });

  /// 创建新的状态副本，只更新指定字段
  RecoveryCategoriesLoaded copyWith({
    List<VendorOption>? vendorOptions,
    VendorOption? selectedVendor,
    List<MaterialCategoryOption>? categoryOptions,
    MaterialCategoryOption? selectedCategory,
    String? errorMessage,
  }) {
    return RecoveryCategoriesLoaded(
      vendorOptions: vendorOptions ?? this.vendorOptions,
      selectedVendor: selectedVendor ?? this.selectedVendor,
      categoryOptions: categoryOptions ?? this.categoryOptions,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    vendorOptions,
    selectedVendor,
    categoryOptions,
    selectedCategory,
    errorMessage,
  ];
}

/// 材料类型加载完成状态 - 用户选择材料分类后显示材料类型下拉框
class RecoveryTypesLoaded extends RecoveryState {
  /// 供应商选项列表
  final List<VendorOption> vendorOptions;

  /// 当前选中的供应商
  final VendorOption selectedVendor;

  /// 材料分类选项列表
  final List<MaterialCategoryOption> categoryOptions;

  /// 当前选中的分类
  final MaterialCategoryOption selectedCategory;

  /// 材料类型选项列表
  final List<MaterialTypeOption> typeOptions;

  /// 默认选中的类型（可能为空）
  final MaterialTypeOption? selectedType;

  /// 一次性消费的错误信息
  final String? errorMessage;

  const RecoveryTypesLoaded({
    required this.vendorOptions,
    required this.selectedVendor,
    required this.categoryOptions,
    required this.selectedCategory,
    required this.typeOptions,
    this.selectedType,
    this.errorMessage,
  });

  /// 创建新的状态副本，只更新指定字段
  RecoveryTypesLoaded copyWith({
    List<VendorOption>? vendorOptions,
    VendorOption? selectedVendor,
    List<MaterialCategoryOption>? categoryOptions,
    MaterialCategoryOption? selectedCategory,
    List<MaterialTypeOption>? typeOptions,
    MaterialTypeOption? selectedType,
    String? errorMessage,
  }) {
    return RecoveryTypesLoaded(
      vendorOptions: vendorOptions ?? this.vendorOptions,
      selectedVendor: selectedVendor ?? this.selectedVendor,
      categoryOptions: categoryOptions ?? this.categoryOptions,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      typeOptions: typeOptions ?? this.typeOptions,
      selectedType: selectedType ?? this.selectedType,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    vendorOptions,
    selectedVendor,
    categoryOptions,
    selectedCategory,
    typeOptions,
    selectedType,
    errorMessage,
  ];
}

/// 表单字段加载完成状态 - 用户选择材料类型后显示动态表单字段
class RecoveryFormReady extends RecoveryState {
  /// 供应商选项列表
  final List<VendorOption> vendorOptions;

  /// 当前选中的供应商
  final VendorOption selectedVendor;

  /// 材料分类选项列表
  final List<MaterialCategoryOption> categoryOptions;

  /// 当前选中的分类
  final MaterialCategoryOption selectedCategory;

  /// 材料类型选项列表
  final List<MaterialTypeOption> typeOptions;

  /// 当前选中的类型
  final MaterialTypeOption selectedType;

  /// 动态表单字段列表
  final List<RetrieveBack> formFields;

  /// 表单数据（字段键 -> 用户输入值）
  final Map<String, String?> formData;

  /// 是否正在验证
  final bool isValidating;

  /// 验证错误信息（字段键 -> 错误信息）
  final Map<String, String> fieldErrors;

  /// 一次性消费的错误信息
  final String? errorMessage;

  const RecoveryFormReady({
    required this.vendorOptions,
    required this.selectedVendor,
    required this.categoryOptions,
    required this.selectedCategory,
    required this.typeOptions,
    required this.selectedType,
    required this.formFields,
    this.formData = const {},
    this.isValidating = false,
    this.fieldErrors = const {},
    this.errorMessage,
  });

  /// 创建新的状态副本，只更新指定字段
  RecoveryFormReady copyWith({
    List<VendorOption>? vendorOptions,
    VendorOption? selectedVendor,
    List<MaterialCategoryOption>? categoryOptions,
    MaterialCategoryOption? selectedCategory,
    List<MaterialTypeOption>? typeOptions,
    MaterialTypeOption? selectedType,
    List<RetrieveBack>? formFields,
    Map<String, String?>? formData,
    bool? isValidating,
    Map<String, String>? fieldErrors,
    String? errorMessage,
  }) {
    return RecoveryFormReady(
      vendorOptions: vendorOptions ?? this.vendorOptions,
      selectedVendor: selectedVendor ?? this.selectedVendor,
      categoryOptions: categoryOptions ?? this.categoryOptions,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      typeOptions: typeOptions ?? this.typeOptions,
      selectedType: selectedType ?? this.selectedType,
      formFields: formFields ?? this.formFields,
      formData: formData ?? this.formData,
      isValidating: isValidating ?? this.isValidating,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    vendorOptions,
    selectedVendor,
    categoryOptions,
    selectedCategory,
    typeOptions,
    selectedType,
    formFields,
    formData,
    isValidating,
    fieldErrors,
    errorMessage,
  ];
}

/// 表单验证错误状态 - 表单验证失败时的状态
class RecoveryValidationError extends RecoveryState {
  /// 保持当前的表单状态
  final RecoveryFormReady formState;

  /// 验证结果
  final ValidationResult validationResult;

  const RecoveryValidationError({
    required this.formState,
    required this.validationResult,
  });

  @override
  List<Object?> get props => [formState, validationResult];
}

/// 表单提交中状态 - 正在提交表单数据时的状态
class RecoverySubmitting extends RecoveryState {
  /// 保持当前的表单状态
  final RecoveryFormReady formState;

  /// 提交进度信息
  final String? message;

  /// 一次性消费的错误信息
  final String? errorMessage;

  const RecoverySubmitting({
    required this.formState,
    this.message,
    this.errorMessage,
  });

  /// 创建新的状态副本，只更新指定字段
  RecoverySubmitting copyWith({
    RecoveryFormReady? formState,
    String? message,
    String? errorMessage,
  }) {
    return RecoverySubmitting(
      formState: formState ?? this.formState,
      message: message ?? this.message,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [formState, message, errorMessage];
}

/// 表单提交成功状态 - 表单提交成功后的状态
class RecoverySubmissionSuccess extends RecoveryState {
  /// 成功提示信息
  final String message;

  /// 提交的数据（用于确认显示）
  final Map<String, String?> submittedData;

  const RecoverySubmissionSuccess({
    required this.message,
    this.submittedData = const {},
  });

  @override
  List<Object?> get props => [message, submittedData];
}

// === 两步提交相关状态 ===

/// Step3提交成功状态 - 第一步提交成功，等待用户确认
class RecoveryStep3Success extends RecoveryState {
  /// 保持当前的表单状态（供用户查看）
  final RecoveryFormReady formState;

  /// Step3提交的结果数据
  final Step3Result step3Result;

  /// 一次性消费的错误信息
  final String? errorMessage;

  const RecoveryStep3Success({
    required this.formState,
    required this.step3Result,
    this.errorMessage,
  });

  /// 创建新的状态副本，只更新指定字段
  RecoveryStep3Success copyWith({
    RecoveryFormReady? formState,
    Step3Result? step3Result,
    String? errorMessage,
  }) {
    return RecoveryStep3Success(
      formState: formState ?? this.formState,
      step3Result: step3Result ?? this.step3Result,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [formState, step3Result, errorMessage];
}

/// Step4进行中状态 - 正在进行QR扫描和最终提交
class RecoveryStep4InProgress extends RecoveryState {
  /// 保持当前的表单状态
  final RecoveryFormReady formState;

  /// Step3的结果数据
  final Step3Result step3Result;

  /// 当前的状态描述
  final String statusMessage;

  /// 是否正在提交Step4
  final bool isSubmittingStep4;

  /// 一次性消费的错误信息
  final String? errorMessage;

  const RecoveryStep4InProgress({
    required this.formState,
    required this.step3Result,
    required this.statusMessage,
    this.isSubmittingStep4 = false,
    this.errorMessage,
  });

  /// 创建新的状态副本，只更新指定字段
  RecoveryStep4InProgress copyWith({
    RecoveryFormReady? formState,
    Step3Result? step3Result,
    String? statusMessage,
    bool? isSubmittingStep4,
    String? errorMessage,
  }) {
    return RecoveryStep4InProgress(
      formState: formState ?? this.formState,
      step3Result: step3Result ?? this.step3Result,
      statusMessage: statusMessage ?? this.statusMessage,
      isSubmittingStep4: isSubmittingStep4 ?? this.isSubmittingStep4,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    formState,
    step3Result,
    statusMessage,
    isSubmittingStep4,
    errorMessage,
  ];
}

/// 两步提交完成状态 - 整个两步提交流程成功完成
class RecoveryTwoStepSubmissionComplete extends RecoveryState {
  /// 成功提示信息
  final String message;

  /// 提交的表单数据（用于确认显示）
  final Map<String, String?> submittedData;

  /// 扫描的QR码（用于确认显示）
  final String scannedQrCode;

  const RecoveryTwoStepSubmissionComplete({
    required this.message,
    this.submittedData = const {},
    required this.scannedQrCode,
  });

  @override
  List<Object?> get props => [message, submittedData, scannedQrCode];
}
