// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captcha_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaptchaResult _$CaptchaResultFromJson(Map<String, dynamic> json) =>
    CaptchaResult(
      base64Data: json['base64_data'] as String,
      imgCode: json['img_code'] as String,
    );

Map<String, dynamic> _$CaptchaResultToJson(CaptchaResult instance) =>
    <String, dynamic>{
      'base64_data': instance.base64Data,
      'img_code': instance.imgCode,
    };
