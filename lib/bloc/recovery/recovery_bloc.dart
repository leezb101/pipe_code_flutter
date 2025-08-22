/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/recovery/material_categories.dart';
import 'package:pipe_code_flutter/models/recovery/vendors_map.dart';
import 'package:pipe_code_flutter/repositories/interfaces/recovery_repository.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

import 'recovery_event.dart';
import 'recovery_state.dart';

/// Recovery模块的Bloc
/// 负责管理Recovery页面的状态和业务逻辑
///
/// 主要功能：
/// 1. 管理供应商、材料分类、材料类型的选择流程
/// 2. 动态表单字段的生成和管理
/// 3. 表单数据的验证和提交
/// 4. 错误处理和状态管理
class RecoveryBloc extends Bloc<RecoveryEvent, RecoveryState> {
  final RecoveryRepository _repository;

  RecoveryBloc({required RecoveryRepository repository})
    : _repository = repository,
      super(const RecoveryInitial()) {
    // 注册事件处理器
    on<RecoveryInitialized>(_onInitialized);
    on<RecoveryDataRefreshed>(_onDataRefreshed);
    on<RecoveryVendorSelected>(_onVendorSelected);
    on<RecoveryCategorySelected>(_onCategorySelected);
    on<RecoveryMaterialTypeSelected>(_onMaterialTypeSelected);
    on<RecoveryFormFieldChanged>(_onFormFieldChanged);
    on<RecoveryFormValidated>(_onFormValidated);
    on<RecoveryFormSubmitted>(_onFormSubmitted);
    on<RecoveryFormReset>(_onFormReset);
    on<RecoveryValidationErrorsCleared>(_onValidationErrorsCleared);
    on<RecoveryErrorMessageCleared>(_onErrorMessageCleared);

    // === 两步提交相关事件处理器 ===
    on<RecoveryStep3Submitted>(_onStep3Submitted);
    on<RecoveryStep4Confirmed>(_onStep4Confirmed);
    on<RecoveryStep4QrScanned>(_onStep4QrScanned);
    on<RecoveryStep4Cancelled>(_onStep4Cancelled);
  }

  /// 处理初始化事件
  /// 页面首次加载时预加载基础数据
  Future<void> _onInitialized(
    RecoveryInitialized event,
    Emitter<RecoveryState> emit,
  ) async {
    Logger.info('Recovery初始化开始', tag: 'RecoveryBloc');

    emit(const RecoveryLoading(message: '正在加载基础数据...'));

    try {
      // 预加载基础数据
      final preloadResult = await _repository.preloadData();

      if (preloadResult.isFailure) {
        Logger.error('预加载数据失败: ${preloadResult.msg}', tag: 'RecoveryBloc');
        emit(const RecoveryLoading(message: '加载基础数据失败，请重试'));
        return;
      }

      // 获取供应商选项
      final vendorOptions = _repository.getVendorOptions();

      if (vendorOptions.isEmpty) {
        Logger.warning('供应商数据为空', tag: 'RecoveryBloc');
        emit(const RecoveryLoading(message: '暂无可用的供应商数据，请重试'));
        return;
      }

      // 默认选择第一个供应商
      final defaultVendor = vendorOptions.first;

      Logger.info(
        'Recovery初始化完成，默认选择供应商: ${defaultVendor.name}',
        tag: 'RecoveryBloc',
      );

      emit(
        RecoveryVendorsLoaded(
          vendorOptions: vendorOptions,
          selectedVendor: defaultVendor,
        ),
      );

      // 自动触发供应商选择事件，加载材料分类
      add(RecoveryVendorSelected(vendorCode: defaultVendor.code));
    } catch (e, stackTrace) {
      Logger.error('Recovery初始化异常', tag: 'RecoveryBloc', error: e);
      Logger.error('堆栈跟踪', tag: 'RecoveryBloc', error: stackTrace);

      emit(const RecoveryLoading(message: '初始化失败，请重试'));
    }
  }

