// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_scan_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrScanResult _$QrScanResultFromJson(Map<String, dynamic> json) => QrScanResult(
  code: json['code'] as String,
  scannedAt: DateTime.parse(json['scannedAt'] as String),
  isValid: json['isValid'] as bool? ?? false,
  message: json['message'] as String?,
);

Map<String, dynamic> _$QrScanResultToJson(QrScanResult instance) =>
    <String, dynamic>{
      'code': instance.code,
      'scannedAt': instance.scannedAt.toIso8601String(),
      'isValid': instance.isValid,
      'message': instance.message,
    };
