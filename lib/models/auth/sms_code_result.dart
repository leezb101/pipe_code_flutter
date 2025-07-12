/*
 * @Author: LeeZB
 * @Date: 2025-07-12 20:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-12 20:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'sms_code_result.g.dart';

/// SMS验证码请求结果
/// 包含短信发送状态和sms_code标识符
@JsonSerializable()
class SmsCodeResult extends Equatable {
  const SmsCodeResult({
    required this.phone,
    required this.smsCode,
    this.message,
  });

  /// 接收短信的手机号码
  final String phone;
  
  /// SMS验证码标识符，来自response header的sms_code字段
  /// 登录时需要作为request header传递
  @JsonKey(name: 'sms_code')
  final String smsCode;
  
  /// 可选的消息内容
  final String? message;

  factory SmsCodeResult.fromJson(Map<String, dynamic> json) =>
      _$SmsCodeResultFromJson(json);

  Map<String, dynamic> toJson() => _$SmsCodeResultToJson(this);

  @override
  List<Object?> get props => [phone, smsCode, message];

  /// 检查SMS验证码数据是否完整
  bool get isValid => phone.isNotEmpty && smsCode.isNotEmpty;

  /// 获取简短的SMS验证码标识（用于日志显示）
  String get shortSmsCode => smsCode.length > 8 
      ? '${smsCode.substring(0, 8)}...' 
      : smsCode;

  /// 创建一个包含手机号和sms_code的结果
  factory SmsCodeResult.create({
    required String phone,
    required String smsCode,
    String? message,
  }) {
    return SmsCodeResult(
      phone: phone,
      smsCode: smsCode,
      message: message,
    );
  }

  @override
  String toString() {
    return 'SmsCodeResult(phone: $phone, smsCode: $shortSmsCode, message: $message)';
  }
}