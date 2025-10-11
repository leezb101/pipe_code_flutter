import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cut_records_item_vo.g.dart';

@JsonSerializable()
class CutRecordsItemVO extends Equatable {
  final int projectId;

  final int? type;

  final String? typeName;

  final String? spec;

  final String? name;

  final String? len;

  final String? materialCode;

  final int? cutTime;

  const CutRecordsItemVO({
    required this.projectId,
    this.type,
    this.typeName,
    this.spec,
    this.name,
    this.len,
    this.materialCode,
    this.cutTime,
  });

  factory CutRecordsItemVO.fromJson(Map<String, dynamic> json) =>
      _$CutRecordsItemVOFromJson(json);

  Map<String, dynamic> toJson() => _$CutRecordsItemVOToJson(this);

  @override
  List<Object?> get props => [
    projectId,
    type,
    typeName,
    spec,
    name,
    len,
    materialCode,
    cutTime,
  ];
}
