/*
 * @Author: LeeZB
 * @Date: 2025-08-06 18:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 18:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_detail_repository.dart';
import 'material_detail_state.dart';

class MaterialDetailCubit extends Cubit<MaterialDetailState> {
  final MaterialDetailRepository _repository;

  MaterialDetailCubit()
    : _repository = getIt<MaterialDetailRepository>(),
      super(MaterialDetailInitial());

  /// 验证材料编码格式
  bool _isValidMaterialCode(String materialCode) {
    return materialCode.trim().isNotEmpty && 
           materialCode.length >= 3; // 基本长度验证
  }

  /// 加载材料详情
  Future<void> loadMaterialDetail(String materialCode) async {
    // 添加格式验证
    if (!_isValidMaterialCode(materialCode)) {
      emit(MaterialDetailError(message: '材料编码格式无效'));
      return;
    }
    
    emit(MaterialDetailLoading());

    try {
      final materialDetail = await _repository.getMaterialDetail(materialCode);
      emit(MaterialDetailLoaded(materialDetail: materialDetail));

      // 如果材料已切割，自动加载截管记录
      if (materialDetail.cut) {
        await loadCuttingRecord(
          materialDetail.info.baseInfo.materialId.toString(),
        );
      }
    } catch (e) {
      emit(MaterialDetailError(message: e.toString()));
    }
  }

  /// 重新加载材料详情
  Future<void> refreshMaterialDetail(String materialCode) async {
    // 添加格式验证
    if (!_isValidMaterialCode(materialCode)) {
      emit(MaterialDetailError(message: '材料编码格式无效'));
      return;
    }
    
    // 如果当前已加载数据，保持显示直到新数据加载完成
    final currentState = state;
    if (currentState is MaterialDetailLoaded) {
      emit(MaterialDetailLoading());
    }

    try {
      final materialDetail = await _repository.getMaterialDetail(materialCode);
      emit(MaterialDetailLoaded(materialDetail: materialDetail));

      if (materialDetail.cut) {
        await loadCuttingRecord(
          materialDetail.info.baseInfo.materialId.toString(),
        );
      }
    } catch (e) {
      emit(MaterialDetailError(message: e.toString()));
    }
  }

  /// 加载截管记录
  Future<void> loadCuttingRecord(String materialId) async {
    final currentState = state;

    if (currentState is MaterialDetailLoaded) {
      // 更新状态为截管记录加载中
      emit(currentState.copyWith(isLoadingCuttingRecord: true));

      try {
        final cuttingRecord = await _repository.getCuttingHistory(materialId);
        emit(
          currentState.copyWith(
            cuttingRecord: cuttingRecord,
            isLoadingCuttingRecord: false,
          ),
        );
      } catch (e) {
        // 截管记录加载失败不影响主页面，只停止加载状态
        emit(currentState.copyWith(isLoadingCuttingRecord: false));
      }
    }
  }

  @override
  void onChange(Change<MaterialDetailState> change) {
    super.onChange(change);
    // 可以在这里添加日志或调试信息
  }

  /// 手动触发事件（用于测试或特殊情况）
  @override
  Future<void> emit(MaterialDetailState state) async {
    super.emit(state);
  }
}
