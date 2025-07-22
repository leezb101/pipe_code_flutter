/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-22 19:59:36
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import 'qr_scan_type.dart';

class QrScanConfig extends Equatable {
  const QrScanConfig({
    required this.scanType,
    this.scanMode = QrScanMode.single,
    this.title,
  });

  final QrScanType scanType;
  final QrScanMode scanMode;
  final String? title;

  String get displayTitle {
    if (title != null) return title!;

    final modePrefix = scanMode == QrScanMode.batch ? '连续' : '单个';
    switch (scanType) {
      case QrScanType.inbound:
        return '$modePrefix入库扫码';
      case QrScanType.outbound:
        return '$modePrefix出库扫码';
      case QrScanType.returnMaterial:
        return '$modePrefix退库扫码';
      case QrScanType.transfer:
        return '$modePrefix调拨扫码';
      case QrScanType.inventory:
        return '$modePrefix盘点扫码';
      case QrScanType.pipeCopy:
        return '$modePrefix截管复制扫码';
      case QrScanType.acceptance:
        return '$modePrefix验收扫码';
      case QrScanType.identification:
        return '扫码识别';
      case QrScanType.materialInbound:
        return '扫码验收入库';
    }
  }

  bool get supportsBatch => scanMode == QrScanMode.batch;

  @override
  List<Object?> get props => [scanType, scanMode, title];
}
