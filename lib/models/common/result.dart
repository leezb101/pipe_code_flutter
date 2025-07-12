/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-12 13:27:13
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'result.g.dart';

/// 通用API响应包装器
/// 完全匹配API文档中的Result结构
@JsonSerializable(genericArgumentFactories: true)
class Result<T> extends Equatable {
  const Result({
    required this.code,
    required this.msg,
    required this.tc,
    this.data,
    this.success,
  });

  /// 错误码
  final int code;

  /// 提示信息
  final String msg;

  /// 接口耗时time consuming
  final int? tc;

  /// 具体的内容
  final T? data;

  /// 是否成功
  final bool? success;

  factory Result.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ResultFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ResultToJson(this, toJsonT);

  Result<T> copyWith({
    int? code,
    String? msg,
    int? tc,
    T? data,
    bool? success,
  }) {
    return Result<T>(
      code: code ?? this.code,
      msg: msg ?? this.msg,
      tc: tc ?? this.tc,
      data: data ?? this.data,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [code, msg, tc, data, success];

  /// 判断是否成功
  bool get isSuccess => code == 0;

  /// 判断是否失败
  bool get isFailure => !isSuccess;
}

/// 专用于Boolean类型的Result
@JsonSerializable()
class ResultBoolean extends Equatable {
  const ResultBoolean({
    required this.code,
    required this.msg,
    required this.tc,
    this.data,
  });

  /// 错误码
  final int code;

  /// 提示信息
  final String msg;

  /// 接口耗时time consuming
  final int tc;

  /// 具体的内容
  final bool? data;

  factory ResultBoolean.fromJson(Map<String, dynamic> json) =>
      _$ResultBooleanFromJson(json);

  Map<String, dynamic> toJson() => _$ResultBooleanToJson(this);

  @override
  List<Object?> get props => [code, msg, tc, data];

  /// 判断是否成功
  bool get isSuccess => code == 0;

  /// 判断是否失败
  bool get isFailure => !isSuccess;
}
