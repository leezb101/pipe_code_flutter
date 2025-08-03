/*
 * @Author: LeeZB
 * @Date: 2025-08-01 16:55:52
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 09:47:35
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/utils/json_converters.dart';

part 'inventory_models.g.dart';

@JsonSerializable()
class InventoryListResponse extends Equatable {
  final List<InventoryListItemVO> records;
  final int total;
  final int size;
  final int current;
  final int? pages;

  const InventoryListResponse({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
    this.pages,
  });

  factory InventoryListResponse.fromJson(Map<String, dynamic> json) =>
      _$InventoryListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryListResponseToJson(this);

  @override
  List<Object?> get props => [records, total, size, current, pages];
}

@JsonSerializable()
class InventoryListItemVO extends Equatable {
  final int id;
  final String? name;
  @NullableTimestampConverter()
  final DateTime? createdTime;
  final int materialNum;
  final String? bindUserName;

  const InventoryListItemVO({
    required this.id,
    this.name,
    this.createdTime,
    required this.materialNum,
    this.bindUserName,
  });

  factory InventoryListItemVO.fromJson(Map<String, dynamic> json) =>
      _$InventoryListItemVOFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryListItemVOToJson(this);

  @override
  List<Object?> get props => [id, name, createdTime, materialNum, bindUserName];
}

@JsonSerializable()
class InventoryDetailInfoVO extends Equatable {
  final int id;
  final String? name;
  @NullableTimestampConverter()
  final DateTime? createdTime;
  @NullableTimestampConverter()
  final DateTime? executeTime;
  final int? materialNum;
  final int? bindUser;
  final String? bindUserName;
  final int? executeUser;
  final String? executeName;
  final int status;
  final int? realMaterialNum;
  final bool? passFlag;
  final int? warehouseId;
  final String? warehouseName;
  final int? virtualType;
  final String? attachmentUrl1;
  final String? attachmentUrl2;
  @JsonKey(defaultValue: [])
  final List<InventoryBindMaterialInfoVO> materials;
  @JsonKey(defaultValue: [])
  final List<InventoryBindMaterialInfoVO> materialExtras;

  InventoryDetailInfoVO({
    required this.id,
    this.name,
    this.createdTime,
    this.executeTime,
    this.materialNum,
    this.bindUser,
    this.bindUserName,
    this.executeUser,
    this.executeName,
    required this.status,
    this.realMaterialNum,
    this.passFlag,
    this.warehouseId,
    this.warehouseName,
    this.virtualType,
    this.attachmentUrl1,
    this.attachmentUrl2,
    List<InventoryBindMaterialInfoVO>? materials,
    List<InventoryBindMaterialInfoVO>? materialExtras,
  }) : materials = materials ?? [],
       materialExtras = materialExtras ?? [];

  factory InventoryDetailInfoVO.fromJson(Map<String, dynamic> json) =>
      _$InventoryDetailInfoVOFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryDetailInfoVOToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    createdTime,
    executeTime,
    materialNum,
    bindUser,
    bindUserName,
    executeUser,
    executeName,
    status,
    realMaterialNum,
    passFlag,
    warehouseId,
    warehouseName,
    virtualType,
    attachmentUrl1,
    attachmentUrl2,
    materials,
    materialExtras,
  ];
}

@JsonSerializable()
class InventoryBindMaterialInfoVO extends Equatable {
  final int materialId;
  final String? materialCode;
  final String? materialName;
  final int materialNum;
  @JsonKey(defaultValue: 0)
  final int? materialRealNum;
  @JsonKey(defaultValue: false)
  final bool? inWarehouse;

  const InventoryBindMaterialInfoVO({
    required this.materialId,
    this.materialCode,
    this.materialName,
    required this.materialNum,
    this.materialRealNum,
    this.inWarehouse,
  });

  factory InventoryBindMaterialInfoVO.fromJson(Map<String, dynamic> json) =>
      _$InventoryBindMaterialInfoVOFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryBindMaterialInfoVOToJson(this);

  @override
  List<Object?> get props => [
    materialId,
    materialCode,
    materialName,
    materialNum,
    materialRealNum,
    inWarehouse,
  ];
}

@JsonSerializable()
class DoInventoryRequestVO extends Equatable {
  final int id;
  @JsonKey(defaultValue: [])
  final List<int> materialIds;
  @JsonKey(defaultValue: [])
  final List<int> materialExtraIds;
  final String? attachmentUrl1;
  final String? attachmentUrl2;

  DoInventoryRequestVO({
    required this.id,
    required this.materialIds,
    required this.materialExtraIds,
    this.attachmentUrl1,
    this.attachmentUrl2,
  }) : assert(
         materialIds.isNotEmpty || materialExtraIds.isNotEmpty,
         'At least one material ID or extra ID must be provided',
       );

  factory DoInventoryRequestVO.fromJson(Map<String, dynamic> json) =>
      _$DoInventoryRequestVOFromJson(json);

  Map<String, dynamic> toJson() => _$DoInventoryRequestVOToJson(this);

  @override
  List<Object?> get props => [
    id,
    materialIds,
    materialExtraIds,
    attachmentUrl1,
    attachmentUrl2,
  ];
}
