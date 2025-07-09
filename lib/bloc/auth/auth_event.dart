/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:10:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 23:10:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import '../../models/auth/login_account_vo.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// 账号密码登录请求
class AuthLoginWithPasswordRequested extends AuthEvent {
  const AuthLoginWithPasswordRequested({
    required this.loginRequest,
  });

  final LoginAccountVO loginRequest;

  @override
  List<Object> get props => [loginRequest];
}

/// 短信验证码登录请求
class AuthLoginWithSmsRequested extends AuthEvent {
  const AuthLoginWithSmsRequested({
    required this.phone,
    required this.code,
  });

  final String phone;
  final String code;

  @override
  List<Object> get props => [phone, code];
}

/// 请求短信验证码
class AuthSmsCodeRequested extends AuthEvent {
  const AuthSmsCodeRequested({
    required this.phone,
  });

  final String phone;

  @override
  List<Object> get props => [phone];
}

/// 选择项目
class AuthProjectSelected extends AuthEvent {
  const AuthProjectSelected({
    required this.projectId,
  });

  final int projectId;

  @override
  List<Object> get props => [projectId];
}

/// 登出请求
class AuthLogoutRequested extends AuthEvent {}

/// 检查登录状态
class AuthCheckRequested extends AuthEvent {}

/// 刷新Token
class AuthTokenRefreshRequested extends AuthEvent {
  const AuthTokenRefreshRequested({
    required this.uid,
  });

  final String uid;

  @override
  List<Object> get props => [uid];
}