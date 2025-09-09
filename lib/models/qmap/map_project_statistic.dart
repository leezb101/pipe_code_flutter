import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'map_project_statistic.g.dart';

@JsonSerializable(explicitToJson: true)
class MapProjectStatistic extends Equatable {
  final int projectId; // 必填
  final int? num; //项目内材料数量(截管的按照截后数量计算,实际值)
  final int? num2; //项目内材料数量(截管的按照截前数量计算,原始值)
  final int? acceptTimes; //验收次数
  final int? acceptNum; //验收材料数量
  final int? installNum; //安装数量
  final int? backNum; //退回数量
  final int? cutNum; //截管数量
  final int? destroyNum; //报废数量

  const MapProjectStatistic({
    required this.projectId,
    this.num,
    this.num2,
    this.acceptTimes,
    this.acceptNum,
    this.installNum,
    this.backNum,
    this.cutNum,
    this.destroyNum,
  });

  /// JSON -> Model
  factory MapProjectStatistic.fromJson(Map<String, dynamic> json) =>
      _$MapProjectStatisticFromJson(json);

  /// Model -> JSON
  Map<String, dynamic> toJson() => _$MapProjectStatisticToJson(this);

  @override
  List<Object?> get props => [
    projectId,
    num,
    num2,
    acceptTimes,
    acceptNum,
    installNum,
    backNum,
    cutNum,
    destroyNum,
  ];
}
