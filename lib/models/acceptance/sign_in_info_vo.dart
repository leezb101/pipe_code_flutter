/*
 * @Author: LeeZB
 * @Date: 2025-07-18 17:37:12
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-21 19:24:14
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'material_vo.dart';
import 'attachment_vo.dart';

part 'sign_in_info_vo.g.dart';

@JsonSerializable()
class SignInInfoVO extends Equatable {
  final List<MaterialVO> materialList;
  final List<AttachmentVO> imageList;
  final int warehouseId;
  final String? warehouseName;
  final String? signInUserName;
  final int? projectId;
  final String? projectName;

  const SignInInfoVO({
    required this.materialList,
    required this.imageList,
    required this.warehouseId,
    this.warehouseName,
    this.signInUserName,
    this.projectId,
    this.projectName,
  });

  factory SignInInfoVO.fromJson(Map<String, dynamic> json) =>
      _$SignInInfoVOFromJson(json);

  Map<String, dynamic> toJson() => _$SignInInfoVOToJson(this);

  @override
  List<Object?> get props => [
    materialList,
    imageList,
    warehouseId,
    warehouseName,
    signInUserName,
    projectId,
    projectName,
  ];

  SignInInfoVO copyWith({
    List<MaterialVO>? materialList,
    List<AttachmentVO>? imageList,
    int? warehouseId,
    String? warehouseName,
    String? signInUserName,
    int? projectId,
    String? projectName,
  }) {
    return SignInInfoVO(
      materialList: materialList ?? this.materialList,
      imageList: imageList ?? this.imageList,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      signInUserName: signInUserName ?? this.signInUserName,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
    );
  }
}
