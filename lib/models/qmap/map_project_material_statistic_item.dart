import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'map_project_material_statistic_item.g.dart';

@JsonSerializable()
class MapProjectMaterialStatisticItem extends Equatable {
  final int? materialType;
  final String? materialName;
  final int? num;

  const MapProjectMaterialStatisticItem({
    this.materialType,
    this.materialName,
    this.num,
  });

  /// JSON -> Model
  factory MapProjectMaterialStatisticItem.fromJson(Map<String, dynamic> json) =>
      _$MapProjectMaterialStatisticItemFromJson(json);

  /// Model -> JSON
  Map<String, dynamic> toJson() =>
      _$MapProjectMaterialStatisticItemToJson(this);

  @override
  List<Object?> get props => [materialType, materialName, num];
}
