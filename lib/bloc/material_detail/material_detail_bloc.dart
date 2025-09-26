/*
 * @Author: LeeZB
 * @Date: 2025-08-06 18:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 18:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_detail_repository.dart';
import 'package:pipe_code_flutter/models/material/material_lifecycle_node.dart';
import 'package:pipe_code_flutter/models/material/scan_identification_response.dart';
import 'package:pipe_code_flutter/models/cut/pipe_cutting_record.dart';

part 'material_detail_state.dart';
part 'material_detail_event.dart';

class MaterialDetailBloc
    extends Bloc<MaterialDetailEvent, MaterialDetailState> {
  final MaterialDetailRepository _repository;

  MaterialDetailBloc({MaterialDetailRepository? repository})
    : _repository = repository ?? getIt<MaterialDetailRepository>(),
      super(MaterialDetailInitial()) {
    on<LoadMaterialDetail>(_onLoadMaterialDetail);
    on<RefreshMaterialDetail>(_onRefreshMaterialDetail);
    on<LoadCuttingRecord>(_onLoadCuttingRecord);
    on<LoadMaterialLifeCycle>(_onLoadMaterialLifecycle);
  }

  /// 验证材料编码格式
  bool _isValidMaterialCode(String materialCode) {
    return materialCode.trim().isNotEmpty && materialCode.length >= 3; // 基本长度验证
  }

  /// 加载材料详情
  Future<void> _onLoadMaterialDetail(
    LoadMaterialDetail event,
    Emitter<MaterialDetailState> emit,
  ) async {
    // 添加格式验证
    if (!_isValidMaterialCode(event.materialCode)) {
      emit(MaterialDetailError(message: '材料编码格式无效'));
      return;
    }

    emit(MaterialDetailLoading());

    try {
      final materialDetail = await _repository.getMaterialDetail(
        event.materialCode,
      );
      emit(MaterialDetailLoaded(materialDetail: materialDetail));
      // 如果材料已切割，自动加载截管记录
      if (materialDetail.cut) {
        add(
          LoadCuttingRecord(
            materialId: materialDetail.info!.baseInfo.materialId.toString(),
          ),
        );
      }
    } catch (e) {
      emit(MaterialDetailError(message: e.toString()));
    }
  }

  /// 重新加载材料详情
  Future<void> _onRefreshMaterialDetail(
    RefreshMaterialDetail event,
    Emitter<MaterialDetailState> emit,
  ) async {
    // 添加格式验证
    if (!_isValidMaterialCode(event.materialCode)) {
      emit(MaterialDetailError(message: '材料编码格式无效'));
      return;
    }

    // 如果当前已加载数据，保持显示直到新数据加载完成
    final currentState = state;
    if (currentState is MaterialDetailLoaded) {
      emit(MaterialDetailLoading());
    }

    try {
      final materialDetail = await _repository.getMaterialDetail(
        event.materialCode,
      );
      emit(MaterialDetailLoaded(materialDetail: materialDetail));

      if (materialDetail.cut) {
        add(
          LoadCuttingRecord(
            materialId: materialDetail.info!.baseInfo.materialId.toString(),
          ),
        );
      }
    } catch (e) {
      emit(MaterialDetailError(message: e.toString()));
    }
  }

  /// 加载截管记录
  Future<void> _onLoadCuttingRecord(
    LoadCuttingRecord event,
    Emitter<MaterialDetailState> emit,
  ) async {
    final currentState = state;

    if (currentState is MaterialDetailLoaded) {
      // 更新状态为截管记录加载中
      emit(
        currentState.copyWith(
          isLoadingCuttingRecord: true,
          clearCuttingRecordError: true,
        ),
      );

      try {
        final cuttingRecord = await _repository.getCuttingHistory(
          event.materialId,
        );
        if (state is MaterialDetailLoaded) {
          emit(
            (state as MaterialDetailLoaded).copyWith(
              cuttingRecord: cuttingRecord,
              isLoadingCuttingRecord: false,
            ),
          );
        }
      } catch (e) {
        // 截管记录加载失败不影响主页面，只停止加载状态
        if (state is MaterialDetailLoaded) {
          emit(
            (state as MaterialDetailLoaded).copyWith(
              isLoadingCuttingRecord: false,
              cuttingRecordError: e.toString(),
            ),
          );
        }
      }
    }
  }

  Future<void> _onLoadMaterialLifecycle(
    LoadMaterialLifeCycle event,
    Emitter<MaterialDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is MaterialDetailLoaded) {
      emit(
        currentState.copyWith(
          isLoadingLifecycle: true,
          clearLifecycleError: true,
        ),
      );
      try {
        final lifecycleNodes = await _repository.getMaterialLifecycle(
          event.materialId,
        );
        if (state is MaterialDetailLoaded) {
          emit(
            (state as MaterialDetailLoaded).copyWith(
              lifecycleNodes: lifecycleNodes,
              isLoadingLifecycle: false,
            ),
          );
        }
      } catch (e) {
        if (state is MaterialDetailLoaded) {
          emit(
            (state as MaterialDetailLoaded).copyWith(
              isLoadingLifecycle: false,
              lifecycleError: e.toString(),
            ),
          );
        }
      }
    }
  }
}
