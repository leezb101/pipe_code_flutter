// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_scan_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrScanConfig _$QrScanConfigFromJson(Map<String, dynamic> json) => QrScanConfig(
  scanType: $enumDecode(_$QrScanTypeEnumMap, json['scanType']),
  scanMode:
      $enumDecodeNullable(_$QrScanModeEnumMap, json['scanMode']) ??
      QrScanMode.single,
  title: json['title'] as String?,
  existingCodesToExclude: (json['existingCodesToExclude'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  context: json['context'] as Map<String, dynamic>?,
  isRemoveOperation: json['isRemoveOperation'] as bool? ?? false,
);

Map<String, dynamic> _$QrScanConfigToJson(QrScanConfig instance) =>
    <String, dynamic>{
      'scanType': _$QrScanTypeEnumMap[instance.scanType]!,
      'scanMode': _$QrScanModeEnumMap[instance.scanMode]!,
      'title': instance.title,
      'existingCodesToExclude': instance.existingCodesToExclude,
      'context': instance.context,
      'isRemoveOperation': instance.isRemoveOperation,
    };

const _$QrScanTypeEnumMap = {
  QrScanType.signout: 'signout',
  QrScanType.transfer: 'transfer',
  QrScanType.inventory: 'inventory',
  QrScanType.pipeCopy: 'pipeCopy',
  QrScanType.identification: 'identification',
  QrScanType.returnMaterial: 'returnMaterial',
  QrScanType.acceptance: 'acceptance',
  QrScanType.materialInbound: 'materialInbound',
  QrScanType.install: 'install',
  QrScanType.scrap: 'scrap',
  QrScanType.raw: 'raw',
};

const _$QrScanModeEnumMap = {
  QrScanMode.single: 'single',
  QrScanMode.batch: 'batch',
};
