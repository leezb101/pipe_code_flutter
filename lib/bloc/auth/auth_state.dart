/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:15:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 23:15:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import '../../models/user/wx_login_vo.dart';
import '../../models/user/current_user_on_project_role_info.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// 认证初始状态
class AuthInitial extends AuthState {}

/// 认证加载中
class AuthLoading extends AuthState {}

/// 短信验证码发送中
class AuthSmsCodeSending extends AuthState {}

/// 短信验证码发送成功
class AuthSmsCodeSent extends AuthState {
  const AuthSmsCodeSent({
    required this.phone,
    required this.smsCode,
  });

  final String phone;
  
  /// SMS验证码标识符，来自response header的sms_code字段
  /// 登录时需要作为request header传递
  final String smsCode;

  @override
  List<Object> get props => [phone, smsCode];

  /// 检查SMS验证码数据是否完整
  bool get isValid => phone.isNotEmpty && smsCode.isNotEmpty;

  /// 获取简短的SMS验证码标识（用于日志显示）
  String get shortSmsCode => smsCode.length > 8 
      ? '${smsCode.substring(0, 8)}...' 
      : smsCode;
}

/// 图片验证码加载中
class AuthCaptchaLoading extends AuthState {}

/// 图片验证码加载成功
class AuthCaptchaLoaded extends AuthState {
  const AuthCaptchaLoaded({
    required this.captchaBase64,
    required this.imgCode,
  });

  /// base64编码的验证码图片数据
  final String captchaBase64;
  
  /// 验证码标识符，来自response header的img_code字段
  /// 登录时需要作为request header传递
  final String imgCode;

  @override
  List<Object> get props => [captchaBase64, imgCode];

  /// 检查验证码数据是否完整
  bool get isValid => captchaBase64.isNotEmpty && imgCode.isNotEmpty;

  /// 获取简短的验证码标识（用于日志显示）
  String get shortImgCode => imgCode.length > 8 
      ? '${imgCode.substring(0, 8)}...' 
      : imgCode;
}

/// 登录成功，等待选择项目
class AuthLoginSuccess extends AuthState {
  const AuthLoginSuccess({required this.wxLoginVO});

  final WxLoginVO wxLoginVO;

  @override
  List<Object> get props => [wxLoginVO];
}

/// 项目选择成功，完全认证
class AuthFullyAuthenticated extends AuthState {
  const AuthFullyAuthenticated({
    required this.wxLoginVO,
    required this.currentUserRoleInfo,
  });

  final WxLoginVO wxLoginVO;
  final CurrentUserOnProjectRoleInfo currentUserRoleInfo;

  @override
  List<Object> get props => [wxLoginVO, currentUserRoleInfo];
}

/// 认证失败
class AuthUnauthenticated extends AuthState {}

/// 认证错误
class AuthFailure extends AuthState {
  const AuthFailure({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}

/// Token刷新成功
class AuthTokenRefreshed extends AuthState {
  const AuthTokenRefreshed({required this.wxLoginVO});

  final WxLoginVO wxLoginVO;

  @override
  List<Object> get props => [wxLoginVO];
}