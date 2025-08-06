/*
 * @Author: LeeZB
 * @Date: 2025-08-06 16:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 16:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'cutting_history_node.dart';

part 'pipe_cutting_record.g.dart';

@JsonSerializable()
class PipeCuttingRecord extends Equatable {
  const PipeCuttingRecord({
    required this.materialRootId,
    required this.name,
    this.factoryName,
    required this.materialCode,
    this.setProdStdNo,
    this.standard,
    this.spec,
    this.batchCode,
    this.len,
    this.produceDate,
    required this.cutHisTree,
  });

  final int materialRootId;
  final String name;
  final String? factoryName;
  final String materialCode;
  final String? setProdStdNo;
  final String? standard;
  final String? spec;
  final String? batchCode;
  final String? len;
  final String? produceDate;
  final CuttingHistoryNode cutHisTree;

  factory PipeCuttingRecord.fromJson(Map<String, dynamic> json) => _$PipeCuttingRecordFromJson(json);
  Map<String, dynamic> toJson() => _$PipeCuttingRecordToJson(this);

  @override
  List<Object?> get props => [
    materialRootId,
    name,
    factoryName,
    materialCode,
    setProdStdNo,
    standard,
    spec,
    batchCode,
    len,
    produceDate,
    cutHisTree,
  ];
}