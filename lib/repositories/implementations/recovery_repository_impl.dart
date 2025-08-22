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
import 'package:pipe_code_flutter/models/recovery/recovery_scan_data.dart';
import 'package:pipe_code_flutter/repositories/interfaces/recovery_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/recovery_api_service.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

/// Recovery模块数据仓库实现
/// 负责数据获取、数据转换和验证的具体实现，每次都重新获取最新数据
class RecoveryRepositoryImpl implements RecoveryRepository {
  final RecoveryApiService _apiService;

  // 当前获取到的数据（不做持久化缓存，仅用于方法间传递）
  VendorsMap? _currentVendorsMap;
  MaterialCategoriesList? _currentMaterialCategories;

  RecoveryRepositoryImpl(this._apiService);

  // === 数据获取方法（为Bloc提供数据源）===

  @override
  Future<Result<VendorsMap>> getVendorsMap() async {
    try {
      Logger.info('从API获取供应商数据', tag: 'RecoveryRepository');
      final result = await _apiService.getVendorsMap();

      if (result.isSuccess && result.data != null) {
        _currentVendorsMap = result.data;
        Logger.info('供应商数据获取成功', tag: 'RecoveryRepository');
      }

      return result;
    } catch (e) {
      Logger.error('获取供应商数据失败', tag: 'RecoveryRepository', error: e);
      return Result(code: -1, msg: '获取供应商数据失败: $e', data: null);
    }
  }

  @override
  Future<Result<MaterialCategoriesList>> getMaterialCategories(
    String vendorCode,
  ) async {
    try {
      Logger.info('从API获取物料分类数据，供应商: $vendorCode', tag: 'RecoveryRepository');
      final result = await _apiService.getMaterialCategories(vendorCode);

      if (result.isSuccess && result.data != null) {
        _currentMaterialCategories = result.data;
        Logger.info('物料分类数据获取成功', tag: 'RecoveryRepository');
      }

      return result;
    } catch (e) {
      Logger.error('获取物料分类数据失败', tag: 'RecoveryRepository', error: e);
      return Result(code: -1, msg: '获取物料分类数据失败: $e', data: null);
    }
  }

  // === 数据查询方法（基于当前数据的快速查询）===

  @override
  String? getVendorNameByCode(String vendorCode) {
    if (_currentVendorsMap == null) {
      Logger.warning('供应商数据未加载，无法查询', tag: 'RecoveryRepository');
      return null;
    }

    return _currentVendorsMap!.getVendorName(vendorCode);
  }

  @override
  MaterialCategory? getCategoryByGroup(int group) {
    if (_currentMaterialCategories == null) {
      Logger.warning('物料分类数据未加载，无法查询', tag: 'RecoveryRepository');
      return null;
    }

    return _currentMaterialCategories!.getCategoryByGroup(group);
  }

  @override
  MaterialType? getMaterialTypeByType(int type) {
    if (_currentMaterialCategories == null) {
      Logger.warning('物料分类数据未加载，无法查询', tag: 'RecoveryRepository');
      return null;
    }

    return _currentMaterialCategories!.getMaterialTypeByType(type);
  }

  @override
  List<MaterialType> getMaterialTypesByCategory(int categoryGroup) {
    final category = getCategoryByGroup(categoryGroup);
    if (category == null) {
      Logger.warning('分类 $categoryGroup 不存在', tag: 'RecoveryRepository');
      return [];
    }

    return category.types;
  }

  @override
  List<RetrieveBack> getRetrieveBacksByType(int materialType) {
    final type = getMaterialTypeByType(materialType);
    if (type == null) {
      Logger.warning('物料类型 $materialType 不存在', tag: 'RecoveryRepository');
      return [];
    }

    return type.retrieveBacks;
  }

  // === 数据转换方法（为Bloc提供便捷的转换工具）===

  @override
  List<VendorOption> getVendorOptions() {
    if (_currentVendorsMap == null) {
      Logger.warning('供应商数据未加载，返回空列表', tag: 'RecoveryRepository');
      return [];
    }

    return _currentVendorsMap!.toOptions();
  }

