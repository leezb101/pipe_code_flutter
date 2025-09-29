/*
 * @Author: LeeZB
 * @Date: 2025-09-29 
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-29
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'jsf_material_vo.dart';
import 'attachment_vo.dart';

part 'jsf_return_data_vo.g.dart';

@JsonSerializable()
class JsfReturnDataVO extends Equatable {
  final String? lng;
  final String? lat;
  final List<JsfMaterialVO> materialList;
  final List<AttachmentVO> imageList;
  final int returnType;
  final String? returnRemark;
  final List<String> returnRemarkVoice;

  const JsfReturnDataVO({
    this.lng,
    this.lat,
    required this.materialList,
    required this.imageList,
    required this.returnType,
    this.returnRemark,
    this.returnRemarkVoice = const [],
  });

  factory JsfReturnDataVO.fromJson(Map<String, dynamic> json) =>
      _$JsfReturnDataVOFromJson(json);

  Map<String, dynamic> toJson() => _$JsfReturnDataVOToJson(this);

  @override
  List<Object?> get props => [
    lng,
    lat,
    materialList,
    imageList,
    returnType,
    returnRemark,
    returnRemarkVoice,
  ];

  JsfReturnDataVO copyWith({
    String? lng,
    String? lat,
    List<JsfMaterialVO>? materialList,
    List<AttachmentVO>? imageList,
    int? returnType,
    String? returnRemark,
    List<String>? returnRemarkVoice,
  }) {
    return JsfReturnDataVO(
      lng: lng ?? this.lng,
      lat: lat ?? this.lat,
      materialList: materialList ?? this.materialList,
      imageList: imageList ?? this.imageList,
      returnType: returnType ?? this.returnType,
      returnRemark: returnRemark ?? this.returnRemark,
      returnRemarkVoice: returnRemarkVoice ?? this.returnRemarkVoice,
    );
  }
}