  /// 处理数据刷新事件
  /// 用户手动刷新或需要重新加载数据时触发
  Future<void> _onDataRefreshed(
    RecoveryDataRefreshed event,
    Emitter<RecoveryState> emit,
  ) async {
    Logger.info('数据刷新开始，强制刷新: ${event.forceRefresh}', tag: 'RecoveryBloc');

    if (event.forceRefresh) {
      _repository.clearCache();
    }

    // 重新初始化
    add(const RecoveryInitialized());
  }

  /// 处理供应商选择事件
  /// 用户选择供应商后加载材料分类数据
  Future<void> _onVendorSelected(
    RecoveryVendorSelected event,
    Emitter<RecoveryState> emit,
  ) async {
    Logger.info('选择供应商: ${event.vendorCode}', tag: 'RecoveryBloc');

    try {
      // 获取当前状态的供应商选项
      List<VendorOption> vendorOptions = [];
      VendorOption? selectedVendor;

      if (state is RecoveryVendorsLoaded) {
        final currentState = state as RecoveryVendorsLoaded;
        vendorOptions = currentState.vendorOptions;
      } else {
        vendorOptions = _repository.getVendorOptions();
      }

      // 查找选中的供应商
      try {
        selectedVendor = vendorOptions.firstWhere(
          (vendor) => vendor.code == event.vendorCode,
        );
      } catch (e) {
        Logger.error('未找到供应商: ${event.vendorCode}', tag: 'RecoveryBloc');
        emit(
          RecoveryVendorsLoaded(
            vendorOptions: vendorOptions,
            errorMessage: '选择的供应商无效',
          ),
        );
        return;
      }

      // 获取该供应商的材料分类数据
      final categoriesResult = await _repository.getMaterialCategories(
        selectedVendor.code,
      );

      if (categoriesResult.isFailure) {
        Logger.error('获取材料分类失败: ${categoriesResult.msg}', tag: 'RecoveryBloc');
        emit(
          RecoveryVendorsLoaded(
            vendorOptions: vendorOptions,
            selectedVendor: selectedVendor,
            errorMessage: '获取材料分类失败，请重试',
          ),
        );
        return;
      }

      // 获取材料分类选项
      final categoryOptions = _repository.getCategoryOptions();

      if (categoryOptions.isEmpty) {
        Logger.warning('材料分类数据为空', tag: 'RecoveryBloc');
        emit(
          RecoveryVendorsLoaded(
            vendorOptions: vendorOptions,
            selectedVendor: selectedVendor,
            errorMessage: '暂无可用的材料分类数据',
          ),
        );
        return;
      }

      Logger.info(
        '材料分类加载完成，共${categoryOptions.length}个分类',
        tag: 'RecoveryBloc',
      );

      emit(
        RecoveryCategoriesLoaded(
          vendorOptions: vendorOptions,
          selectedVendor: selectedVendor,
          categoryOptions: categoryOptions,
        ),
      );
    } catch (e, stackTrace) {
      Logger.error('供应商选择处理异常', tag: 'RecoveryBloc', error: e);
      Logger.error('堆栈跟踪', tag: 'RecoveryBloc', error: stackTrace);

      // 尝试获取当前状态的供应商列表，如果无法获取则使用空列表
      List<VendorOption> fallbackVendorOptions = [];
      if (state is RecoveryVendorsLoaded) {
        fallbackVendorOptions = (state as RecoveryVendorsLoaded).vendorOptions;
      } else {
        fallbackVendorOptions = _repository.getVendorOptions();
      }

      emit(
        RecoveryVendorsLoaded(
          vendorOptions: fallbackVendorOptions,
          errorMessage: '加载材料分类失败，请重试',
        ),
      );
    }
  }

