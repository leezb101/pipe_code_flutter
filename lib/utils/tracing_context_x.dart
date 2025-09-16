import 'package:flutter/widgets.dart';
import '../config/service_locator.dart';
import '../services/tracing/tracing_manager.dart';
import '../services/tracing/tracing_context.dart';

extension TracingContextX on BuildContext {
  /// 根据给定的操作标题（通常是按钮文本），创建一个精确的操作上下文
  ///
  /// 它会自动获取由`TracingNavigatorObserver`添加的当前页面上下文，并结合提供的标题创建一个新的上下文
  /// 例如：
  /// 页面上下文：{descrpition: '登录页'}
  /// actionTitle: '账号密码登录'
  /// 返回上下文：{descrpition: '登录页 - 账号密码登录'}
  TracingContext createActionContext(String actionTitle) {
    final manager = getIt<TracingManager>();
    final pageContext =
        manager.currentContext ??
        const TracingContext(
          source: 'unknown',
          action: 'unknown',
          description: '未知页面',
        );

    return pageContext.copyWith(
      action: 'user-action',
      description: pageContext.description != null
          ? '${pageContext.description} - $actionTitle'
          : actionTitle,
    );
  }
}
