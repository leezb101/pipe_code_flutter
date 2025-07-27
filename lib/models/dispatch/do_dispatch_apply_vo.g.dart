// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'do_dispatch_apply_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoDispatchApplyVo _$DoDispatchApplyVoFromJson(Map<String, dynamic> json) =>
    DoDispatchApplyVo(
      materialList: (json['materialList'] as List<dynamic>)
          .map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageList: (json['imageList'] as List<dynamic>)
          .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      fromProjectId: (json['fromProjectId'] as num).toInt(),
      toProjectId: (json['toProjectId'] as num).toInt(),
      toWarehouseId: (json['toWarehouseId'] as num).toInt(),
      messageTo: (json['messageTo'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$DoDispatchApplyVoToJson(DoDispatchApplyVo instance) =>
    <String, dynamic>{
      'materialList': instance.materialList,
      'imageList': instance.imageList,
      'fromProjectId': instance.fromProjectId,
      'toProjectId': instance.toProjectId,
      'toWarehouseId': instance.toWarehouseId,
      'messageTo': instance.messageTo,
    };
