/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:10:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 23:10:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/services/tracing/tracing_context.dart';
import '../../models/auth/login_account_vo.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

abstract class TracableAuthEvent extends AuthEvent {
  const TracableAuthEvent({required this.tracingContext});

  final TracingContext tracingContext;

  @override
  List<Object> get props => [tracingContext];
}

/// 账号密码登录请求
class AuthLoginWithPasswordRequested extends TracableAuthEvent {
  const AuthLoginWithPasswordRequested({
    required super.tracingContext,
    required this.loginRequest,
    this.imgCode,
  });

  final LoginAccountVO loginRequest;

  /// 验证码标识符，来自验证码接口response header的img_code字段
  final String? imgCode;

  @override
  List<Object> get props => [
    loginRequest,
    if (imgCode != null) imgCode!,
    super.props,
  ];
}

/// 短信验证码登录请求
class AuthLoginWithSmsRequested extends TracableAuthEvent {
  const AuthLoginWithSmsRequested({
    required super.tracingContext,
    required this.phone,
    required this.code,
    this.smsCode,
  });

  final String phone;
  final String code;

  /// SMS验证码标识符，来自短信验证码接口response header的sms_code字段
  final String? smsCode;

  @override
  List<Object> get props => [
    phone,
    code,
    if (smsCode != null) smsCode!,
    super.props,
  ];
}

/// 请求短信验证码
class AuthSmsCodeRequested extends TracableAuthEvent {
  const AuthSmsCodeRequested({
    required super.tracingContext,
    required this.phone,
  });

  final String phone;

  @override
  List<Object> get props => [phone, super.props];
}

/// 请求图片验证码
class AuthCaptchaRequested extends AuthEvent {
  const AuthCaptchaRequested();

  @override
  List<Object> get props => [];
}

/// 登出请求
class AuthLogoutRequested extends AuthEvent {}

/// 检查登录状态
class AuthCheckRequested extends AuthEvent {}

/// 刷新Token
class AuthTokenRefreshRequested extends AuthEvent {
  const AuthTokenRefreshRequested({required this.uid});

  final String uid;

  @override
  List<Object> get props => [uid];
}