  @override
  List<MaterialCategoryOption> getCategoryOptions() {
    if (_currentMaterialCategories == null) {
      Logger.warning('物料分类数据未加载，返回空列表', tag: 'RecoveryRepository');
      return [];
    }

    return _currentMaterialCategories!.categories
        .map(
          (category) => MaterialCategoryOption.fromMaterialCategory(category),
        )
        .toList();
  }

  @override
  List<MaterialTypeOption> getTypeOptionsByCategory(int categoryGroup) {
    final types = getMaterialTypesByCategory(categoryGroup);
    return types
        .map((type) => MaterialTypeOption.fromMaterialType(type))
        .toList();
  }

  // === 数据验证方法（为Bloc提供验证逻辑）===

  @override
  ValidationResult validateFormData(
    Map<String, String?> formData,
    int materialType,
  ) {
    final retrieveBacks = getRetrieveBacksByType(materialType);

    if (retrieveBacks.isEmpty) {
      return ValidationResult.failure(
        errorMessages: ['无效的物料类型: $materialType'],
      );
    }

    final Map<String, String> fieldErrors = {};
    final List<String> errorMessages = [];

    // 验证每个必填字段
    for (final retrieveBack in retrieveBacks) {
      final value = formData[retrieveBack.key];

      // 检查必填字段是否为空
      if (value == null || value.trim().isEmpty) {
        fieldErrors[retrieveBack.key] = '${retrieveBack.name}不能为空';
      }
    }

    // 如果有字段错误，添加汇总错误信息
    if (fieldErrors.isNotEmpty) {
      errorMessages.add('请完善以下必填信息：${fieldErrors.values.join('、')}');
    }

    final isValid = fieldErrors.isEmpty && errorMessages.isEmpty;

    if (isValid) {
      return ValidationResult.success();
    } else {
      return ValidationResult.failure(
        errorMessages: errorMessages,
        fieldErrors: fieldErrors,
      );
    }
  }

  @override
  Map<String, String?> buildSubmissionData(
    int materialType,
    Map<String, String?> formData,
  ) {
    final retrieveBacks = getRetrieveBacksByType(materialType);
    final Map<String, String?> submissionData = {};

    // 只包含有效的字段
    for (final retrieveBack in retrieveBacks) {
      final value = formData[retrieveBack.key];
      if (value != null && value.trim().isNotEmpty) {
        submissionData[retrieveBack.key] = value.trim();
      }
    }

    Logger.info('构建提交数据: $submissionData', tag: 'RecoveryRepository');
    return submissionData;
  }

  // === 数据管理方法===

  @override
  bool get hasValidCache {
    // 由于不使用缓存，始终返回false，强制重新加载
    return false;
  }

  @override
  void clearCache() {
    Logger.info('清除当前数据', tag: 'RecoveryRepository');
    _currentVendorsMap = null;
    _currentMaterialCategories = null;
  }

  @override
  Future<Result<bool>> preloadData() async {
    try {
      Logger.info('开始预加载数据', tag: 'RecoveryRepository');

      // 第一步：获取供应商数据
      final vendorsResult = await getVendorsMap();
      if (vendorsResult.isFailure) {
        final errorMsg = '获取供应商数据失败: ${vendorsResult.msg}';
        Logger.error(errorMsg, tag: 'RecoveryRepository');
        return Result(code: -1, msg: errorMsg, data: false);
      }

      // 检查供应商数据是否为空
      final vendorOptions = getVendorOptions();
      if (vendorOptions.isEmpty) {
        const errorMsg = '供应商数据为空';
        Logger.error(errorMsg, tag: 'RecoveryRepository');
        return Result(code: -1, msg: errorMsg, data: false);
      }

      // 第二步：使用第一个供应商的code获取材料分类数据
      final defaultVendorCode = vendorOptions.first.code;
      Logger.info(
        '使用默认供应商: $defaultVendorCode 加载材料分类',
        tag: 'RecoveryRepository',
      );

      final categoriesResult = await getMaterialCategories(defaultVendorCode);
      if (categoriesResult.isFailure) {
        final errorMsg = '获取材料分类数据失败: ${categoriesResult.msg}';
        Logger.error(errorMsg, tag: 'RecoveryRepository');
        return Result(code: -1, msg: errorMsg, data: false);
      }

      Logger.info('预加载数据成功', tag: 'RecoveryRepository');
      return Result(code: 0, msg: '预加载成功', data: true);
    } catch (e) {
      Logger.error('预加载数据异常', tag: 'RecoveryRepository', error: e);
      return Result(code: -1, msg: '预加载失败: $e', data: false);
    }
  }

