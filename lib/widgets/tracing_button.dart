import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/services/tracing/tracing_manager.dart';

/// 自动上报审计日志的button
/// 自动捕获按钮标题，并将其作为审计日志的一部分
/// 在执行onPressed回调期间设置一个临时的、更精确的操作上下文
class TracingElevatedButton extends StatelessWidget {
  /// 按钮按下的回调，可以是同步或异步函数
  final FutureOr<void> Function()? onPressed;

  /// 按钮的内容，通常是一个text组件
  final Widget child;

  /// 明确指定用于审计的标题，如果为null，组件会尝试从child中提取文本
  final String? actionTitle;

  /// 按钮的样式，与ElevatedButton.style保持一致
  final ButtonStyle? style;

  /// 其他 ElevatedButton 的属性
  final FocusNode? focusNode;
  final bool autoFocus;
  final Clip clipBehavior;

  const TracingElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.actionTitle,
    this.style,
    this.focusNode,
    this.autoFocus = false,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final tracingManager = getIt<TracingManager>();

    return ElevatedButton(
      onPressed: onPressed == null
          ? null
          : () async {
              // 尝试获取按钮标题
              String? title = actionTitle;
              if (title == null) {
                if (child is Text) {
                  title = (child as Text).data;
                } else if (child is RichText) {
                  final richText = child as RichText;
                  title = richText.text.toPlainText();
                }
              }
              title ??= '未命名操作';

              await tracingManager.scopeActionWithTitle(title, () async {
                final result = onPressed!();
                if (result is Future) {
                  await result;
                }
              });
            },
      style: style,
      focusNode: focusNode,
      autofocus: autoFocus,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
