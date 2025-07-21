/*
 * @Author: LeeZB
 * @Date: 2025-07-21 14:31:11
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-21 17:36:09
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common_user_vo.g.dart';

@JsonSerializable()
class CommonUserVO extends Equatable {
  final int userId;
  final String name;
  final String phone;
  final bool? messageTo;
  final bool? realHandler;

  const CommonUserVO({
    required this.userId,
    required this.name,
    required this.phone,
    this.messageTo,
    this.realHandler,
  });

  factory CommonUserVO.fromJson(Map<String, dynamic> json) =>
      _$CommonUserVOFromJson(json);

  Map<String, dynamic> toJson() => _$CommonUserVOToJson(this);

  @override
  List<Object?> get props => [userId, name, phone, messageTo, realHandler];
}
