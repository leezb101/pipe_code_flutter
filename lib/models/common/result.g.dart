// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result<T> _$ResultFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => Result<T>(
  code: (json['code'] as num).toInt(),
  msg: json['msg'] as String,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  success: json['success'] as bool?,
);

Map<String, dynamic> _$ResultToJson<T>(
  Result<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'code': instance.code,
  'msg': instance.msg,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'success': instance.success,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

ResultBoolean _$ResultBooleanFromJson(Map<String, dynamic> json) =>
    ResultBoolean(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] as bool?,
    );

Map<String, dynamic> _$ResultBooleanToJson(ResultBoolean instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };
