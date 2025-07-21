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