  /// 处理材料分类选择事件
  /// 用户选择材料分类后加载材料类型数据
  Future<void> _onCategorySelected(
    RecoveryCategorySelected event,
    Emitter<RecoveryState> emit,
  ) async {
    Logger.info('选择材料分类: ${event.categoryGroup}', tag: 'RecoveryBloc');

    if (state is! RecoveryCategoriesLoaded) {
      Logger.error('状态错误：当前状态不是RecoveryCategoriesLoaded', tag: 'RecoveryBloc');
      return;
    }

    final currentState = state as RecoveryCategoriesLoaded;

    try {
      // 查找选中的分类
      MaterialCategoryOption? selectedCategory;
      try {
        selectedCategory = currentState.categoryOptions.firstWhere(
          (category) => category.group == event.categoryGroup,
        );
      } catch (e) {
        Logger.error('未找到材料分类: ${event.categoryGroup}', tag: 'RecoveryBloc');
        emit(currentState.copyWith(errorMessage: '选择的材料分类无效'));
        return;
      }

      // 获取该分类下的材料类型选项
      final typeOptions = _repository.getTypeOptionsByCategory(
        event.categoryGroup,
      );

      if (typeOptions.isEmpty) {
        Logger.warning('分类${event.categoryGroup}下无材料类型', tag: 'RecoveryBloc');
        emit(currentState.copyWith(errorMessage: '该分类下暂无可用的材料类型'));
        return;
      }

      Logger.info('材料类型加载完成，共${typeOptions.length}个类型', tag: 'RecoveryBloc');

      emit(
        RecoveryTypesLoaded(
          vendorOptions: currentState.vendorOptions,
          selectedVendor: currentState.selectedVendor,
          categoryOptions: currentState.categoryOptions,
          selectedCategory: selectedCategory,
          typeOptions: typeOptions,
        ),
      );
    } catch (e, stackTrace) {
      Logger.error('材料分类选择处理异常', tag: 'RecoveryBloc', error: e);
      Logger.error('堆栈跟踪', tag: 'RecoveryBloc', error: stackTrace);

      // 回到CategoriesLoaded状态并显示错误
      if (state is RecoveryCategoriesLoaded) {
        final currentState = state as RecoveryCategoriesLoaded;
        emit(currentState.copyWith(errorMessage: '加载材料类型失败，请重试'));
      }
    }
  }

  /// 处理材料类型选择事件
  /// 用户选择材料类型后生成动态表单字段
  Future<void> _onMaterialTypeSelected(
    RecoveryMaterialTypeSelected event,
    Emitter<RecoveryState> emit,
  ) async {
    Logger.info('选择材料类型: ${event.materialType}', tag: 'RecoveryBloc');

    if (state is! RecoveryTypesLoaded) {
      Logger.error('状态错误：当前状态不是RecoveryTypesLoaded', tag: 'RecoveryBloc');
      return;
    }

    final currentState = state as RecoveryTypesLoaded;

    try {
      // 查找选中的材料类型
      MaterialTypeOption? selectedType;
      try {
        selectedType = currentState.typeOptions.firstWhere(
          (type) => type.type == event.materialType,
        );
      } catch (e) {
        Logger.error('未找到材料类型: ${event.materialType}', tag: 'RecoveryBloc');
        emit(currentState.copyWith(errorMessage: '选择的材料类型无效'));
        return;
      }

      // 获取该材料类型的表单字段
      final formFields = _repository.getRetrieveBacksByType(event.materialType);

      if (formFields.isEmpty) {
        Logger.warning('材料类型${event.materialType}无表单字段', tag: 'RecoveryBloc');
        emit(currentState.copyWith(errorMessage: '该材料类型无需填写附加信息'));
        return;
      }

      // 初始化表单数据
      final Map<String, String?> initialFormData = {};
      for (final field in formFields) {
        initialFormData[field.key] = field.value; // 使用默认值（如果有）
      }

      Logger.info('表单字段加载完成，共${formFields.length}个字段', tag: 'RecoveryBloc');

      emit(
        RecoveryFormReady(
          vendorOptions: currentState.vendorOptions,
          selectedVendor: currentState.selectedVendor,
          categoryOptions: currentState.categoryOptions,
          selectedCategory: currentState.selectedCategory,
          typeOptions: currentState.typeOptions,
          selectedType: selectedType,
          formFields: formFields,
          formData: initialFormData,
        ),
      );
    } catch (e, stackTrace) {
      Logger.error('材料类型选择处理异常', tag: 'RecoveryBloc', error: e);
      Logger.error('堆栈跟踪', tag: 'RecoveryBloc', error: stackTrace);

      // 回到TypesLoaded状态并显示错误
      if (state is RecoveryTypesLoaded) {
        final currentState = state as RecoveryTypesLoaded;
        emit(currentState.copyWith(errorMessage: '加载表单字段失败，请重试'));
      }
    }
  }

