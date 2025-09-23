// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'do_return_req_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoReturnReqVo _$DoReturnReqVoFromJson(Map<String, dynamic> json) =>
    DoReturnReqVo(
      materialList:
          (json['materialList'] as List<dynamic>?)
              ?.map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      imageList:
          (json['imageList'] as List<dynamic>?)
              ?.map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      returnType: (json['returnType'] as num?)?.toInt() ?? 0,
      returnRemark: json['returnRemark'] as String? ?? '',
      returnRemarkVoice: (json['returnRemarkVoice'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DoReturnReqVoToJson(DoReturnReqVo instance) =>
    <String, dynamic>{
      'materialList': instance.materialList,
      'imageList': instance.imageList,
      'returnType': instance.returnType,
      'returnRemark': instance.returnRemark,
      'returnRemarkVoice': instance.returnRemarkVoice,
    };
