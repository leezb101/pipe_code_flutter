/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 14:05:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/qr_scan/qr_scan_result.dart';
import '../../models/qr_scan/qr_scan_type.dart';
import '../../services/qr_scan_service.dart';
import '../../services/qr_scan_strategies/qr_scan_strategy.dart';
import 'qr_scan_event.dart';
import 'qr_scan_state.dart';

class QrScanBloc extends Bloc<QrScanEvent, QrScanState> {
  QrScanBloc({required QrScanService qrScanService})
    : _qrScanService = qrScanService,
      super(const QrScanState()) {
    on<InitializeScan>(_onInitializeScan);
    on<CodeScanned>(_onCodeScanned);
    on<ValidateCode>(_onValidateCode);
    on<FinishBatchScan>(_onFinishBatchScan);
    on<ResetScan>(_onResetScan);
    on<ProcessScannedCodes>(_onProcessScannedCodes);
    on<RemoveScannedCode>(_onRemoveScannedCode);
  }

  final QrScanService _qrScanService;

  void _onInitializeScan(InitializeScan event, Emitter<QrScanState> emit) {
    emit(
      state.copyWith(
        status: QrScanStatus.scanning,
        config: event.config,
        scannedCodes: [],
        currentCode: null,
        errorMessage: null,
      ),
    );
  }

  void _onCodeScanned(CodeScanned event, Emitter<QrScanState> emit) {
    // 防止在处理状态时扫描新码
    if (state.status == QrScanStatus.processing) {
      return;
    }
    
    // 防止扫描相同的二维码（在当前处理中）
    if (state.currentCode == event.code) {
      return;
    }
    
    // 对于批量扫描，允许重复扫描不同的码；对于单个扫描，检查是否已扫描过
    if (state.config?.supportsBatch != true && 
        state.scannedCodes.any((result) => result.code == event.code)) {
      return;
    }

    emit(
      state.copyWith(currentCode: event.code, status: QrScanStatus.processing),
    );

    add(ValidateCode(event.code));
  }

  Future<void> _onValidateCode(
    ValidateCode event,
    Emitter<QrScanState> emit,
  ) async {
    try {
      final isValid = await _qrScanService.validateCode(event.code);

      if (isValid) {
        final result = QrScanResult(
          code: event.code,
          scannedAt: DateTime.now(),
          isValid: true,
        );

        final updatedCodes = List<QrScanResult>.from(state.scannedCodes);

        if (!updatedCodes.any((r) => r.code == event.code)) {
          updatedCodes.add(result);
        }

        if (state.config?.supportsBatch == true) {
          // 批量模式：添加到列表，保持扫码状态，等待更多扫码或手动结束
          emit(
            state.copyWith(
              status: QrScanStatus.scanning,
              scannedCodes: updatedCodes,
              isValidCode: true,
              currentCode: null, // 清除当前码，准备下次扫码
            ),
          );
        } else {
          // 单个模式：开始处理，然后跳转
          emit(
            state.copyWith(
              status: QrScanStatus.processing,
              scannedCodes: updatedCodes,
              isValidCode: true,
            ),
          );

          add(const ProcessScannedCodes());
        }
      } else {
        emit(
          state.copyWith(
            status: QrScanStatus.error,
            errorMessage: '无效的二维码格式',
            isValidCode: false,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (!isClosed) {
            add(const ResetScan());
          }
        });
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: QrScanStatus.error,
          errorMessage: '验证二维码时发生错误: $e',
          isValidCode: false,
        ),
      );
    }
  }

  Future<void> _onFinishBatchScan(
    FinishBatchScan event,
    Emitter<QrScanState> emit,
  ) async {
    if (state.scannedCodes.isEmpty) {
      emit(
        state.copyWith(
          status: QrScanStatus.error,
          errorMessage: '请至少扫描一个有效的二维码',
        ),
      );
      return;
    }

    // 批量扫码结束，开始处理所有扫码结果
    emit(state.copyWith(status: QrScanStatus.processing));
    add(const ProcessScannedCodes());
  }

  void _onResetScan(ResetScan event, Emitter<QrScanState> emit) {
    emit(
      state.copyWith(
        status: QrScanStatus.scanning,
        currentCode: null,
        errorMessage: null,
        isValidCode: false,
      ),
    );
  }

  Future<void> _onProcessScannedCodes(
    ProcessScannedCodes event,
    Emitter<QrScanState> emit,
  ) async {
    if (state.config == null || state.scannedCodes.isEmpty || state.isProcessing) {
      return;
    }

    try {
      emit(state.copyWith(status: QrScanStatus.processing, isProcessing: true));

      QrScanProcessResult? result;
      switch (state.config!.scanType) {
        case QrScanType.inbound:
          result = await _qrScanService.processInbound(state.scannedCodes);
          break;
        case QrScanType.outbound:
          result = await _qrScanService.processOutbound(state.scannedCodes);
          break;
        case QrScanType.transfer:
          result = await _qrScanService.processTransfer(state.scannedCodes);
          break;
        case QrScanType.inventory:
          result = await _qrScanService.processInventory(state.scannedCodes);
          break;
        case QrScanType.pipeCopy:
          result = await _qrScanService.processPipeCopy(state.scannedCodes);
          break;
        case QrScanType.identification:
          result = await _qrScanService.processIdentification(state.scannedCodes);
          break;
        case QrScanType.returnMaterial:
          result = await _qrScanService.processReturnMaterial(state.scannedCodes);
          break;
      }

      if (result != null && !result.success) {
        emit(
          state.copyWith(
            status: QrScanStatus.error,
            errorMessage: result.errorMessage ?? '处理扫码结果时发生错误',
            isProcessing: false,
          ),
        );
      } else {
        // 处理完成，设置为 processComplete 状态
        emit(
          state.copyWith(
            status: QrScanStatus.processComplete,
            isProcessing: false,
            processResult: result,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: QrScanStatus.error,
          errorMessage: '处理扫码结果时发生错误: $e',
          isProcessing: false,
        ),
      );
    }
  }

  void _onRemoveScannedCode(
    RemoveScannedCode event,
    Emitter<QrScanState> emit,
  ) {
    final updatedCodes = state.scannedCodes
        .where((result) => result.code != event.code)
        .toList();

    emit(state.copyWith(scannedCodes: updatedCodes));
  }
}
