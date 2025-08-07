/*
 * @Author: LeeZB
 * @Date: 2025-08-07 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-07 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'notification_action_vo.g.dart';

/// 通知操作对象
/// 用于定义通知触发的具体操作
@JsonSerializable()
class NotificationActionVO extends Equatable {
  const NotificationActionVO({
    required this.type,
    required this.method,
    this.url,
    this.params,
    this.headers,
    this.uiAction,
    this.confirmMessage,
  });

  /// 操作类型
  final String type;

  /// 调用方法 (HTTP_GET, HTTP_POST, UI_NAVIGATE, etc.)
  final String method;

  /// 请求URL (用于HTTP操作)
  final String? url;

  /// 请求参数
  final Map<String, dynamic>? params;

  /// 请求头
  final Map<String, String>? headers;

  /// UI操作相关
  final UiActionVO? uiAction;

  /// 确认消息
  final String? confirmMessage;

  factory NotificationActionVO.fromJson(Map<String, dynamic> json) =>
      _$NotificationActionVOFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationActionVOToJson(this);

  NotificationActionVO copyWith({
    String? type,
    String? method,
    String? url,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    UiActionVO? uiAction,
    String? confirmMessage,
  }) {
    return NotificationActionVO(
      type: type ?? this.type,
      method: method ?? this.method,
      url: url ?? this.url,
      params: params ?? this.params,
      headers: headers ?? this.headers,
      uiAction: uiAction ?? this.uiAction,
      confirmMessage: confirmMessage ?? this.confirmMessage,
    );
  }

  /// 检查是否为HTTP操作
  bool get isHttpAction => method.startsWith('HTTP_');

  /// 检查是否为UI操作
  bool get isUiAction => method.startsWith('UI_');

  /// 检查是否需要用户确认
  bool get requiresConfirmation => confirmMessage != null && confirmMessage!.isNotEmpty;

  @override
  List<Object?> get props => [
        type,
        method,
        url,
        params,
        headers,
        uiAction,
        confirmMessage,
      ];
}

/// UI操作对象
/// 用于定义UI相关的操作
@JsonSerializable()
class UiActionVO extends Equatable {
  const UiActionVO({
    required this.action,
    this.route,
    this.params,
    this.animation,
  });

  /// UI操作类型
  final String action;

  /// 路由路径
  final String? route;

  /// 路由参数
  final Map<String, dynamic>? params;

  /// 动画类型
  final String? animation;

  factory UiActionVO.fromJson(Map<String, dynamic> json) =>
      _$UiActionVOFromJson(json);

  Map<String, dynamic> toJson() => _$UiActionVOToJson(this);

  UiActionVO copyWith({
    String? action,
    String? route,
    Map<String, dynamic>? params,
    String? animation,
  }) {
    return UiActionVO(
      action: action ?? this.action,
      route: route ?? this.route,
      params: params ?? this.params,
      animation: animation ?? this.animation,
    );
  }

  @override
  List<Object?> get props => [action, route, params, animation];
}

/// 操作方法常量
class NotificationActionMethods {
  static const String HTTP_GET = 'HTTP_GET';
  static const String HTTP_POST = 'HTTP_POST';
  static const String HTTP_PUT = 'HTTP_PUT';
  static const String HTTP_DELETE = 'HTTP_DELETE';
  static const String UI_NAVIGATE = 'UI_NAVIGATE';
  static const String UI_DIALOG = 'UI_DIALOG';
  static const String UI_TOAST = 'UI_TOAST';
  static const String UI_REFRESH = 'UI_REFRESH';
}