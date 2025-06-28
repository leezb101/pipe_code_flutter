/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 14:05:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import '../../models/qr_scan/qr_scan_config.dart';

abstract class QrScanEvent extends Equatable {
  const QrScanEvent();

  @override
  List<Object?> get props => [];
}

class InitializeScan extends QrScanEvent {
  const InitializeScan(this.config);

  final QrScanConfig config;

  @override
  List<Object?> get props => [config];
}

class CodeScanned extends QrScanEvent {
  const CodeScanned(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

class ValidateCode extends QrScanEvent {
  const ValidateCode(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

class FinishBatchScan extends QrScanEvent {
  const FinishBatchScan();
}

class ResetScan extends QrScanEvent {
  const ResetScan();
}

class ProcessScannedCodes extends QrScanEvent {
  const ProcessScannedCodes();
}

class RemoveScannedCode extends QrScanEvent {
  const RemoveScannedCode(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}