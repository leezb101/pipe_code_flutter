/*
 * @Author: LeeZB
 * @Date: 2025-07-24 18:55:39
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-24 19:04:46
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/models/signout/do_install_vo.dart';

import '../acceptance/material_vo.dart';

part 'signout_info_vo.g.dart';

@JsonSerializable()
class SignoutInfoVo extends Equatable {
  final List<MaterialVO> materialList;
  final List<AttachmentVO> imageList;
  final List<int> messageTo;
  final int? warehouseId;
  final String? warehouseName;
  final List<CommonUserVO> warehouseUsers;
  final int? installUserId;
  final String? installUserName;
  final DoInstallVo? installInfo;

  const SignoutInfoVo({
    required this.materialList,
    required this.imageList,
    required this.messageTo,
    this.warehouseId,
    this.warehouseName,
    required this.warehouseUsers,
    this.installUserId,
    this.installUserName,
    this.installInfo,
  });

  factory SignoutInfoVo.fromJson(Map<String, dynamic> json) =>
      _$SignoutInfoVoFromJson(json);

  Map<String, dynamic> toJson() => _$SignoutInfoVoToJson(this);

  @override
  List<Object?> get props => [
    materialList,
    imageList,
    messageTo,
    warehouseId,
    warehouseName,
    warehouseUsers,
    installUserId,
    installUserName,
    installInfo,
  ];

  SignoutInfoVo copyWith({
    List<MaterialVO>? materialList,
    List<AttachmentVO>? imageList,
    List<int>? messageTo,
    int? warehouseId,
    String? warehouseName,
    List<CommonUserVO>? warehouseUsers,
    int? installUserId,
    String? installUserName,
    DoInstallVo? installInfo,
  }) {
    return SignoutInfoVo(
      materialList: materialList ?? this.materialList,
      imageList: imageList ?? this.imageList,
      messageTo: messageTo ?? this.messageTo,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      warehouseUsers: warehouseUsers ?? this.warehouseUsers,
      installUserId: installUserId ?? this.installUserId,
      installUserName: installUserName ?? this.installUserName,
      installInfo: installInfo ?? this.installInfo,
    );
  }
}
