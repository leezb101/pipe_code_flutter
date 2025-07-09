/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:20:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:20:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'login_account_vo.g.dart';

/// 账号密码登录请求对象
/// 完全匹配API文档中的LoginAccountVO结构
@JsonSerializable()
class LoginAccountVO extends Equatable {
  const LoginAccountVO({
    required this.account,
    required this.password,
    required this.code,
  });

  /// 账号
  final String account;

  /// 密码
  final String password;

  /// 验证码
  final String code;

  factory LoginAccountVO.fromJson(Map<String, dynamic> json) =>
      _$LoginAccountVOFromJson(json);

  Map<String, dynamic> toJson() => _$LoginAccountVOToJson(this);

  LoginAccountVO copyWith({
    String? account,
    String? password,
    String? code,
  }) {
    return LoginAccountVO(
      account: account ?? this.account,
      password: password ?? this.password,
      code: code ?? this.code,
    );
  }

  @override
  List<Object?> get props => [account, password, code];
}