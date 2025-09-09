import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'map_project_statistic.g.dart';

@JsonSerializable(explicitToJson: true)
class MapProjectStatistic extends Equatable {
  final int projectId; // 必填
  final int? num;
  final int? num2;
  final int? acceptTimes;
  final int? acceptNum;
  final int? installNum;
  final int? backNum;
  final int? cutNum;
  final int? destroyNum;

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
