import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'common_user_vo.dart';

part 'warehouse_user_info_vo.g.dart';

@JsonSerializable()
class WarehouseUserInfoVO extends Equatable {
  final List<CommonUserVO> warehouseUsers;

  const WarehouseUserInfoVO({
    required this.warehouseUsers,
  });

  factory WarehouseUserInfoVO.fromJson(Map<String, dynamic> json) =>
      _$WarehouseUserInfoVOFromJson(json);

  Map<String, dynamic> toJson() => _$WarehouseUserInfoVOToJson(this);

  @override
  List<Object?> get props => [warehouseUsers];
}