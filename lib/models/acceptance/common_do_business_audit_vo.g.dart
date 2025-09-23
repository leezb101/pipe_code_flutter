// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_do_business_audit_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommonDoBusinessAuditVO _$CommonDoBusinessAuditVOFromJson(
  Map<String, dynamic> json,
) => CommonDoBusinessAuditVO(
  id: (json['id'] as num).toInt(),
  pass: json['pass'] as bool,
  reason: json['reason'] as String?,
  reasonVoice: (json['reasonVoice'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CommonDoBusinessAuditVOToJson(
  CommonDoBusinessAuditVO instance,
) => <String, dynamic>{
  'id': instance.id,
  'pass': instance.pass,
  'reason': instance.reason,
  'reasonVoice': instance.reasonVoice,
};
