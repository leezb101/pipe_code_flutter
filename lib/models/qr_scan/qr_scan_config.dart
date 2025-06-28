/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 14:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import 'qr_scan_type.dart';

class QrScanConfig extends Equatable {
  const QrScanConfig({
    required this.scanType,
    this.acceptanceType,
    this.title,
  });

  final QrScanType scanType;
  final AcceptanceType? acceptanceType;
  final String? title;

  String get displayTitle {
    switch (scanType) {
      case QrScanType.acceptance:
        return acceptanceType?.displayName ?? '验收扫码';
      case QrScanType.verification:
        return '核销扫码';
      case QrScanType.inspection:
        return '巡检扫码';
    }
  }

  bool get supportsBatch => 
      scanType == QrScanType.acceptance && 
      acceptanceType == AcceptanceType.batch;

  @override
  List<Object?> get props => [scanType, acceptanceType, title];
}