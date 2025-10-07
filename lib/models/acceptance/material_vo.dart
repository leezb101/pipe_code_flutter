import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'material_vo.g.dart';

@JsonSerializable()
class MaterialVO extends Equatable {
  final int materialId;
  @JsonKey(defaultValue: '')
  final String materialName;
  final int num;
  final String? installPileNo;
  final String? installImageUrl1;
  final String? installImageUrl2;
  final String? materialCode;
  final String? batchCode;
  final int? status;
  final String? statusName;

  const MaterialVO({
    required this.materialId,
    required this.materialName,
    this.num = 1,
    this.installPileNo,
    this.installImageUrl1,
    this.installImageUrl2,
    this.materialCode,
    this.batchCode,
    this.status,
    this.statusName,
  });

  factory MaterialVO.fromJson(Map<String, dynamic> json) =>
      _$MaterialVOFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialVOToJson(this);

  @override
  List<Object?> get props => [
    materialId,
    materialName,
    num,
    installPileNo,
    installImageUrl1,
    installImageUrl2,
    materialCode,
    batchCode,
    status,
    statusName,
  ];

  MaterialVO copyWith({
    int? materialId,
    String? materialName,
    int? num,
    String? installPileNo,
    String? installImageUrl1,
    String? installImageUrl2,
    String? materialCode,
    String? batchCode,
    int? status,
    String? statusName,
  }) {
    return MaterialVO(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      num: num ?? this.num,
      installPileNo: installPileNo ?? this.installPileNo,
      installImageUrl1: installImageUrl1 ?? this.installImageUrl1,
      installImageUrl2: installImageUrl2 ?? this.installImageUrl2,
      materialCode: materialCode ?? this.materialCode,
      batchCode: batchCode ?? this.batchCode,
      status: status ?? this.status,
      statusName: statusName ?? this.statusName,
    );
  }
}
