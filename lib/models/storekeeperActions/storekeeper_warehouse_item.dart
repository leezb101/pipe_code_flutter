import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'storekeeper_warehouse_item.g.dart';

@JsonSerializable()
class StorekeeperWarehouseItem extends Equatable {
  final int id;
  final String? name;
  final String? address;
  @JsonKey(defaultValue: false)
  final bool isRealWarehouse;

  const StorekeeperWarehouseItem({
    required this.id,
    this.name,
    this.address,
    this.isRealWarehouse = false,
  });

  factory StorekeeperWarehouseItem.fromJson(Map<String, dynamic> json) =>
      _$StorekeeperWarehouseItemFromJson(json);

  Map<String, dynamic> toJson() => _$StorekeeperWarehouseItemToJson(this);

  @override
  List<Object?> get props => [id, name, address, isRealWarehouse];
}
