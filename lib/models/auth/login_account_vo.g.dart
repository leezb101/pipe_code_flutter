// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_account_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginAccountVO _$LoginAccountVOFromJson(Map<String, dynamic> json) =>
    LoginAccountVO(
      account: json['account'] as String,
      password: json['password'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$LoginAccountVOToJson(LoginAccountVO instance) =>
    <String, dynamic>{
      'account': instance.account,
      'password': instance.password,
      'code': instance.code,
    };
