/*
 * @Author: LeeZB
 * @Date: 2025-07-12 19:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-12 19:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'captcha_result.g.dart';

/// 验证码请求结果
/// 包含base64图片数据和img_code header值
@JsonSerializable()
class CaptchaResult extends Equatable {
  const CaptchaResult({
    required this.base64Data,
    required this.imgCode,
  });

  /// base64编码的验证码图片数据
  /// 来自API响应体的data字段
  @JsonKey(name: 'base64_data')
  final String base64Data;

  /// 验证码标识符
  /// 来自API响应头的img_code字段，登录时需要作为请求头传递
  @JsonKey(name: 'img_code')
  final String imgCode;

  factory CaptchaResult.fromJson(Map<String, dynamic> json) =>
      _$CaptchaResultFromJson(json);

  Map<String, dynamic> toJson() => _$CaptchaResultToJson(this);

  CaptchaResult copyWith({
    String? base64Data,
    String? imgCode,
  }) {
    return CaptchaResult(
      base64Data: base64Data ?? this.base64Data,
      imgCode: imgCode ?? this.imgCode,
    );
  }

  @override
  List<Object?> get props => [base64Data, imgCode];

  /// 检查验证码数据是否有效
  bool get isValid => base64Data.isNotEmpty && imgCode.isNotEmpty;

  /// 获取验证码图片数据大小（字符数）
  int get dataSize => base64Data.length;

  /// 获取简短的验证码标识（用于日志显示）
  String get shortImgCode => imgCode.length > 8 
      ? '${imgCode.substring(0, 8)}...' 
      : imgCode;

  @override
  String toString() {
    return 'CaptchaResult(imgCode: $shortImgCode, dataSize: $dataSize)';
  }
}