/*
 * @Author: LeeZB
 * @Date: 2025-09-29 
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-29
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'jsf_material_vo.g.dart';

@JsonSerializable()
class JsfMaterialVO extends Equatable {
  final int materialId;
  final String materialName;
  final int num;
  final String? installPileNo;
  final String? installImageUrl1;
  final String? installImageUrl2;
  final String? remark;
  final int projectId;

  const JsfMaterialVO({
    required this.materialId,
    required this.materialName,
    this.num = 1,
    this.installPileNo,
    this.installImageUrl1,
    this.installImageUrl2,
    this.remark,
    required this.projectId,
  });

  factory JsfMaterialVO.fromJson(Map<String, dynamic> json) =>
      _$JsfMaterialVOFromJson(json);

  Map<String, dynamic> toJson() => _$JsfMaterialVOToJson(this);

  @override
  List<Object?> get props => [
    materialId,
    materialName,
    num,
    installPileNo,
    installImageUrl1,
    installImageUrl2,
    remark,
    projectId,
  ];

  JsfMaterialVO copyWith({
    int? materialId,
    String? materialName,
    int? num,
    String? installPileNo,
    String? installImageUrl1,
    String? installImageUrl2,
    String? remark,
    int? projectId,
  }) {
    return JsfMaterialVO(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      num: num ?? this.num,
      installPileNo: installPileNo ?? this.installPileNo,
      installImageUrl1: installImageUrl1 ?? this.installImageUrl1,
      installImageUrl2: installImageUrl2 ?? this.installImageUrl2,
      remark: remark ?? this.remark,
      projectId: projectId ?? this.projectId,
    );
  }
}
