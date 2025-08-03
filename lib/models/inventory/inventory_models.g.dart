// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryListResponse _$InventoryListResponseFromJson(
  Map<String, dynamic> json,
) => InventoryListResponse(
  records: (json['records'] as List<dynamic>)
      .map((e) => InventoryListItemVO.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  current: (json['current'] as num).toInt(),
  pages: (json['pages'] as num?)?.toInt(),
);

Map<String, dynamic> _$InventoryListResponseToJson(
  InventoryListResponse instance,
) => <String, dynamic>{
  'records': instance.records,
  'total': instance.total,
  'size': instance.size,
  'current': instance.current,
  'pages': instance.pages,
};

InventoryListItemVO _$InventoryListItemVOFromJson(Map<String, dynamic> json) =>
    InventoryListItemVO(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      createdTime: const NullableTimestampConverter().fromJson(
        (json['createdTime'] as num?)?.toInt(),
      ),
      materialNum: (json['materialNum'] as num).toInt(),
      bindUserName: json['bindUserName'] as String?,
    );

Map<String, dynamic> _$InventoryListItemVOToJson(
  InventoryListItemVO instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdTime': const NullableTimestampConverter().toJson(
    instance.createdTime,
  ),
  'materialNum': instance.materialNum,
  'bindUserName': instance.bindUserName,
};

InventoryDetailInfoVO _$InventoryDetailInfoVOFromJson(
  Map<String, dynamic> json,
) => InventoryDetailInfoVO(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  createdTime: const NullableTimestampConverter().fromJson(
    (json['createdTime'] as num?)?.toInt(),
  ),
  executeTime: const NullableTimestampConverter().fromJson(
    (json['executeTime'] as num?)?.toInt(),
  ),
  materialNum: (json['materialNum'] as num?)?.toInt(),
  bindUser: (json['bindUser'] as num?)?.toInt(),
  bindUserName: json['bindUserName'] as String?,
  executeUser: (json['executeUser'] as num?)?.toInt(),
  executeName: json['executeName'] as String?,
  status: (json['status'] as num).toInt(),
  realMaterialNum: (json['realMaterialNum'] as num?)?.toInt(),
  passFlag: json['passFlag'] as bool?,
  warehouseId: (json['warehouseId'] as num?)?.toInt(),
  warehouseName: json['warehouseName'] as String?,
  virtualType: (json['virtualType'] as num?)?.toInt(),
  attachmentUrl1: json['attachmentUrl1'] as String?,
  attachmentUrl2: json['attachmentUrl2'] as String?,
  materials:
      (json['materials'] as List<dynamic>?)
          ?.map(
            (e) =>
                InventoryBindMaterialInfoVO.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  materialExtras:
      (json['materialExtras'] as List<dynamic>?)
          ?.map(
            (e) =>
                InventoryBindMaterialInfoVO.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
);

Map<String, dynamic> _$InventoryDetailInfoVOToJson(
  InventoryDetailInfoVO instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdTime': const NullableTimestampConverter().toJson(
    instance.createdTime,
  ),
  'executeTime': const NullableTimestampConverter().toJson(
    instance.executeTime,
  ),
  'materialNum': instance.materialNum,
  'bindUser': instance.bindUser,
  'bindUserName': instance.bindUserName,
  'executeUser': instance.executeUser,
  'executeName': instance.executeName,
  'status': instance.status,
  'realMaterialNum': instance.realMaterialNum,
  'passFlag': instance.passFlag,
  'warehouseId': instance.warehouseId,
  'warehouseName': instance.warehouseName,
  'virtualType': instance.virtualType,
  'attachmentUrl1': instance.attachmentUrl1,
  'attachmentUrl2': instance.attachmentUrl2,
  'materials': instance.materials,
  'materialExtras': instance.materialExtras,
};

InventoryBindMaterialInfoVO _$InventoryBindMaterialInfoVOFromJson(
  Map<String, dynamic> json,
) => InventoryBindMaterialInfoVO(
  materialId: (json['materialId'] as num).toInt(),
  materialCode: json['materialCode'] as String?,
  materialName: json['materialName'] as String?,
  materialNum: (json['materialNum'] as num).toInt(),
  materialRealNum: (json['materialRealNum'] as num?)?.toInt() ?? 0,
  inWarehouse: json['inWarehouse'] as bool? ?? false,
);

Map<String, dynamic> _$InventoryBindMaterialInfoVOToJson(
  InventoryBindMaterialInfoVO instance,
) => <String, dynamic>{
  'materialId': instance.materialId,
  'materialCode': instance.materialCode,
  'materialName': instance.materialName,
  'materialNum': instance.materialNum,
  'materialRealNum': instance.materialRealNum,
  'inWarehouse': instance.inWarehouse,
};

DoInventoryRequestVO _$DoInventoryRequestVOFromJson(
  Map<String, dynamic> json,
) => DoInventoryRequestVO(
  id: (json['id'] as num).toInt(),
  materialIds:
      (json['materialIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  materialExtraIds:
      (json['materialExtraIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  attachmentUrl1: json['attachmentUrl1'] as String?,
  attachmentUrl2: json['attachmentUrl2'] as String?,
);

Map<String, dynamic> _$DoInventoryRequestVOToJson(
  DoInventoryRequestVO instance,
) => <String, dynamic>{
  'id': instance.id,
  'materialIds': instance.materialIds,
  'materialExtraIds': instance.materialExtraIds,
  'attachmentUrl1': instance.attachmentUrl1,
  'attachmentUrl2': instance.attachmentUrl2,
};
