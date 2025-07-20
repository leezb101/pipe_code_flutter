/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-18 18:01:48
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../utils/logger.dart';

part 'result.g.dart';

/// 通用API响应包装器
/// 完全匹配API文档中的Result结构
@JsonSerializable(genericArgumentFactories: true)
class Result<T> extends Equatable {
  const Result({
    required this.code,
    required this.msg,
    this.data,
    this.success,
  });

  /// 错误码
  final int code;

  /// 提示信息
  final String msg;

  /// 具体的内容
  final T? data;

  /// 是否成功
  final bool? success;

  factory Result.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ResultFromJson(json, fromJsonT);

  /// 安全的类型转换方法，优先处理服务器错误
  /// 如果服务器返回错误(code != 0)，直接返回错误信息，不进行data类型转换
  /// 如果服务器返回成功但data类型转换失败，记录详细错误并返回用户友好的错误信息
  static Result<T> safeFromJson<T>(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
    String modelName,
  ) {
    try {
      // 首先解析基础字段
      final code = json['code'] as int? ?? -1;
      final msg = json['msg'] as String? ?? '未知错误';
      final success = json['success'] as bool?;

      // 如果服务器返回错误，直接返回错误结果，不进行data转换
      if (code != 0) {
        Logger.info('服务器返回错误: code=$code, msg=$msg', tag: 'API_ERROR');
        return Result<T>(code: code, msg: msg, data: null, success: success);
      }

      // 服务器返回成功，尝试进行data类型转换
      try {
        final data = json['data'];
        T? convertedData;
        
        if (data != null) {
          convertedData = fromJsonT(data);
          Logger.info('数据类型转换成功: $modelName', tag: 'TYPE_CONVERSION');
        }

        return Result<T>(
          code: code,
          msg: msg,
          data: convertedData,
          success: success,
        );
      } catch (conversionError, stackTrace) {
        // 类型转换失败，记录详细错误信息但不影响用户体验
        Logger.error(
          '数据序列化失败: $modelName',
          tag: 'TYPE_CONVERSION_ERROR',
          error: conversionError,
        );
        Logger.error(
          '原始数据: ${json['data']}',
          tag: 'TYPE_CONVERSION_ERROR',
        );
        Logger.error(
          '堆栈跟踪: $stackTrace',
          tag: 'TYPE_CONVERSION_ERROR',
        );

        // 返回用户友好的错误信息
        return Result<T>(
          code: -1,
          msg: '数据异常，请稍后再试',
          data: null,
        );
      }
    } catch (parseError, stackTrace) {
      // JSON解析基础字段失败
      Logger.error(
        'JSON基础字段解析失败: $modelName',
        tag: 'JSON_PARSE_ERROR',
        error: parseError,
      );
      Logger.error(
        '原始JSON: $json',
        tag: 'JSON_PARSE_ERROR',
      );
      Logger.error(
        '堆栈跟踪: $stackTrace',
        tag: 'JSON_PARSE_ERROR',
      );

      return Result<T>(
        code: -1,
        msg: '数据格式异常，请稍后再试',
        data: null,
      );
    }
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ResultToJson(this, toJsonT);

  Result<T> copyWith({int? code, String? msg, T? data, bool? success}) {
    return Result<T>(
      code: code ?? this.code,
      msg: msg ?? this.msg,
      data: data ?? this.data,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [code, msg, data, success];

  /// 判断是否成功
  bool get isSuccess => code == 0;

  /// 判断是否失败
  bool get isFailure => !isSuccess;
}

/// 专用于Boolean类型的Result
@JsonSerializable()
class ResultBoolean extends Equatable {
  const ResultBoolean({required this.code, required this.msg, this.data});

  /// 错误码
  final int code;

  /// 提示信息
  final String msg;

  /// 具体的内容
  final bool? data;

  factory ResultBoolean.fromJson(Map<String, dynamic> json) =>
      _$ResultBooleanFromJson(json);

  Map<String, dynamic> toJson() => _$ResultBooleanToJson(this);

  @override
  List<Object?> get props => [code, msg, data];

  /// 判断是否成功
  bool get isSuccess => code == 0;

  /// 判断是否失败
  bool get isFailure => !isSuccess;
}
