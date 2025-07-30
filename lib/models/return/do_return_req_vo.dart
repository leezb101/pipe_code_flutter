/*
 * @Author: LeeZB
 * @Date: 2025-07-30 10:15:39
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 10:18:28
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';

part 'do_return_req_vo.g.dart';

@JsonSerializable()
class DoReturnReqVo extends Equatable {
  @JsonKey(defaultValue: [])
  final List<MaterialVO> materialList;

  @JsonKey(defaultValue: [])
  final List<AttachmentVO> imageList;

  @JsonKey(defaultValue: 0)
  /// 0 不合格退库  1 多余件退库
  final int returnType;

  @JsonKey(defaultValue: '')
  final String returnRemark;

  const DoReturnReqVo({
    required this.materialList,
    required this.imageList,
    required this.returnType,
    this.returnRemark = '',
  }) : assert(returnType == 0 || returnType == 1, 'returnType字段只能为0或1');

  factory DoReturnReqVo.fromJson(Map<String, dynamic> json) =>
      _$DoReturnReqVoFromJson(json);

  Map<String, dynamic> toJson() => _$DoReturnReqVoToJson(this);

  @override
  List<Object?> get props => [
    materialList,
    imageList,
    returnType,
    returnRemark,
  ];
}
