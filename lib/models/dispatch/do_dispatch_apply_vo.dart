/*
 * @Author: LeeZB
 * @Date: 2025-07-27 10:47:39
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-27 11:05:20
 * @copyright: Copyright © 2025 高新供水.
 */
/*
 * @Author: LeeZB
 * @Date: 2025-07-27 10:47:39
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-27 11:01:41
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';

part 'do_dispatch_apply_vo.g.dart';

/// 调拨申请VO
@JsonSerializable()
class DoDispatchApplyVo extends Equatable {
  final List<MaterialVO> materialList;
  final List<AttachmentVO> imageList;
  final int fromProjectId;
  final int toProjectId;
  final int toWarehouseId;
  final List<int> messageTo;

  const DoDispatchApplyVo({
    required this.materialList,
    required this.imageList,
    required this.fromProjectId,
    required this.toProjectId,
    required this.toWarehouseId,
    required this.messageTo,
  });

  factory DoDispatchApplyVo.fromJson(Map<String, dynamic> json) =>
      _$DoDispatchApplyVoFromJson(json);

  Map<String, dynamic> toJson() => _$DoDispatchApplyVoToJson(this);

  @override
  List<Object?> get props => [
    materialList,
    imageList,
    fromProjectId,
    toProjectId,
    toWarehouseId,
    messageTo,
  ];

  DoDispatchApplyVo copyWith({
    List<MaterialVO>? materialList,
    List<AttachmentVO>? imageList,
    int? fromProjectId,
    int? toProjectId,
    int? toWarehouseId,
    List<int>? messageTo,
  }) {
    return DoDispatchApplyVo(
      materialList: materialList ?? this.materialList,
      imageList: imageList ?? this.imageList,
      fromProjectId: fromProjectId ?? this.fromProjectId,
      toProjectId: toProjectId ?? this.toProjectId,
      toWarehouseId: toWarehouseId ?? this.toWarehouseId,
      messageTo: messageTo ?? this.messageTo,
    );
  }
}