  /// 处理表单字段变更事件
  /// 用户在动态表单中输入或修改内容时更新表单数据
  void _onFormFieldChanged(
    RecoveryFormFieldChanged event,
    Emitter<RecoveryState> emit,
  ) {
    if (state is! RecoveryFormReady) {
      Logger.warning('状态错误：当前状态不是RecoveryFormReady', tag: 'RecoveryBloc');
      return;
    }

    final currentState = state as RecoveryFormReady;

    Logger.debug(
      '表单字段变更: ${event.fieldKey} = ${event.value}',
      tag: 'RecoveryBloc',
    );

    // 更新表单数据
    final updatedFormData = Map<String, String?>.from(currentState.formData);
    updatedFormData[event.fieldKey] = event.value;

    // 清除该字段的验证错误（如果有）
    final updatedFieldErrors = Map<String, String>.from(
      currentState.fieldErrors,
    );
    updatedFieldErrors.remove(event.fieldKey);

    emit(
      currentState.copyWith(
        formData: updatedFormData,
        fieldErrors: updatedFieldErrors,
      ),
    );
  }

  /// 处理表单验证事件
  /// 验证当前表单数据的完整性和有效性
  void _onFormValidated(
    RecoveryFormValidated event,
    Emitter<RecoveryState> emit,
  ) {
    if (state is! RecoveryFormReady) {
      Logger.warning('状态错误：当前状态不是RecoveryFormReady', tag: 'RecoveryBloc');
      return;
    }

    final currentState = state as RecoveryFormReady;

    Logger.info('开始表单验证', tag: 'RecoveryBloc');

    // 开始验证
    emit(currentState.copyWith(isValidating: true));

    // 执行验证
    final validationResult = _repository.validateFormData(
      currentState.formData,
      currentState.selectedType.type,
    );

    if (validationResult.isValid) {
      Logger.info('表单验证通过', tag: 'RecoveryBloc');

      emit(currentState.copyWith(isValidating: false, fieldErrors: {}));
    } else {
      Logger.warning(
        '表单验证失败: ${validationResult.allErrorMessages}',
        tag: 'RecoveryBloc',
      );

      emit(
        RecoveryValidationError(
          formState: currentState.copyWith(
            isValidating: false,
            fieldErrors: validationResult.fieldErrors,
          ),
          validationResult: validationResult,
        ),
      );
    }
  }

  /// 处理表单提交事件
  /// 验证并开始两步提交流程（触发Step3）
  Future<void> _onFormSubmitted(
    RecoveryFormSubmitted event,
    Emitter<RecoveryState> emit,
  ) async {
    if (state is! RecoveryFormReady) {
      Logger.warning('状态错误：当前状态不是RecoveryFormReady', tag: 'RecoveryBloc');
      return;
    }

    Logger.info('表单提交，开始两步提交流程', tag: 'RecoveryBloc');

    // 触发Step3提交事件
    add(const RecoveryStep3Submitted());
  }