  // === 两步提交方法实现 ===

  @override
  Future<Result<Step3Result>> submitStep3Fields(
    String vendorCode,
    int materialType,
    Map<String, String?> formData,
  ) async {
    try {
      Logger.info(
        'Step3提交: 供应商=$vendorCode, 材料类型=$materialType',
        tag: 'RecoveryRepository',
      );

      // 过滤掉空值，准备提交数据
      final Map<String, dynamic> submitFields = {};
      formData.forEach((key, value) {
        if (value != null && value.trim().isNotEmpty) {
          submitFields[key] = value.trim();
        }
      });

      Logger.info('Step3提交字段: $submitFields', tag: 'RecoveryRepository');

      // 调用API service的step3方法
      final apiResult = await _apiService.submitStep3Fields(
        code: vendorCode,
        type: materialType,
        fields: submitFields,
      );

      if (apiResult.isFailure) {
        Logger.error(
          'Step3 API调用失败: ${apiResult.msg}',
          tag: 'RecoveryRepository',
        );
        return Result(code: apiResult.code, msg: apiResult.msg, data: null);
      }

      // 从API返回的Map中提取数据和key
      final responseData = apiResult.data!;
      final headerKey = responseData['key'] as String?;
      final scanDataJson = responseData['data'];

      if (headerKey == null || headerKey.isEmpty) {
        const errorMsg = 'Step3响应缺少header key';
        Logger.error(errorMsg, tag: 'RecoveryRepository');
        return Result(code: -1, msg: errorMsg, data: null);
      }

      if (scanDataJson == null) {
        const errorMsg = 'Step3响应缺少扫描数据';
        Logger.error(errorMsg, tag: 'RecoveryRepository');
        return Result(code: -1, msg: errorMsg, data: null);
      }

      // 序列化RecoveryScanData
      RecoveryScanData scanData;
      try {
        scanData = RecoveryScanData.fromJson(
          scanDataJson as Map<String, dynamic>,
        );
      } catch (e) {
        Logger.error(
          'RecoveryScanData序列化失败',
          tag: 'RecoveryRepository',
          error: e,
        );
        return Result(code: -1, msg: '数据序列化失败: $e', data: null);
      }

      // 创建Step3Result
      final step3Result = Step3Result(scanData: scanData, headerKey: headerKey);

      Logger.info('Step3提交成功，headerKey: $headerKey', tag: 'RecoveryRepository');
      return Result(code: 0, msg: 'Step3提交成功', data: step3Result);
    } catch (e) {
      Logger.error('Step3提交异常', tag: 'RecoveryRepository', error: e);
      return Result(code: -1, msg: 'Step3提交失败: $e', data: null);
    }
  }

  @override
  Future<Result<void>> submitStep4Fields(
    String qrCode,
    String headerKey,
  ) async {
    try {
      Logger.info(
        'Step4提交: qrCode=$qrCode, headerKey=$headerKey',
        tag: 'RecoveryRepository',
      );

      // 调用API service的step4方法
      final apiResult = await _apiService.submitStep4Fields(qrCode, headerKey);

      if (apiResult.isFailure) {
        Logger.error(
          'Step4 API调用失败: ${apiResult.msg}',
          tag: 'RecoveryRepository',
        );
        return Result(code: apiResult.code, msg: apiResult.msg, data: null);
      }

      Logger.info('Step4提交成功', tag: 'RecoveryRepository');
      return Result(code: 0, msg: 'Step4提交成功', data: null);
    } catch (e) {
      Logger.error('Step4提交异常', tag: 'RecoveryRepository', error: e);
      return Result(code: -1, msg: 'Step4提交失败: $e', data: null);
    }
  }
}
