/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 14:50:47
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'qr_scan_type.dart';

part 'qr_scan_config.g.dart';

@JsonSerializable()
class QrScanConfig extends Equatable {
  const QrScanConfig({
    required this.scanType,
    this.scanMode = QrScanMode.single,
    this.title,
    this.existingCodesToExclude,
    this.context,
  });

  final QrScanType scanType;
  final QrScanMode scanMode;
  final String? title;
  final List<String>? existingCodesToExclude;

  /// 额外的上下文信息，用于策略判断调用来源
  final Map<String, dynamic>? context;

  factory QrScanConfig.fromJson(Map<String, dynamic> json) =>
      _$QrScanConfigFromJson(json);

  Map<String, dynamic> toJson() => _$QrScanConfigToJson(this);

  String get displayTitle {
    if (title != null) return title!;

    final modePrefix = scanMode == QrScanMode.batch ? '连续' : '单个';
    switch (scanType) {
      // case QrScanType.inbound:
      //   return '$modePrefix入库扫码';
      case QrScanType.signout:
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
      case QrScanType.scrap:
        return '$modePrefix报废扫码';
      case QrScanType.install:
        return '扫码安装';
      case QrScanType.raw:
        return '$modePrefix原材料扫码';
    }
  }

  bool get supportsBatch => scanMode == QrScanMode.batch;

  @override
  List<Object?> get props => [
    scanType,
    scanMode,
    title,
    existingCodesToExclude,
    context,
  ];
}