  /// 处理表单重置事件
  /// 重置表单到初始状态
  void _onFormReset(RecoveryFormReset event, Emitter<RecoveryState> emit) {
    Logger.info('表单重置', tag: 'RecoveryBloc');

    // 重新初始化
    add(const RecoveryInitialized());
  }

  /// 处理清除验证错误事件
  /// 清除当前的验证错误状态
  void _onValidationErrorsCleared(
    RecoveryValidationErrorsCleared event,
    Emitter<RecoveryState> emit,
  ) {
    if (state is RecoveryValidationError) {
      final currentState = state as RecoveryValidationError;

      Logger.info('清除验证错误', tag: 'RecoveryBloc');

      emit(currentState.formState.copyWith(fieldErrors: {}));
    }
  }

  /// 处理清除错误信息事件
  /// 清除当前状态中的一次性错误信息
  void _onErrorMessageCleared(
    RecoveryErrorMessageCleared event,
    Emitter<RecoveryState> emit,
  ) {
    Logger.info('清除错误信息', tag: 'RecoveryBloc');

    // 根据当前状态类型清除错误信息
    if (state is RecoveryVendorsLoaded) {
      final currentState = state as RecoveryVendorsLoaded;
      emit(currentState.copyWith(errorMessage: null));
    } else if (state is RecoveryCategoriesLoaded) {
      final currentState = state as RecoveryCategoriesLoaded;
      emit(currentState.copyWith(errorMessage: null));
    } else if (state is RecoveryTypesLoaded) {
      final currentState = state as RecoveryTypesLoaded;
      emit(currentState.copyWith(errorMessage: null));
    } else if (state is RecoveryFormReady) {
      final currentState = state as RecoveryFormReady;
      emit(currentState.copyWith(errorMessage: null));
    } else if (state is RecoveryStep3Success) {
      final currentState = state as RecoveryStep3Success;
      emit(currentState.copyWith(errorMessage: null));
    }
  }

  // === 两步提交相关事件处理器实现 ===

  /// 处理Step3提交事件
  /// 第一步提交表单数据，获取确认信息
  Future<void> _onStep3Submitted(
    RecoveryStep3Submitted event,
    Emitter<RecoveryState> emit,
  ) async {
    if (state is! RecoveryFormReady) {
      Logger.warning('状态错误：当前状态不是RecoveryFormReady', tag: 'RecoveryBloc');
      return;
    }

    final currentState = state as RecoveryFormReady;

    Logger.info('开始Step3提交', tag: 'RecoveryBloc');

    // 先进行验证
    final validationResult = _repository.validateFormData(
      currentState.formData,
      currentState.selectedType.type,
    );

    if (!validationResult.isValid) {
      Logger.warning('Step3提交前验证失败', tag: 'RecoveryBloc');

      emit(
        RecoveryValidationError(
          formState: currentState.copyWith(
            fieldErrors: validationResult.fieldErrors,
          ),
          validationResult: validationResult,
        ),
      );
      return;
    }

    try {
      // 开始Step3提交
      emit(
        RecoverySubmitting(formState: currentState, message: '正在提交数据（第1步）...'),
      );

      // 调用Repository的Step3提交方法
      final step3Result = await _repository.submitStep3Fields(
        currentState.selectedVendor.code,
        currentState.selectedType.type,
        currentState.formData,
      );

      if (step3Result.isFailure) {
        Logger.error('Step3提交失败: ${step3Result.msg}', tag: 'RecoveryBloc');

        emit(
          currentState.copyWith(errorMessage: 'Step3提交失败: ${step3Result.msg}'),
        );
        return;
      }

      Logger.info('Step3提交成功', tag: 'RecoveryBloc');

      // 进入Step3成功状态，等待用户确认
      emit(
        RecoveryStep3Success(
          formState: currentState,
          step3Result: step3Result.data!,
        ),
      );
    } catch (e, stackTrace) {
      Logger.error('Step3提交异常', tag: 'RecoveryBloc', error: e);
      Logger.error('堆栈跟踪', tag: 'RecoveryBloc', error: stackTrace);

      emit(currentState.copyWith(errorMessage: 'Step3提交失败: $e'));
    }
  }

