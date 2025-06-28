/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 14:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'qr_scan_result.g.dart';

@JsonSerializable()
class QrScanResult extends Equatable {
  const QrScanResult({
    required this.code,
    required this.scannedAt,
    this.isValid = false,
    this.message,
  });

  final String code;
  final DateTime scannedAt;
  final bool isValid;
  final String? message;

  factory QrScanResult.fromJson(Map<String, dynamic> json) =>
      _$QrScanResultFromJson(json);

  Map<String, dynamic> toJson() => _$QrScanResultToJson(this);

  QrScanResult copyWith({
    String? code,
    DateTime? scannedAt,
    bool? isValid,
    String? message,
  }) {
    return QrScanResult(
      code: code ?? this.code,
      scannedAt: scannedAt ?? this.scannedAt,
      isValid: isValid ?? this.isValid,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [code, scannedAt, isValid, message];
}