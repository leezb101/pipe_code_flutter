import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';

part 'dispatch_detail_vo.g.dart';

@JsonSerializable()
class DispatchDetailVo extends Equatable {
  final List<MaterialVO> materialList;
  final List<AttachmentVO> imageList;
  final int? fromProjectId;
  final String? fromProjectName;
  final int? toProjectId;
  final String? toProjectName;
  final int toWarehouseId;
  final String? toWarehouseName;
  final int fromWarehouseId;
  final String? fromWarehouseName;
  final int toUserId;
  final String? toUserName;
  final List<CommonUserVO> fromWarehouseUsers;
  final List<CommonUserVO> toWarehouseUsers;

  const DispatchDetailVo({
    required this.materialList,
    required this.imageList,
    required this.fromProjectId,
    this.fromProjectName,
    required this.toProjectId,
    this.toProjectName,
    required this.toWarehouseId,
    this.toWarehouseName,
    required this.fromWarehouseId,
    this.fromWarehouseName,
    required this.toUserId,
    this.toUserName,
    required this.fromWarehouseUsers,
    required this.toWarehouseUsers,
  });

  factory DispatchDetailVo.fromJson(Map<String, dynamic> json) =>
      _$DispatchDetailVoFromJson(json);

  Map<String, dynamic> toJson() => _$DispatchDetailVoToJson(this);

  @override
  List<Object?> get props => [
    materialList,
    imageList,
    fromProjectId,
    fromProjectName,
    toProjectId,
    toProjectName,
    toWarehouseId,
    toWarehouseName,
    fromWarehouseId,
    fromWarehouseName,
    toUserId,
    toUserName,
    fromWarehouseUsers,
    toWarehouseUsers,
  ];

  DispatchDetailVo copyWith({
    List<MaterialVO>? materialList,
    List<AttachmentVO>? imageList,
    int? fromProjectId,
    String? fromProjectName,
    int? toProjectId,
    String? toProjectName,
    int? toWarehouseId,
    String? toWarehouseName,
    int? fromWarehouseId,
    String? fromWarehouseName,
    int? toUserId,
    String? toUserName,
    List<CommonUserVO>? fromWarehouseUsers,
    List<CommonUserVO>? toWarehouseUsers,
  }) {
    return DispatchDetailVo(
      materialList: materialList ?? this.materialList,
      imageList: imageList ?? this.imageList,
      fromProjectId: fromProjectId ?? this.fromProjectId,
      fromProjectName: fromProjectName ?? this.fromProjectName,
      toProjectId: toProjectId ?? this.toProjectId,
      toProjectName: toProjectName ?? this.toProjectName,
      toWarehouseId: toWarehouseId ?? this.toWarehouseId,
      toWarehouseName: toWarehouseName ?? this.toWarehouseName,
      fromWarehouseId: fromWarehouseId ?? this.fromWarehouseId,
      fromWarehouseName: fromWarehouseName ?? this.fromWarehouseName,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      fromWarehouseUsers: fromWarehouseUsers ?? this.fromWarehouseUsers,
      toWarehouseUsers: toWarehouseUsers ?? this.toWarehouseUsers,
    );
  }
}
