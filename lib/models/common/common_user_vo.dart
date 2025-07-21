import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common_user_vo.g.dart';

@JsonSerializable()
class CommonUserVO extends Equatable {
  final int userId;
  final String name;
  final String phone;
  final bool messageTo;
  final bool realHandler;

  const CommonUserVO({
    required this.userId,
    required this.name,
    required this.phone,
    required this.messageTo,
    required this.realHandler,
  });

  factory CommonUserVO.fromJson(Map<String, dynamic> json) =>
      _$CommonUserVOFromJson(json);

  Map<String, dynamic> toJson() => _$CommonUserVOToJson(this);

  @override
  List<Object?> get props => [userId, name, phone, messageTo, realHandler];
}