import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'map_project_user.g.dart';

@JsonSerializable()
class MapProjectUser extends Equatable {
  final int userId;
  final String? name;
  final String? phone;
  final bool? messageTo;
  final bool? realHandler;

  const MapProjectUser({
    required this.userId,
    this.name,
    this.phone,
    this.messageTo,
    this.realHandler,
  });

  /// JSON -> Model
  factory MapProjectUser.fromJson(Map<String, dynamic> json) =>
      _$MapProjectUserFromJson(json);

  /// Model -> JSON
  Map<String, dynamic> toJson() => _$MapProjectUserToJson(this);

  @override
  List<Object?> get props => [userId, name, phone, messageTo, realHandler];
}
