import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common_user_vo.g.dart';

@JsonSerializable()
class CommonUserVO extends Equatable {
  final String name;
  final String phone;
  final bool messageTo;

  const CommonUserVO({
    required this.name,
    required this.phone,
    required this.messageTo,
  });

  factory CommonUserVO.fromJson(Map<String, dynamic> json) =>
      _$CommonUserVOFromJson(json);

  Map<String, dynamic> toJson() => _$CommonUserVOToJson(this);

  @override
  List<Object?> get props => [name, phone, messageTo];

  CommonUserVO copyWith({
    String? name,
    String? phone,
    bool? messageTo,
  }) {
    return CommonUserVO(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      messageTo: messageTo ?? this.messageTo,
    );
  }
}