/*
 * @Author: LeeZB
 * @Date: 2025-08-06 16:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 16:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'cutting_history_node.g.dart';

@JsonSerializable()
class CuttingHistoryNode extends Equatable {
  const CuttingHistoryNode({
    required this.materialId,
    this.parentId,
    required this.rootId,
    this.len,
    this.cutTime,
    this.img,
    this.cutUserName,
    required this.cutUserId,
    this.cutUserPhone,
    this.children,
    this.currentId,
  });

  final int materialId;
  final String? parentId;
  final int rootId;
  final String? len;
  final String? cutTime;
  final String? img;
  final String? cutUserName;
  final int cutUserId;
  final String? cutUserPhone;
  final List<CuttingHistoryNode>? children;
  final String? currentId;

  factory CuttingHistoryNode.fromJson(Map<String, dynamic> json) => _$CuttingHistoryNodeFromJson(json);
  Map<String, dynamic> toJson() => _$CuttingHistoryNodeToJson(this);

  @override
  List<Object?> get props => [
    materialId,
    parentId,
    rootId,
    len,
    cutTime,
    img,
    cutUserName,
    cutUserId,
    cutUserPhone,
    children,
    currentId,
  ];
}