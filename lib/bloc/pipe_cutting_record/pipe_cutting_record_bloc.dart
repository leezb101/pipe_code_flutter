/*
 * @Author: LeeZB  
 * @Date: 2025-10-11 00:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-10-11 00:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/cut/pipe_cutting_record.dart';
import 'package:pipe_code_flutter/services/api/interfaces/cut_api_service.dart';

part 'pipe_cutting_record_event.dart';
part 'pipe_cutting_record_state.dart';

/// 独立的截管记录详情 BLoC
class PipeCuttingRecordBloc
    extends Bloc<PipeCuttingRecordEvent, PipeCuttingRecordState> {
  final CutApiService _cutApiService;

  PipeCuttingRecordBloc({required CutApiService cutApiService})
    : _cutApiService = cutApiService,
      super(PipeCuttingRecordInitial()) {
    on<LoadPipeCuttingRecord>(_onLoadPipeCuttingRecord);
    on<RefreshPipeCuttingRecord>(_onRefreshPipeCuttingRecord);
  }

  Future<void> _onLoadPipeCuttingRecord(
    LoadPipeCuttingRecord event,
    Emitter<PipeCuttingRecordState> emit,
  ) async {
    emit(PipeCuttingRecordLoading());

    try {
      final result = await _cutApiService.getCuttingHistory(event.materialId);

      if (result.isSuccess == true && result.data != null) {
        emit(PipeCuttingRecordLoaded(cuttingRecord: result.data!));
      } else {
        emit(PipeCuttingRecordError(message: result.msg));
      }
    } catch (e) {
      emit(PipeCuttingRecordError(message: e.toString()));
    }
  }

  Future<void> _onRefreshPipeCuttingRecord(
    RefreshPipeCuttingRecord event,
    Emitter<PipeCuttingRecordState> emit,
  ) async {
    // 刷新时复用加载逻辑
    await _onLoadPipeCuttingRecord(
      LoadPipeCuttingRecord(materialId: event.materialId),
      emit,
    );
  }
}
