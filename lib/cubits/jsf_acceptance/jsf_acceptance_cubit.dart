/*
 * @Author: LeeZB
 * @Date: 2025-09-29
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-29
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:pipe_code_flutter/repositories/interfaces/acceptance_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/user/current_user_on_project_role_info.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'jsf_acceptance_event.dart';
import 'jsf_acceptance_state.dart';

/// 建设方验收Cubit（使用RxDart实现）
/// 使用RxDart的BehaviorSubject管理状态
class JsfAcceptanceCubit {
  final AcceptanceRepository _acceptanceRepository;
  final MaterialHandleRepository _materialHandleRepository;

  // 使用 BehaviorSubject 管理状态
  final BehaviorSubject<JsfAcceptanceState> _stateSubject =
      BehaviorSubject<JsfAcceptanceState>.seeded(const JsfAcceptanceState());

  // 公开状态流
  Stream<JsfAcceptanceState> get state => _stateSubject.stream;

  // 获取当前状态
  JsfAcceptanceState get currentState => _stateSubject.value;

  JsfAcceptanceCubit({
    required AcceptanceRepository acceptanceRepository,
    required MaterialHandleRepository materialHandleRepository,
  }) : _acceptanceRepository = acceptanceRepository,
       _materialHandleRepository = materialHandleRepository;

  /// 更新状态
  void _updateState(JsfAcceptanceState newState) {
    _stateSubject.add(newState);
  }

  /// 处理事件
  void handleEvent(
    JsfAcceptanceEvent event, {
    String? projectPurNm,
    ProjectSupplyType? supplyType,
  }) {
    switch (event) {
      case InitializeJsfMaterials():
        _onInitializeMaterials(
          event,
          projectPurNm: projectPurNm,
          supplyType: supplyType,
        );
        break;
      case InitializeJsfMaterialsFromCodes():
        _onInitializeMaterialsFromCodes(
          event,
          projectPurNm: projectPurNm,
          supplyType: supplyType,
        );
        break;
      case AppendJsfMaterialsByCodes():
        _onAppendMaterialsByCodes(
          event,
          projectPurNm: projectPurNm,
          supplyType: supplyType,
        );
        break;
      case RemoveJsfMaterialsByCodes():
        _onRemoveMaterialsByCodes(event);
        break;
      case LoadJsfWarehouseList():
        _onLoadWarehouseList(event);
        break;
      case LoadJsfWarehouseUsers():
        _onLoadWarehouseUsers(event);
        break;
      case SubmitJsfAcceptance():
        _onSubmitAcceptance(event);
        break;
      case ClearJsfMessage():
        _onClearMessage(event);
        break;
      case ConfirmPurchaserValidationWarning():
        _onConfirmPurchaserValidationWarning(event);
        break;
    }
  }

  void _onInitializeMaterials(
    InitializeJsfMaterials event, {
    String? projectPurNm,
    ProjectSupplyType? supplyType,
  }) {
    final materialIds = event.materials
        .map((m) => m.baseInfo.materialId)
        .toSet();

    // 检查采购方不匹配的材料
    final mismatchMaterials = _checkPurchaserMismatch(
      event.materials,
      projectPurNm,
      supplyType,
    );

    _updateState(
      currentState.copyWith(
        materials: event.materials,
        materialIds: materialIds,
        showPurchaserValidationWarning: mismatchMaterials.isNotEmpty,
        purchaserMismatchMaterials: mismatchMaterials,
      ),
    );

    Logger.debug(
      'Initialized JSF materials with ${event.materials.length} items',
      tag: 'JsfAcceptanceController',
    );

    if (mismatchMaterials.isNotEmpty) {
      Logger.warning(
        'Found ${mismatchMaterials.length} materials with purchaser mismatch',
        tag: 'JsfAcceptanceController',
      );
    }
  }

  Future<void> _onInitializeMaterialsFromCodes(
    InitializeJsfMaterialsFromCodes event, {
    String? projectPurNm,
    ProjectSupplyType? supplyType,
  }) async {
    try {
      if (event.codes.isEmpty) return;

      _updateState(currentState.copyWith(isLoadingMaterials: true));

      final result = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );

      if (result.isSuccess && result.data != null) {
        final materials = result.data!.normals;
        final errorMaterials = result.data!.errors; // 获取错误材料
        final materialIds = materials.map((m) => m.baseInfo.materialId).toSet();

        // 检查采购方不匹配的材料
        final mismatchMaterials = _checkPurchaserMismatch(
          materials,
          projectPurNm,
          supplyType,
        );

        _updateState(
          currentState.copyWith(
            materials: materials,
            materialIds: materialIds,
            errorMaterials: errorMaterials, // 设置错误材料
            isLoadingMaterials: false,
            showPurchaserValidationWarning: mismatchMaterials.isNotEmpty,
            purchaserMismatchMaterials: mismatchMaterials,
          ),
        );

        Logger.debug(
          'JSF材料初始化完成，共 ${materials.length} 项正常材料，${errorMaterials.length} 项异常材料',
          tag: 'JsfAcceptanceController',
        );

        if (mismatchMaterials.isNotEmpty) {
          Logger.warning(
            'Found ${mismatchMaterials.length} materials with purchaser mismatch',
            tag: 'JsfAcceptanceController',
          );
        }
      } else {
        _updateState(
          currentState.copyWith(
            isLoadingMaterials: false,
            errorMessage: result.msg,
          ),
        );
      }
    } catch (e) {
      Logger.error('JSF材料初始化失败: $e', tag: 'JsfAcceptanceController');
      _updateState(
        currentState.copyWith(
          isLoadingMaterials: false,
          errorMessage: '解析扫码列表失败',
        ),
      );
    }
  }

  Future<void> _onAppendMaterialsByCodes(
    AppendJsfMaterialsByCodes event, {
    String? projectPurNm,
    ProjectSupplyType? supplyType,
  }) async {
    try {
      if (event.codes.isEmpty) return;

      // 设置追加材料加载状态
      _updateState(currentState.copyWith(isLoadingAppendMaterials: true));

      final result = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );

      if (result.isSuccess && result.data != null) {
        final newMaterials = result.data!.normals;
        final newErrorMaterials = result.data!.errors; // 获取错误材料
        final updatedMaterials = List<MaterialInfo>.from(
          currentState.materials,
        );
        final updatedIds = Set<int>.from(currentState.materialIds);
        final updatedErrorMaterials = List<dynamic>.from(
          currentState.errorMaterials,
        );

        var addedCount = 0;
        var duplicateCount = 0;
        var errorAddedCount = 0;

        // 筛选新材料，基于materialId去重
        for (final material in newMaterials) {
          final materialId = material.baseInfo.materialId;
          if (!updatedIds.contains(materialId)) {
            updatedMaterials.add(material);
            updatedIds.add(materialId);
            addedCount++;
          } else {
            duplicateCount++;
          }
        }

        // 追加错误材料，避免重复
        for (final error in newErrorMaterials) {
          // 简单的重复检查，基于qrCode
          final qrCode = _getErrorQrCode(error);
          final isDuplicate = updatedErrorMaterials.any(
            (existingError) => _getErrorQrCode(existingError) == qrCode,
          );

          if (!isDuplicate) {
            updatedErrorMaterials.add(error);
            errorAddedCount++;
          }
        }

        // 检查新添加材料的采购方匹配情况
        final mismatchMaterials = _checkPurchaserMismatch(
          updatedMaterials,
          projectPurNm,
          supplyType,
        );

        // 构建消息
        final messages = <String>[];
        if (addedCount > 0) {
          messages.add('追加 $addedCount 项正常材料');
        }
        if (errorAddedCount > 0) {
          messages.add('追加 $errorAddedCount 项异常材料');
        }
        if (duplicateCount > 0) {
          messages.add('跳过 $duplicateCount 项重复材料');
        }

        final message = messages.isNotEmpty
            ? messages.join('，')
            : '所有材料均已存在，未追加新材料';

        _updateState(
          currentState.copyWith(
            materials: updatedMaterials,
            materialIds: updatedIds,
            errorMaterials: updatedErrorMaterials,
            isLoadingAppendMaterials: false,
            message: message,
            showPurchaserValidationWarning: mismatchMaterials.isNotEmpty,
            purchaserMismatchMaterials: mismatchMaterials,
          ),
        );

        Logger.debug(
          'JSF材料追加完成，新增 $addedCount 项正常材料，$errorAddedCount 项异常材料，重复 $duplicateCount 项',
          tag: 'JsfAcceptanceController',
        );

        if (mismatchMaterials.isNotEmpty) {
          Logger.warning(
            'Found ${mismatchMaterials.length} materials with purchaser mismatch after append',
            tag: 'JsfAcceptanceController',
          );
        }
      } else {
        _updateState(
          currentState.copyWith(
            isLoadingAppendMaterials: false,
            message: result.msg,
          ),
        );
      }
    } catch (e) {
      Logger.error('JSF材料追加失败: $e', tag: 'JsfAcceptanceController');
      _updateState(
        currentState.copyWith(
          isLoadingAppendMaterials: false,
          message: '获取物料信息失败',
        ),
      );
    }
  }

  Future<void> _onRemoveMaterialsByCodes(
    RemoveJsfMaterialsByCodes event,
  ) async {
    try {
      if (event.codes.isEmpty) return;

      final result = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );

      if (result.isSuccess && result.data != null) {
        final materialsToRemove = result.data!.normals;
        final errorsToRemove = result.data!.errors; // 获取要剔除的错误材料
        final idsToRemove = materialsToRemove
            .map((m) => m.baseInfo.materialId)
            .toSet();

        // 处理正常材料剔除
        final updatedMaterials = currentState.materials
            .where((m) => !idsToRemove.contains(m.baseInfo.materialId))
            .toList();
        final updatedIds = updatedMaterials
            .map((m) => m.baseInfo.materialId)
            .toSet();

        final removedNormalCount =
            currentState.materials.length - updatedMaterials.length;
        final notFoundNormalCount =
            materialsToRemove.length - removedNormalCount;

        // 处理错误材料剔除
        final updatedErrorMaterials = List<dynamic>.from(
          currentState.errorMaterials,
        );
        int removedErrorCount = 0;
        int notFoundErrorCount = 0;

        for (final errorToRemove in errorsToRemove) {
          final qrCodeToRemove = _getErrorQrCode(errorToRemove);
          bool found = false;

          for (int i = updatedErrorMaterials.length - 1; i >= 0; i--) {
            final existingQrCode = _getErrorQrCode(updatedErrorMaterials[i]);
            if (existingQrCode == qrCodeToRemove && qrCodeToRemove.isNotEmpty) {
              updatedErrorMaterials.removeAt(i);
              removedErrorCount++;
              found = true;
              break;
            }
          }

          if (!found) {
            notFoundErrorCount++;
          }
        }

        // 构建消息
        final messages = <String>[];
        if (removedNormalCount > 0) {
          messages.add('剔除 $removedNormalCount 项正常材料');
        }
        if (removedErrorCount > 0) {
          messages.add('剔除 $removedErrorCount 项异常材料');
        }
        if (notFoundNormalCount > 0 || notFoundErrorCount > 0) {
          final total = notFoundNormalCount + notFoundErrorCount;
          messages.add('$total 项材料不在当前列表中');
        }

        final message = messages.isNotEmpty
            ? messages.join('，')
            : '扫描的材料都不在当前列表中，未剔除任何材料';

        _updateState(
          currentState.copyWith(
            materials: updatedMaterials,
            materialIds: updatedIds,
            errorMaterials: updatedErrorMaterials,
            message: message,
          ),
        );

        Logger.debug(
          'JSF材料剔除完成，移除 $removedNormalCount 项正常材料，$removedErrorCount 项异常材料',
          tag: 'JsfAcceptanceController',
        );
      } else {
        _updateState(currentState.copyWith(message: result.msg));
      }
    } catch (e) {
      Logger.error('JSF材料剔除失败: $e', tag: 'JsfAcceptanceController');
      _updateState(currentState.copyWith(message: '剔除失败'));
    }
  }

  Future<void> _onLoadWarehouseList(LoadJsfWarehouseList event) async {
    try {
      Logger.info(
        'Loading warehouse list for JSF',
        tag: 'JsfAcceptanceController',
      );

      final result = await _acceptanceRepository.getWarehouseList();

      if (result.isSuccess && result.data != null) {
        final warehouseList = result.data!;

        _updateState(currentState.copyWith(warehouseList: warehouseList));

        Logger.debug(
          'JSF仓库列表加载成功，共 ${warehouseList.length} 个仓库',
          tag: 'JsfAcceptanceController',
        );
      } else {
        _updateState(currentState.copyWith(errorMessage: result.msg));
      }
    } catch (e) {
      _updateState(currentState.copyWith(errorMessage: '获取仓库列表失败，请重试'));
      Logger.error(
        'Error loading JSF warehouse list: $e',
        tag: 'JsfAcceptanceController',
      );
    }
  }

  Future<void> _onLoadWarehouseUsers(LoadJsfWarehouseUsers event) async {
    try {
      Logger.info(
        'Loading warehouse users for JSF',
        tag: 'JsfAcceptanceController',
      );

      final result = await _acceptanceRepository.getWarehouseUsers(
        warehouseId: event.warehouseId,
      );

      if (result.isSuccess && result.data != null) {
        final warehouseUsers = result.data!.warehouseUsers;

        _updateState(currentState.copyWith(warehouseUsers: warehouseUsers));

        Logger.debug(
          'JSF仓库用户加载成功，共 ${warehouseUsers.length} 个用户',
          tag: 'JsfAcceptanceController',
        );
      } else {
        _updateState(currentState.copyWith(errorMessage: result.msg));
      }
    } catch (e) {
      _updateState(currentState.copyWith(errorMessage: '获取仓库用户失败，请重试'));
      Logger.error(
        'Error loading JSF warehouse users: $e',
        tag: 'JsfAcceptanceController',
      );
    }
  }

  Future<void> _onSubmitAcceptance(SubmitJsfAcceptance event) async {
    try {
      _updateState(currentState.copyWith(isSubmitting: true));
      Logger.info('Submitting JSF acceptance', tag: 'JsfAcceptanceController');

      final result = await _acceptanceRepository.submitJsfAcceptance(
        event.request,
      );

      if (result.isSuccess) {
        _updateState(
          currentState.copyWith(isSubmitting: false, isSubmitted: true),
        );
        Logger.info(
          'JSF acceptance submitted successfully',
          tag: 'JsfAcceptanceController',
        );
      } else {
        _updateState(
          currentState.copyWith(isSubmitting: false, errorMessage: result.msg),
        );
        Logger.error(
          'JSF acceptance submission failed: ${result.msg}',
          tag: 'JsfAcceptanceController',
        );
      }
    } catch (e) {
      _updateState(
        currentState.copyWith(isSubmitting: false, errorMessage: '提交验收失败，请重试'),
      );
      Logger.error(
        'Error submitting JSF acceptance: $e',
        tag: 'JsfAcceptanceController',
      );
    }
  }

  void _onClearMessage(ClearJsfMessage event) {
    _updateState(currentState.copyWith(message: null, errorMessage: null));
  }

  void _onConfirmPurchaserValidationWarning(
    ConfirmPurchaserValidationWarning event,
  ) {
    _updateState(
      currentState.copyWith(
        showPurchaserValidationWarning: false,
        purchaserMismatchMaterials: const [],
      ),
    );
    Logger.info(
      'User confirmed purchaser validation warning',
      tag: 'JsfAcceptanceController',
    );
  }

  /// 检查材料采购方与项目采购方是否匹配
  List<String> _checkPurchaserMismatch(
    List<MaterialInfo> materials,
    String? projectPurNm,
    ProjectSupplyType? supplyType,
  ) {
    // 前置判断：根据供材类型决定是否需要进行purNm检查
    if (supplyType == null) {
      return []; // 如果没有供材类型信息，跳过验证
    }

    // 如果是"甲供材"，则不需要进行purNm判断，直接返回空列表
    if (supplyType == ProjectSupplyType.jiaGongCai) {
      return [];
    }

    // 如果是"乙供材"，建设方验收也不需要进行purNm判断
    if (supplyType == ProjectSupplyType.yiGongCai) {
      return [];
    }

    // 只有"甲乙混供"时，才需要进行purNm判断
    if (supplyType != ProjectSupplyType.jiaYiHunGong) {
      return [];
    }

    if (projectPurNm == null || projectPurNm.isEmpty) {
      return []; // 如果没有项目采购方信息，跳过验证
    }

    final mismatchMaterials = <String>[];
    for (final material in materials) {
      final materialPurNm = material.baseInfo.purNm;
      if (materialPurNm != null &&
          materialPurNm.isNotEmpty &&
          materialPurNm != projectPurNm) {
        final materialName = material.baseInfo.prodNm ?? '未知材料';
        mismatchMaterials.add('$materialName (采购方: $materialPurNm)');
      }
    }

    return mismatchMaterials;
  }

  /// 从错误材料对象中提取qrCode
  String _getErrorQrCode(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['qrCode']?.toString() ?? error['qr_code']?.toString() ?? '';
    }
    try {
      return (error as dynamic).qrCode?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  /// 释放资源
  void dispose() {
    _stateSubject.close();
  }
}
