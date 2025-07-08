/*
 * @Author: LeeZB
 * @Date: 2025-07-07 14:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-07 14:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'pipe_material.g.dart';

@JsonSerializable()
class PipeMaterial extends Equatable {
  const PipeMaterial({
    required this.id,
    required this.materialCode,
    required this.materialName,
    required this.specification,
    required this.quantity,
    this.unit = '个',
    this.batchCode,
    this.deliveryDate,
    this.supplier,
    this.remarks,
  });

  final String id;
  final String materialCode;
  final String materialName;
  final String specification;
  final int quantity;
  final String unit;
  final String? batchCode;
  final DateTime? deliveryDate;
  final String? supplier;
  final String? remarks;

  factory PipeMaterial.fromJson(Map<String, dynamic> json) =>
      _$PipeMaterialFromJson(json);

  Map<String, dynamic> toJson() => _$PipeMaterialToJson(this);

  PipeMaterial copyWith({
    String? id,
    String? materialCode,
    String? materialName,
    String? specification,
    int? quantity,
    String? unit,
    String? batchCode,
    DateTime? deliveryDate,
    String? supplier,
    String? remarks,
  }) {
    return PipeMaterial(
      id: id ?? this.id,
      materialCode: materialCode ?? this.materialCode,
      materialName: materialName ?? this.materialName,
      specification: specification ?? this.specification,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      batchCode: batchCode ?? this.batchCode,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      supplier: supplier ?? this.supplier,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  List<Object?> get props => [
        id,
        materialCode,
        materialName,
        specification,
        quantity,
        unit,
        batchCode,
        deliveryDate,
        supplier,
        remarks,
      ];
}