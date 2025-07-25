/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 14:05:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import '../../models/qr_scan/qr_scan_config.dart';
import '../../models/qr_scan/qr_scan_result.dart';
import '../../services/qr_scan_strategies/qr_scan_strategy.dart';

enum QrScanStatus {
  initial,
  scanning,
  processing,
  processComplete,
  completed,
  error,
}

class QrScanState extends Equatable {
  const QrScanState({
    this.status = QrScanStatus.initial,
    this.config,
    this.scannedCodes = const [],
    this.currentCode,
    this.errorMessage,
    this.isValidCode = false,
    this.isProcessing = false,
    this.processResult,
  });

  final QrScanStatus status;
  final QrScanConfig? config;
  final List<QrScanResult> scannedCodes;
  final String? currentCode;
  final String? errorMessage;
  final bool isValidCode;
  final bool isProcessing;
  final QrScanProcessResult? processResult;

  QrScanState copyWith({
    QrScanStatus? status,
    QrScanConfig? config,
    List<QrScanResult>? scannedCodes,
    String? currentCode,
    String? errorMessage,
    bool? isValidCode,
    bool? isProcessing,
    QrScanProcessResult? processResult,
  }) {
    return QrScanState(
      status: status ?? this.status,
      config: config ?? this.config,
      scannedCodes: scannedCodes ?? this.scannedCodes,
      currentCode: currentCode ?? this.currentCode,
      errorMessage: errorMessage ?? this.errorMessage,
      isValidCode: isValidCode ?? this.isValidCode,
      isProcessing: isProcessing ?? this.isProcessing,
      processResult: processResult ?? this.processResult,
    );
  }

  QrScanState clearError() {
    return copyWith(
      status: QrScanStatus.scanning,
      errorMessage: null,
    );
  }

  QrScanState clearCurrentCode() {
    return copyWith(
      currentCode: null,
      isValidCode: false,
    );
  }

  @override
  List<Object?> get props => [
        status,
        config,
        scannedCodes,
        currentCode,
        errorMessage,
        isValidCode,
        isProcessing,
        processResult,
      ];
}