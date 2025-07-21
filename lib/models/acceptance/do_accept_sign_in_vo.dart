/*
 * @Author: LeeZB
 * @Date: 2025-07-18 17:37:56
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-21 19:22:34
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'material_vo.dart';
import 'attachment_vo.dart';

part 'do_accept_sign_in_vo.g.dart';

@JsonSerializable()
class DoAcceptSignInVO extends Equatable {
  final int acceptId;
  final List<MaterialVO> materialList;
  final List<AttachmentVO> imageList;

  const DoAcceptSignInVO({
    required this.acceptId,
    required this.materialList,
    required this.imageList,
  });

  factory DoAcceptSignInVO.fromJson(Map<String, dynamic> json) =>
      _$DoAcceptSignInVOFromJson(json);

  Map<String, dynamic> toJson() => _$DoAcceptSignInVOToJson(this);

  @override
  List<Object?> get props => [acceptId, materialList, imageList];

  DoAcceptSignInVO copyWith({
    int? acceptId,
    List<MaterialVO>? materialList,
    List<AttachmentVO>? imageList,
  }) {
    return DoAcceptSignInVO(
      acceptId: acceptId ?? this.acceptId,
      materialList: materialList ?? this.materialList,
      imageList: imageList ?? this.imageList,
    );
  }
}
