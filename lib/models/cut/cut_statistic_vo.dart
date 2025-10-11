import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cut_statistic_vo.g.dart';

@JsonSerializable()
class CutStatisticVo extends Equatable {
  final int projectId;

  @JsonKey(defaultValue: 0)
  final int cutSourceNum;

  @JsonKey(defaultValue: 0)
  final int cutTimes;

  @JsonKey(defaultValue: 0)
  final int newActivePipeNum;

  const CutStatisticVo({
    required this.projectId,
    this.cutSourceNum = 0,
    this.cutTimes = 0,
    this.newActivePipeNum = 0,
  });

  @override
  List<Object?> get props => [
    projectId,
    cutSourceNum,
    cutTimes,
    newActivePipeNum,
  ];

  factory CutStatisticVo.fromJson(Map<String, dynamic> json) =>
      _$CutStatisticVoFromJson(json);

  Map<String, dynamic> toJson() => _$CutStatisticVoToJson(this);
}