  /// 处理Step4确认事件
  /// 用户确认信息后准备QR扫描
  void _onStep4Confirmed(
    RecoveryStep4Confirmed event,
    Emitter<RecoveryState> emit,
  ) {
    if (state is! RecoveryStep3Success) {
      Logger.warning('状态错误：当前状态不是RecoveryStep3Success', tag: 'RecoveryBloc');
      return;
    }

    final currentState = state as RecoveryStep3Success;

    Logger.info('Step4确认，准备QR扫描', tag: 'RecoveryBloc');

    // 进入Step4进行中状态
    emit(
      RecoveryStep4InProgress(
        formState: currentState.formState,
        step3Result: currentState.step3Result,
        statusMessage: '请扫描QR码完成最终提交',
      ),
    );
  }

  /// 处理Step4 QR扫描完成事件
  /// 用户完成QR扫描后提交最终数据
  Future<void> _onStep4QrScanned(
    RecoveryStep4QrScanned event,
    Emitter<RecoveryState> emit,
  ) async {
    if (state is! RecoveryStep4InProgress) {
      Logger.warning('状态错误：当前状态不是RecoveryStep4InProgress', tag: 'RecoveryBloc');
      return;
    }

    final currentState = state as RecoveryStep4InProgress;

    Logger.info('QR扫描完成，开始Step4提交: ${event.qrCode}', tag: 'RecoveryBloc');

    try {
      // 开始Step4提交
      emit(
        currentState.copyWith(
          statusMessage: '正在提交数据（第2步）...',
          isSubmittingStep4: true,
        ),
      );

      // 调用Repository的Step4提交方法
      final step4Result = await _repository.submitStep4Fields(
        event.qrCode,
        currentState.step3Result.headerKey,
      );

      if (step4Result.isFailure) {
        Logger.error('Step4提交失败: ${step4Result.msg}', tag: 'RecoveryBloc');

        emit(
          RecoveryStep3Success(
            formState: currentState.formState,
            step3Result: currentState.step3Result,
            errorMessage: 'Step4提交失败: ${step4Result.msg}',
          ),
        );
        return;
      }

      Logger.info('Step4提交成功，两步提交流程完成', tag: 'RecoveryBloc');

      // 进入两步提交完成状态
      emit(
        RecoveryTwoStepSubmissionComplete(
          message: '数据提交成功',
          submittedData: currentState.formState.formData,
          scannedQrCode: event.qrCode,
        ),
      );
    } catch (e, stackTrace) {
      Logger.error('Step4提交异常', tag: 'RecoveryBloc', error: e);
      Logger.error('堆栈跟踪', tag: 'RecoveryBloc', error: stackTrace);

      emit(
        RecoveryStep3Success(
          formState: currentState.formState,
          step3Result: currentState.step3Result,
          errorMessage: 'Step4提交失败: $e',
        ),
      );
    }
  }

  /// 处理Step4取消事件
  /// 用户在确认弹窗中点击取消或返回
  void _onStep4Cancelled(
    RecoveryStep4Cancelled event,
    Emitter<RecoveryState> emit,
  ) {
    Logger.info('Step4取消，回到表单状态', tag: 'RecoveryBloc');

    if (state is RecoveryStep3Success) {
      final currentState = state as RecoveryStep3Success;
      // 回到表单准备状态
      emit(currentState.formState);
    } else if (state is RecoveryStep4InProgress) {
      final currentState = state as RecoveryStep4InProgress;
      // 回到Step3成功状态
      emit(
        RecoveryStep3Success(
          formState: currentState.formState,
          step3Result: currentState.step3Result,
        ),
      );
    }
  }
}
