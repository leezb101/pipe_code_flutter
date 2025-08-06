// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipe_cutting_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PipeCuttingRecord _$PipeCuttingRecordFromJson(Map<String, dynamic> json) =>
    PipeCuttingRecord(
      materialRootId: (json['materialRootId'] as num).toInt(),
      name: json['name'] as String,
      factoryName: json['factoryName'] as String?,
      materialCode: json['materialCode'] as String,
      setProdStdNo: json['setProdStdNo'] as String?,
      standard: json['standard'] as String?,
      spec: json['spec'] as String?,
      batchCode: json['batchCode'] as String?,
      len: json['len'] as String?,
      produceDate: json['produceDate'] as String?,
      cutHisTree: CuttingHistoryNode.fromJson(
        json['cutHisTree'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PipeCuttingRecordToJson(PipeCuttingRecord instance) =>
    <String, dynamic>{
      'materialRootId': instance.materialRootId,
      'name': instance.name,
      'factoryName': instance.factoryName,
      'materialCode': instance.materialCode,
      'setProdStdNo': instance.setProdStdNo,
      'standard': instance.standard,
      'spec': instance.spec,
      'batchCode': instance.batchCode,
      'len': instance.len,
      'produceDate': instance.produceDate,
      'cutHisTree': instance.cutHisTree,
    };
