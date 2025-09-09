import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/models/common/warehouse_vo.dart'; // 你的仓库模型
import 'package:pipe_code_flutter/models/common/org_models.dart'; // 你的公司模型

part 'map_project_base.g.dart';

@JsonSerializable(explicitToJson: true)
class MapProjectBase extends Equatable {
  final int projectId; // 必填
  final String projectName; // 必填
  final String? projectCode;
  final String? startTime;
  final String? auditTime;
  final String? address;
  final List<SimpleOrg>? construct;
  final List<SimpleOrg>? builder;
  final List<SimpleOrg>? supervisor;
  final List<SimpleOrg>? suppliers;
  final List<WarehouseVO>? warehouseVOS;

  const MapProjectBase({
    required this.projectId,
    required this.projectName,
    this.projectCode,
    this.startTime,
    this.auditTime,
    this.address,
    this.construct,
    this.builder,
    this.supervisor,
    this.suppliers,
    this.warehouseVOS,
  });

  /// JSON -> Model
  factory MapProjectBase.fromJson(Map<String, dynamic> json) =>
      _$MapProjectBaseFromJson(json);

  /// Model -> JSON
  Map<String, dynamic> toJson() => _$MapProjectBaseToJson(this);

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    projectCode,
    startTime,
    auditTime,
    address,
    construct,
    builder,
    supervisor,
    suppliers,
    warehouseVOS,
  ];
}
