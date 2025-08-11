/*
 * @Author: LeeZB
 * @Date: 2025-07-30 10:02:20
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 10:17:38
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';

part 'return_detail_vo.g.dart';

@JsonSerializable()
class ReturnDetailVo extends Equatable {
  @JsonKey(defaultValue: [])
  final List<MaterialVO>? materialList;
  @JsonKey(defaultValue: [])
  final List<AttachmentVO>? imageList;
  @JsonKey(defaultValue: 1)
  /// 0 质量不合格退库  1 多余件退库
  final int returnType;
  @JsonKey(defaultValue: '')
  final String returnRemark;

  const ReturnDetailVo({
    this.materialList,
    this.imageList,
    required this.returnType,
    this.returnRemark = '',
  }) : assert(returnType == 0 || returnType == 1, 'returnType字段只能为0或1');

  factory ReturnDetailVo.fromJson(Map<String, dynamic> json) =>
      _$ReturnDetailVoFromJson(json);

  Map<String, dynamic> toJson() => _$ReturnDetailVoToJson(this);

  ReturnDetailVo copyWith({
    List<MaterialVO>? materialList,
    List<AttachmentVO>? imageList,
    int? returnType,
    String? returnRemark,
  }) {
    return ReturnDetailVo(
      materialList: materialList ?? this.materialList,
      imageList: imageList ?? this.imageList,
      returnType: returnType ?? this.returnType,
      returnRemark: returnRemark ?? this.returnRemark,
    );
  }

  @override
  List<Object?> get props => [
    materialList,
    imageList,
    returnType,
    returnRemark,
  ];
}
