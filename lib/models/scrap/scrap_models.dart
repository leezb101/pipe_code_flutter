/*
 * @Author: LeeZB
 * @Date: 2025-08-03 10:37:41
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 10:42:31
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';

part 'scrap_models.g.dart';

@JsonSerializable()
class ScrapDetailVO extends Equatable {
  @JsonKey(defaultValue: [])
  final List<MaterialVO> materialList;
  @JsonKey(defaultValue: [])
  final List<AttachmentVO> imageList;

  const ScrapDetailVO({required this.materialList, required this.imageList});

  factory ScrapDetailVO.fromJson(Map<String, dynamic> json) =>
      _$ScrapDetailVOFromJson(json);

  Map<String, dynamic> toJson() => _$ScrapDetailVOToJson(this);

  @override
  List<Object?> get props => [materialList, imageList];
}
