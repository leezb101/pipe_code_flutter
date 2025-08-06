/*
 * @Author: LeeZB
 * @Date: 2025-08-07 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-07 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */

class PipeCuttingTreeNode {
  final String id;
  final String materialCode;
  final String materialId;
  final String? parentId;
  final String title;
  final double? length;
  final String? specification;
  final DateTime? cutDate;
  final String status; // 'parent', 'child', 'leaf'
  final String? details; // Additional details for popover
  final List<PipeCuttingTreeNode> children;

  PipeCuttingTreeNode({
    required this.id,
    required this.materialCode,
    required this.materialId,
    this.parentId,
    required this.title,
    this.length,
    this.specification,
    this.cutDate,
    required this.status,
    this.details,
    List<PipeCuttingTreeNode>? children,
  }) : children = children ?? [];

  /// Check if this node is the query node
  bool get isQueryNode => materialId == materialId;

  /// Create a copy with updated fields
  PipeCuttingTreeNode copyWith({
    String? id,
    String? materialCode,
    String? materialId,
    String? parentId,
    String? title,
    double? length,
    String? specification,
    DateTime? cutDate,
    String? status,
    String? details,
    List<PipeCuttingTreeNode>? children,
  }) {
    return PipeCuttingTreeNode(
      id: id ?? this.id,
      materialCode: materialCode ?? this.materialCode,
      materialId: materialId ?? this.materialId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      length: length ?? this.length,
      specification: specification ?? this.specification,
      cutDate: cutDate ?? this.cutDate,
      status: status ?? this.status,
      details: details ?? this.details,
      children: children ?? this.children,
    );
  }

  /// Factory method for creating from JSON
  factory PipeCuttingTreeNode.fromJson(Map<String, dynamic> json) {
    return PipeCuttingTreeNode(
      id: json['id'] as String,
      materialCode: json['materialCode'] as String,
      materialId: json['materialId'] as String,
      parentId: json['parentId'] as String?,
      title: json['title'] as String,
      length: (json['length'] as num?)?.toDouble(),
      specification: json['specification'] as String?,
      cutDate: json['cutDate'] != null 
          ? DateTime.parse(json['cutDate'] as String) 
          : null,
      status: json['status'] as String,
      details: json['details'] as String?,
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => PipeCuttingTreeNode.fromJson(child))
          .toList() ?? [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialCode': materialCode,
      'materialId': materialId,
      'parentId': parentId,
      'title': title,
      'length': length,
      'specification': specification,
      'cutDate': cutDate?.toIso8601String(),
      'status': status,
      'details': details,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }
}