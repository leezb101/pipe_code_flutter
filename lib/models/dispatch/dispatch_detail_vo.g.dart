// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatch_detail_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatchDetailVo _$DispatchDetailVoFromJson(Map<String, dynamic> json) =>
    DispatchDetailVo(
      materialList: (json['materialList'] as List<dynamic>)
          .map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageList: (json['imageList'] as List<dynamic>)
          .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      fromProjectId: (json['fromProjectId'] as num?)?.toInt(),
      fromProjectName: json['fromProjectName'] as String?,
      toProjectId: (json['toProjectId'] as num?)?.toInt(),
      toProjectName: json['toProjectName'] as String?,
      toWarehouseId: (json['toWarehouseId'] as num).toInt(),
      toWarehouseName: json['toWarehouseName'] as String?,
      fromWarehouseId: (json['fromWarehouseId'] as num).toInt(),
      fromWarehouseName: json['fromWarehouseName'] as String?,
      toUserId: (json['toUserId'] as num).toInt(),
      toUserName: json['toUserName'] as String?,
      fromWarehouseUsers: (json['fromWarehouseUsers'] as List<dynamic>)
          .map((e) => CommonUserVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      toWarehouseUsers: (json['toWarehouseUsers'] as List<dynamic>)
          .map((e) => CommonUserVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      dispatchStatus: (json['dispatchStatus'] as num?)?.toInt(),
      dispatchStatusName: json['dispatchStatusName'] as String?,
    );

Map<String, dynamic> _$DispatchDetailVoToJson(DispatchDetailVo instance) =>
    <String, dynamic>{
      'materialList': instance.materialList,
      'imageList': instance.imageList,
      'fromProjectId': instance.fromProjectId,
      'fromProjectName': instance.fromProjectName,
      'toProjectId': instance.toProjectId,
      'toProjectName': instance.toProjectName,
      'toWarehouseId': instance.toWarehouseId,
      'toWarehouseName': instance.toWarehouseName,
      'fromWarehouseId': instance.fromWarehouseId,
      'fromWarehouseName': instance.fromWarehouseName,
      'toUserId': instance.toUserId,
      'toUserName': instance.toUserName,
      'fromWarehouseUsers': instance.fromWarehouseUsers,
      'toWarehouseUsers': instance.toWarehouseUsers,
      'dispatchStatus': instance.dispatchStatus,
      'dispatchStatusName': instance.dispatchStatusName,
    };
