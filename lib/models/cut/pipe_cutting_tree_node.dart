/*
 * @Author: LeeZB
 * @Date: 2025-08-06 20:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 20:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import 'cutting_history_node.dart';

/// 树状截管记录节点模型
class PipeCuttingTreeNode extends Equatable {
  const PipeCuttingTreeNode({
    required this.materialId,
    required this.rootId,
    this.parentId,
    this.len,
    this.cutTime,
    this.img,
    this.cutUserName,
    required this.cutUserId,
    this.cutUserPhone,
    this.currentId,
    this.children = const [],
    this.level = 0,
    this.isRoot = false,
    this.isCurrent = false,
  });

  final int materialId;
  final int rootId;
  final String? parentId;
  final String? len;
  final String? cutTime;
  final String? img;
  final String? cutUserName;
  final int cutUserId;
  final String? cutUserPhone;
  final String? currentId;
  final List<PipeCuttingTreeNode> children;
  final int level;
  final bool isRoot;
  final bool isCurrent;

  /// 从 CuttingHistoryNode 创建树节点
  factory PipeCuttingTreeNode.fromCuttingHistoryNode(
    CuttingHistoryNode node, {
    int level = 0,
    bool isRoot = false,
    String? currentMaterialId,
  }) {
    final isCurrent = currentMaterialId != null && 
                      node.materialId.toString() == currentMaterialId;
    
    return PipeCuttingTreeNode(
      materialId: node.materialId,
      rootId: node.rootId,
      parentId: node.parentId,
      len: node.len,
      cutTime: node.cutTime,
      img: node.img,
      cutUserName: node.cutUserName,
      cutUserId: node.cutUserId,
      cutUserPhone: node.cutUserPhone,
      currentId: node.currentId,
      level: level,
      isRoot: isRoot,
      isCurrent: isCurrent,
      children: node.children?.map((child) => 
        PipeCuttingTreeNode.fromCuttingHistoryNode(
          child,
          level: level + 1,
          currentMaterialId: currentMaterialId,
        ),
      ).toList() ?? [],
    );
  }

  /// 获取节点显示文本
  String get displayText {
    if (isRoot) {
      return '根节点 (ID: $materialId)';
    }
    return '截管段 (ID: $materialId)';
  }

  /// 获取节点副标题
  String get subtitle {
    final parts = <String>[];
    if (len != null && len!.isNotEmpty) {
      parts.add('长度: $len');
    }
    if (cutTime != null && cutTime!.isNotEmpty) {
      parts.add('时间: $cutTime');
    }
    if (cutUserName != null && cutUserName!.isNotEmpty) {
      parts.add('操作人: $cutUserName');
    }
    return parts.join(' | ');
  }

  /// 复制对象并更新字段
  PipeCuttingTreeNode copyWith({
    int? materialId,
    int? rootId,
    String? parentId,
    String? len,
    String? cutTime,
    String? img,
    String? cutUserName,
    int? cutUserId,
    String? cutUserPhone,
    String? currentId,
    List<PipeCuttingTreeNode>? children,
    int? level,
    bool? isRoot,
    bool? isCurrent,
  }) {
    return PipeCuttingTreeNode(
      materialId: materialId ?? this.materialId,
      rootId: rootId ?? this.rootId,
      parentId: parentId ?? this.parentId,
      len: len ?? this.len,
      cutTime: cutTime ?? this.cutTime,
      img: img ?? this.img,
      cutUserName: cutUserName ?? this.cutUserName,
      cutUserId: cutUserId ?? this.cutUserId,
      cutUserPhone: cutUserPhone ?? this.cutUserPhone,
      currentId: currentId ?? this.currentId,
      children: children ?? this.children,
      level: level ?? this.level,
      isRoot: isRoot ?? this.isRoot,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  List<Object?> get props => [
    materialId,
    rootId,
    parentId,
    len,
    cutTime,
    img,
    cutUserName,
    cutUserId,
    cutUserPhone,
    currentId,
    children,
    level,
    isRoot,
    isCurrent,
  ];
}