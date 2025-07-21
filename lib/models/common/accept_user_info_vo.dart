import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'common_user_vo.dart';

part 'accept_user_info_vo.g.dart';

@JsonSerializable()
class AcceptUserInfoVO extends Equatable {
  final List<CommonUserVO> supervisorUsers;
  final List<CommonUserVO> constructionUsers;

  const AcceptUserInfoVO({
    required this.supervisorUsers,
    required this.constructionUsers,
  });

  factory AcceptUserInfoVO.fromJson(Map<String, dynamic> json) =>
      _$AcceptUserInfoVOFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptUserInfoVOToJson(this);

  @override
  List<Object?> get props => [supervisorUsers, constructionUsers];

  AcceptUserInfoVO copyWith({
    List<CommonUserVO>? supervisorUsers,
    List<CommonUserVO>? constructionUsers,
  }) {
    return AcceptUserInfoVO(
      supervisorUsers: supervisorUsers ?? this.supervisorUsers,
      constructionUsers: constructionUsers ?? this.constructionUsers,
    );
  }
}