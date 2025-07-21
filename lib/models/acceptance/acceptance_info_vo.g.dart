// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acceptance_info_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptanceInfoVO _$AcceptanceInfoVOFromJson(Map<String, dynamic> json) =>
    AcceptanceInfoVO(
      materialList: (json['materialList'] as List<dynamic>)
          .map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageList: (json['imageList'] as List<dynamic>)
          .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      sendAcceptUrl: json['sendAcceptUrl'] as String?,
      acceptReportUrl: json['acceptReportUrl'] as String?,
      realWarehouse: json['realWarehouse'] as bool,
      warehouseId: (json['warehouseId'] as num).toInt(),
      warehouseUsers: (json['warehouseUsers'] as List<dynamic>)
          .map((e) => CommonUserVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      supervisorUsers: (json['supervisorUsers'] as List<dynamic>)
          .map((e) => CommonUserVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      constructionUsers: (json['constructionUsers'] as List<dynamic>)
          .map((e) => CommonUserVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      signInInfo: json['signInInfo'] == null
          ? null
          : SignInInfoVO.fromJson(json['signInInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AcceptanceInfoVOToJson(AcceptanceInfoVO instance) =>
    <String, dynamic>{
      'materialList': instance.materialList,
      'imageList': instance.imageList,
      'sendAcceptUrl': instance.sendAcceptUrl,
      'acceptReportUrl': instance.acceptReportUrl,
      'realWarehouse': instance.realWarehouse,
      'warehouseId': instance.warehouseId,
      'warehouseUsers': instance.warehouseUsers,
      'supervisorUsers': instance.supervisorUsers,
      'constructionUsers': instance.constructionUsers,
      'signInInfo': instance.signInInfo,
    };
