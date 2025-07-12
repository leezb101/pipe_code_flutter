// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_code_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmsCodeResult _$SmsCodeResultFromJson(Map<String, dynamic> json) =>
    SmsCodeResult(
      phone: json['phone'] as String,
      smsCode: json['sms_code'] as String,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SmsCodeResultToJson(SmsCodeResult instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'sms_code': instance.smsCode,
      'message': instance.message,
    };
