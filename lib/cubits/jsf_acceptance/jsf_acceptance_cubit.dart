/*
 * @Author: LeeZB
 * @Date: 2025-09-29
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-29
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/repositories/interfaces/acceptance_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'jsf_acceptance_event.dart';
import 'jsf_acceptance_state.dart';

/// 建设方验收Cubit
/// 使用基于事件的模式管理状态
class JsfAcceptanceCubit extends Cubit<JsfAcceptanceState> {
  final AcceptanceRepository _acceptanceRepository;
  final MaterialHandleRepository _materialHandleRepository;

  JsfAcceptanceCubit({
    required AcceptanceRepository acceptanceRepository,
    required MaterialHandleRepository materialHandleRepository,
  }) : _acceptanceRepository = acceptanceRepository,
       _materialHandleRepository = materialHandleRepository,
       super(const JsfAcceptanceInitial());

  /// 处理事件
  void handleEvent(JsfAcceptanceEvent event) {
    switch (event) {
      case InitializeJsfMaterials():
        _onInitializeMaterials(event);
        break;
      case InitializeJsfMaterialsFromCodes():
        _onInitializeMaterialsFromCodes(event);
        break;
      case AppendJsfMaterialsByCodes():
        _onAppendMaterialsByCodes(event);
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
    }
  }

  void _onInitializeMaterials(InitializeJsfMaterials event) {
    final materialIds = event.materials
        .map((m) => m.baseInfo.materialId)
        .toSet();
    emit(
      JsfAcceptanceEditingState(
        currentMaterials: event.materials,
        materialIds: materialIds,
      ),
    );
    Logger.debug(
      'Initialized JSF materials with ${event.materials.length} items',
      tag: 'JsfAcceptanceCubit',
    );
  }

  Future<void> _onInitializeMaterialsFromCodes(
    InitializeJsfMaterialsFromCodes event,
  ) async {
    try {
      if (event.codes.isEmpty) return;

      emit(const JsfAcceptanceMaterialsLoading());

      final result = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );

      if (result.isSuccess && result.data != null) {
        final materials = result.data!.normals;
        final materialIds = materials.map((m) => m.baseInfo.materialId).toSet();

        emit(
          JsfAcceptanceEditingState(
            currentMaterials: materials,
            materialIds: materialIds,
          ),
        );

        Logger.debug(
          'JSF材料初始化完成，共 ${materials.length} 项',
          tag: 'JsfAcceptanceCubit',
        );
      } else {
        emit(JsfAcceptanceError(message: result.msg));
      }
    } catch (e) {
      Logger.error('JSF材料初始化失败: $e', tag: 'JsfAcceptanceCubit');
      emit(const JsfAcceptanceError(message: '解析扫码列表失败'));
    }
  }

  Future<void> _onAppendMaterialsByCodes(
    AppendJsfMaterialsByCodes event,
  ) async {
    try {
      if (event.codes.isEmpty) return;

      final currentState = state;
      final editing = currentState is JsfAcceptanceEditingState
          ? currentState
          : const JsfAcceptanceEditingState(
              currentMaterials: [],
              materialIds: <int>{},
            );

      // 设置追加材料加载状态
      emit(editing.copyWith(isLoadingAppendMaterials: true));

      final result = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );

      if (result.isSuccess && result.data != null) {
        final newMaterials = result.data!.normals;
        final updatedMaterials = List<MaterialInfo>.from(
          editing.currentMaterials,
        );
        final updatedIds = Set<int>.from(editing.materialIds);
        var addedCount = 0;
        var duplicateCount = 0;

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

        String? message;
        if (addedCount > 0 && duplicateCount > 0) {
          message = '成功追加 $addedCount 项材料，跳过 $duplicateCount 项重复材料';
        } else if (addedCount > 0) {
          message = '成功追加 $addedCount 项材料';
        } else if (duplicateCount > 0) {
          message = '所有 $duplicateCount 项材料均已存在，未追加新材料';
        }

        emit(
          JsfAcceptanceEditingState(
            currentMaterials: updatedMaterials,
            materialIds: updatedIds,
            message: message,
          ),
        );

        Logger.debug(
          'JSF材料追加完成，新增 $addedCount 项，重复 $duplicateCount 项',
          tag: 'JsfAcceptanceCubit',
        );
      } else {
        emit(
          editing.copyWith(
            isLoadingAppendMaterials: false,
            message: result.msg,
          ),
        );
      }
    } catch (e) {
      Logger.error('JSF材料追加失败: $e', tag: 'JsfAcceptanceCubit');
      final currentState = state;
      if (currentState is JsfAcceptanceEditingState) {
        emit(
          currentState.copyWith(
            isLoadingAppendMaterials: false,
            message: '获取物料信息失败',
          ),
        );
      } else {
        emit(const JsfAcceptanceError(message: '获取物料信息失败'));
      }
    }
  }

  Future<void> _onRemoveMaterialsByCodes(
    RemoveJsfMaterialsByCodes event,
  ) async {
    try {
      if (event.codes.isEmpty) return;

      final currentState = state;
      if (currentState is! JsfAcceptanceEditingState) return;

      final result = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );

      if (result.isSuccess && result.data != null) {
        final materialsToRemove = result.data!.normals;
        final idsToRemove = materialsToRemove
            .map((m) => m.baseInfo.materialId)
            .toSet();

        final updatedMaterials = currentState.currentMaterials
            .where((m) => !idsToRemove.contains(m.baseInfo.materialId))
            .toList();
        final updatedIds = updatedMaterials
            .map((m) => m.baseInfo.materialId)
            .toSet();

        final removedCount =
            currentState.currentMaterials.length - updatedMaterials.length;
        final notFoundCount = materialsToRemove.length - removedCount;

        String? message;
        if (removedCount > 0 && notFoundCount > 0) {
          message = '成功剔除 $removedCount 项材料，$notFoundCount 项材料不在当前列表中';
        } else if (removedCount > 0) {
          message = '成功剔除 $removedCount 项材料';
        } else {
          message = '扫描的材料都不在当前列表中，未剔除任何材料';
        }

        emit(
          JsfAcceptanceEditingState(
            currentMaterials: updatedMaterials,
            materialIds: updatedIds,
            message: message,
            warehouseList: currentState.warehouseList,
            warehouseUsers: currentState.warehouseUsers,
          ),
        );

        Logger.debug('JSF材料剔除完成，移除 $removedCount 项', tag: 'JsfAcceptanceCubit');
      } else {
        emit(currentState.copyWith(message: result.msg));
      }
    } catch (e) {
      Logger.error('JSF材料剔除失败: $e', tag: 'JsfAcceptanceCubit');
      final currentState = state;
      if (currentState is JsfAcceptanceEditingState) {
        emit(currentState.copyWith(message: '剔除失败'));
      } else {
        emit(const JsfAcceptanceError(message: '剔除失败'));
      }
    }
  }

  Future<void> _onLoadWarehouseList(LoadJsfWarehouseList event) async {
    try {
      final currentState = state;

      Logger.info('Loading warehouse list for JSF', tag: 'JsfAcceptanceCubit');

      final result = await _acceptanceRepository.getWarehouseList();

      if (result.isSuccess && result.data != null) {
        final warehouseList = result.data!;

        // 如果当前是编辑状态，保持编辑状态并更新仓库列表
        if (currentState is JsfAcceptanceEditingState) {
          emit(currentState.copyWith(warehouseList: warehouseList));
        } else {
          // 发出独立的仓库加载状态
          emit(JsfAcceptanceWarehouseLoaded(warehouseList: warehouseList));
        }

        Logger.debug(
          'JSF仓库列表加载成功，共 ${warehouseList.length} 个仓库',
          tag: 'JsfAcceptanceCubit',
        );
      } else {
        emit(JsfAcceptanceError(message: result.msg));
      }
    } catch (e) {
      emit(const JsfAcceptanceError(message: '获取仓库列表失败，请重试'));
      Logger.error(
        'Error loading JSF warehouse list: $e',
        tag: 'JsfAcceptanceCubit',
      );
    }
  }

  Future<void> _onLoadWarehouseUsers(LoadJsfWarehouseUsers event) async {
    try {
      final currentState = state;

      Logger.info('Loading warehouse users for JSF', tag: 'JsfAcceptanceCubit');

      final result = await _acceptanceRepository.getWarehouseUsers(
        warehouseId: event.warehouseId,
      );

      if (result.isSuccess && result.data != null) {
        final warehouseUsers = result.data!.warehouseUsers;

        // 如果当前是编辑状态，保持编辑状态并更新仓库用户列表
        if (currentState is JsfAcceptanceEditingState) {
          emit(currentState.copyWith(warehouseUsers: warehouseUsers));
        } else {
          // 发出独立的仓库用户加载状态
          emit(
            JsfAcceptanceWarehouseUsersLoaded(warehouseUsers: warehouseUsers),
          );
        }

        Logger.debug(
          'JSF仓库用户加载成功，共 ${warehouseUsers.length} 个用户',
          tag: 'JsfAcceptanceCubit',
        );
      } else {
        emit(JsfAcceptanceError(message: result.msg));
      }
    } catch (e) {
      emit(const JsfAcceptanceError(message: '获取仓库用户失败，请重试'));
      Logger.error(
        'Error loading JSF warehouse users: $e',
        tag: 'JsfAcceptanceCubit',
      );
    }
  }

  Future<void> _onSubmitAcceptance(SubmitJsfAcceptance event) async {
    try {
      emit(const JsfAcceptanceSubmitting());
      Logger.info('Submitting JSF acceptance', tag: 'JsfAcceptanceCubit');

      final result = await _acceptanceRepository.submitJsfAcceptance(
        event.request,
      );

      if (result.isSuccess) {
        emit(const JsfAcceptanceSubmitted());
        Logger.info(
          'JSF acceptance submitted successfully',
          tag: 'JsfAcceptanceCubit',
        );
      } else {
        emit(JsfAcceptanceError(message: result.msg));
        Logger.error(
          'JSF acceptance submission failed: ${result.msg}',
          tag: 'JsfAcceptanceCubit',
        );
      }
    } catch (e) {
      emit(const JsfAcceptanceError(message: '提交验收失败，请重试'));
      Logger.error(
        'Error submitting JSF acceptance: $e',
        tag: 'JsfAcceptanceCubit',
      );
    }
  }

  void _onClearMessage(ClearJsfMessage event) {
    final currentState = state;
    if (currentState is JsfAcceptanceEditingState) {
      emit(currentState.copyWith(message: null));
    }
  }
}
