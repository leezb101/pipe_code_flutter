import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'storekeeper_signin_request.g.dart';

@JsonSerializable()
class StorekeeperSigninRequest extends Equatable {
  final List<String> materialIds;
  final int warehouseId;
  final String img;
  final String? describe;

  const StorekeeperSigninRequest({
    required this.materialIds,
    required this.warehouseId,
    required this.img,
    this.describe,
  });

  factory StorekeeperSigninRequest.fromJson(Map<String, dynamic> json) =>
      _$StorekeeperSigninRequestFromJson(json);

  Map<String, dynamic> toJson() => _$StorekeeperSigninRequestToJson(this);

  @override
  List<Object?> get props => [materialIds, warehouseId, img, describe];
}
