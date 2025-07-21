/*
 * @Author: LeeZB
 * @Date: 2025-07-21 14:31:56
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-21 16:51:39
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'warehouse_vo.g.dart';

@JsonSerializable()
class WarehouseVO extends Equatable {
  final int id;
  final String name;
  final String address;
  final bool isRealWarehouse;

  const WarehouseVO({
    required this.id,
    required this.name,
    required this.address,
    required this.isRealWarehouse,
  });

  factory WarehouseVO.fromJson(Map<String, dynamic> json) =>
      _$WarehouseVOFromJson(json);

  Map<String, dynamic> toJson() => _$WarehouseVOToJson(this);

  @override
  List<Object?> get props => [id, name, address, isRealWarehouse];
}
