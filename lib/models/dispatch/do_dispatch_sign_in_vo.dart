/*
 * @Author: LeeZB
 * @Date: 2025-07-27 10:58:19
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-27 11:00:46
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';

part 'do_dispatch_sign_in_vo.g.dart';

@JsonSerializable()
class DoDispatchSignInVo extends Equatable {
  final int dispatchId;
  final List<MaterialVO> materialList;
  final List<AttachmentVO> imageList;

  const DoDispatchSignInVo({
    required this.dispatchId,
    required this.materialList,
    required this.imageList,
  });

  factory DoDispatchSignInVo.fromJson(Map<String, dynamic> json) =>
      _$DoDispatchSignInVoFromJson(json);

  Map<String, dynamic> toJson() => _$DoDispatchSignInVoToJson(this);

  @override
  List<Object?> get props => [dispatchId, materialList, imageList];

  DoDispatchSignInVo copyWith({
    int? dispatchId,
    List<MaterialVO>? materialList,
    List<AttachmentVO>? imageList,
  }) {
    return DoDispatchSignInVo(
      dispatchId: dispatchId ?? this.dispatchId,
      materialList: materialList ?? this.materialList,
      imageList: imageList ?? this.imageList,
    );
  }
}
