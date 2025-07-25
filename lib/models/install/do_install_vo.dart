/*
 * @Author: LeeZB
 * @Date: 2025-07-25 18:50:15
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 20:28:19
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';

part 'do_install_vo.g.dart';

@JsonSerializable()
class DoInstallVo extends Equatable {
  final List<MaterialVO> materialList;
  final List<AttachmentVO> imageList;
  final String? installQualityUrl;
  final bool onlyInstall;
  final int? signOutId;

  const DoInstallVo({
    required this.materialList,
    required this.imageList,
    this.installQualityUrl,
    this.onlyInstall = false,
    this.signOutId,
  });

  factory DoInstallVo.fromJson(Map<String, dynamic> json) =>
      _$DoInstallVoFromJson(json);

  Map<String, dynamic> toJson() => _$DoInstallVoToJson(this);

  @override
  List<Object?> get props => [
    materialList,
    imageList,
    installQualityUrl,
    onlyInstall,
    signOutId,
  ];

  DoInstallVo copyWith({
    List<MaterialVO>? materialList,
    List<AttachmentVO>? imageList,
    String? installQualityUrl,
    bool? onlyInstall,
    int? signOutId,
  }) {
    return DoInstallVo(
      materialList: materialList ?? this.materialList,
      imageList: imageList ?? this.imageList,
      installQualityUrl: installQualityUrl ?? this.installQualityUrl,
      onlyInstall: onlyInstall ?? this.onlyInstall,
      signOutId: signOutId ?? this.signOutId,
    );
  }
}
