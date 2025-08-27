/*
 * @Author: LeeZB
 * @Date: 2025-07-25 18:55:34
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 19:04:12
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:json_annotation/json_annotation.dart';

part 'install_detail_vo.g.dart';

@JsonSerializable()
class InstallDetailVo extends Equatable {
  final List<MaterialVO> materialList;
  final List<AttachmentVO> imageList;
  final String? installQualityUrl;
  final bool? onlyInstall;
  final int signOutId;

  const InstallDetailVo({
    required this.materialList,
    required this.imageList,
    this.installQualityUrl,
    this.onlyInstall,
    required this.signOutId,
  });

  @override
  List<Object?> get props => [
    materialList,
    imageList,
    installQualityUrl,
    onlyInstall,
    signOutId,
  ];

  factory InstallDetailVo.fromJson(Map<String, dynamic> json) =>
      _$InstallDetailVoFromJson(json);

  Map<String, dynamic> toJson() => _$InstallDetailVoToJson(this);
}
