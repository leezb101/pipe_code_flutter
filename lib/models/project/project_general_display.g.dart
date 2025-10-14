// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_general_display.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectGeneralDisplay _$ProjectGeneralDisplayFromJson(
  Map<String, dynamic> json,
) => ProjectGeneralDisplay(
  totalCount: (json['totalCount'] as num?)?.toInt(),
  acceptedCount: (json['acceptedCount'] as num?)?.toInt(),
  signInCount: (json['signInCount'] as num?)?.toInt(),
  installedCount: (json['installedCount'] as num?)?.toInt(),
  cutPipeCount: (json['cutPipeCount'] as num?)?.toInt(),
  rejectedCount: (json['rejectedCount'] as num?)?.toInt(),
  surplusReturnedCount: (json['surplusReturnedCount'] as num?)?.toInt(),
  qrCodeLostCount: (json['qrCodeLostCount'] as num?)?.toInt(),
  damageCount: (json['damageCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProjectGeneralDisplayToJson(
  ProjectGeneralDisplay instance,
) => <String, dynamic>{
  'totalCount': instance.totalCount,
  'acceptedCount': instance.acceptedCount,
  'signInCount': instance.signInCount,
  'installedCount': instance.installedCount,
  'cutPipeCount': instance.cutPipeCount,
  'rejectedCount': instance.rejectedCount,
  'surplusReturnedCount': instance.surplusReturnedCount,
  'qrCodeLostCount': instance.qrCodeLostCount,
  'damageCount': instance.damageCount,
};
