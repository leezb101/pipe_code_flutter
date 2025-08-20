// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_scan_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrScanConfig _$QrScanConfigFromJson(Map<String, dynamic> json) => QrScanConfig(
  scanMode:
      $enumDecodeNullable(_$QrScanModeEnumMap, json['scanMode']) ??
      QrScanMode.single,
  title: json['title'] as String?,
  existingCodesToExclude: (json['existingCodesToExclude'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  context: json['context'] as Map<String, dynamic>?,
  operation:
      $enumDecodeNullable(_$QrScanOperationEnumMap, json['operation']) ??
      QrScanOperation.initial,
  skipValidation: json['skipValidation'] as bool? ?? false,
);

Map<String, dynamic> _$QrScanConfigToJson(QrScanConfig instance) =>
    <String, dynamic>{
      'scanMode': _$QrScanModeEnumMap[instance.scanMode]!,
      'title': instance.title,
      'existingCodesToExclude': instance.existingCodesToExclude,
      'context': instance.context,
      'operation': _$QrScanOperationEnumMap[instance.operation]!,
      'skipValidation': instance.skipValidation,
    };

const _$QrScanModeEnumMap = {
  QrScanMode.single: 'single',
  QrScanMode.batch: 'batch',
};

const _$QrScanOperationEnumMap = {
  QrScanOperation.initial: 'initial',
  QrScanOperation.append: 'append',
  QrScanOperation.remove: 'remove',
};
