/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 14:50:47
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
// QrScanType removed. Keep QrScanMode locally.

part 'qr_scan_config.g.dart';

/// 扫码操作类型：首次(初始化)、追加、移除
enum QrScanOperation { initial, append, remove }

/// 扫描模式：单个/连续
enum QrScanMode {
  single('单个扫码'),
  batch('连续扫码');

  const QrScanMode(this.displayName);
  final String displayName;
}

@JsonSerializable()
class QrScanConfig extends Equatable {
  const QrScanConfig({
    this.scanMode = QrScanMode.single,
    this.title,
    this.existingCodesToExclude,
    this.context,
    QrScanOperation this.operation = QrScanOperation.initial,
    this.skipValidation = false,
  });

  final QrScanMode scanMode;
  final String? title;
  final List<String>? existingCodesToExclude;

  /// 额外的上下文信息，用于策略判断调用来源
  final Map<String, dynamic>? context;

  /// 语义化的扫码操作类型
  @JsonKey(defaultValue: QrScanOperation.initial)
  final QrScanOperation operation;

  /// 是否跳过格式校验（逐步取代对 QrScanType.raw 的特判）
  @JsonKey(defaultValue: false)
  final bool skipValidation;

  factory QrScanConfig.fromJson(Map<String, dynamic> json) {
    final cfg = _$QrScanConfigFromJson(json);
    // 兼容旧版本：没有 operation 字段但 isRemoveOperation = true 的情况
    // 旧字段 isRemoveOperation 已删除；兼容逻辑可忽略或根据需要添加
    return cfg;
  }

  Map<String, dynamic> toJson() => _$QrScanConfigToJson(this);

  String get displayTitle {
    if (title != null) return title!;
    final modePrefix = scanMode == QrScanMode.batch ? '连续' : '单个';
    return '$modePrefix扫码';
  }

  bool get supportsBatch => scanMode == QrScanMode.batch;

  /// 是否删除操作
  bool get isRemove => operation == QrScanOperation.remove;

  QrScanConfig copyWith({
    QrScanMode? scanMode,
    String? title,
    List<String>? existingCodesToExclude,
    Map<String, dynamic>? context,
    QrScanOperation? operation,
    bool? skipValidation,
  }) {
    return QrScanConfig(
      scanMode: scanMode ?? this.scanMode,
      title: title ?? this.title,
      existingCodesToExclude:
          existingCodesToExclude ?? this.existingCodesToExclude,
      context: context ?? this.context,
      operation: operation ?? this.operation,
      skipValidation: skipValidation ?? this.skipValidation,
    );
  }

  @override
  List<Object?> get props => [
    scanMode,
    title,
    existingCodesToExclude,
    context,
    operation,
    skipValidation,
  ];
}
