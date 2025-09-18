import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/services/tracing/tracing_context.dart';
import 'package:pipe_code_flutter/utils/tracing_context_x.dart';

/// 自动上报审计日志的button
/// 自动捕获按钮标题，并将其作为审计日志的一部分
/// 在执行onPressed回调期间设置一个临时的、更精确的操作上下文
class TracingElevatedButton extends StatelessWidget {
  /// 按钮按下的回调，可以是同步或异步函数
  final void Function(TracingContext tracingContext) onPressed;

  /// 按钮的内容，通常是一个text组件
  final Widget child;

  /// 明确指定用于审计的标题，如果为null，组件会尝试从child中提取文本
  final String? actionTitle;

  /// 按钮的样式，与ElevatedButton.style保持一致
  final ButtonStyle? style;

  final bool enabled;

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
    this.enabled = true,
    this.autoFocus = false,
    this.clipBehavior = Clip.none,
  });

  String _getActionTitle() {
    if (actionTitle != null && actionTitle!.isNotEmpty) {
      return actionTitle!;
    }
    if (child is Text) {
      final textWidget = child as Text;
      if (textWidget.data != null && textWidget.data!.isNotEmpty) {
        return textWidget.data!;
      }
    }
    return '未命名操作';
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle effectiveStyle = style ?? ElevatedButton.styleFrom();
    return ElevatedButton(
      style: effectiveStyle,
      onPressed: enabled
          ? () {
              final title = _getActionTitle();
              final tracingContext = context.createActionContext(title);
              onPressed(tracingContext);
            }
          : null,
      focusNode: focusNode,
      autofocus: autoFocus,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
