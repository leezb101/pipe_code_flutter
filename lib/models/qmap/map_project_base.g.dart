// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_project_base.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapProjectBase _$MapProjectBaseFromJson(Map<String, dynamic> json) =>
    MapProjectBase(
      projectId: (json['projectId'] as num).toInt(),
      projectName: json['projectName'] as String,
      projectCode: json['projectCode'] as String?,
      startTime: json['startTime'] as String?,
      auditTime: json['auditTime'] as String?,
      address: json['address'] as String?,
      construct: (json['construct'] as List<dynamic>?)
          ?.map((e) => SimpleOrg.fromJson(e as Map<String, dynamic>))
          .toList(),
      builder: (json['builder'] as List<dynamic>?)
          ?.map((e) => SimpleOrg.fromJson(e as Map<String, dynamic>))
          .toList(),
      supervisor: (json['supervisor'] as List<dynamic>?)
          ?.map((e) => SimpleOrg.fromJson(e as Map<String, dynamic>))
          .toList(),
      suppliers: (json['suppliers'] as List<dynamic>?)
          ?.map((e) => SimpleOrg.fromJson(e as Map<String, dynamic>))
          .toList(),
      warehouseVOS: (json['warehouseVOS'] as List<dynamic>?)
          ?.map((e) => WarehouseVO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MapProjectBaseToJson(MapProjectBase instance) =>
    <String, dynamic>{
      'projectId': instance.projectId,
      'projectName': instance.projectName,
      'projectCode': instance.projectCode,
      'startTime': instance.startTime,
      'auditTime': instance.auditTime,
      'address': instance.address,
      'construct': instance.construct?.map((e) => e.toJson()).toList(),
      'builder': instance.builder?.map((e) => e.toJson()).toList(),
      'supervisor': instance.supervisor?.map((e) => e.toJson()).toList(),
      'suppliers': instance.suppliers?.map((e) => e.toJson()).toList(),
      'warehouseVOS': instance.warehouseVOS?.map((e) => e.toJson()).toList(),
    };
