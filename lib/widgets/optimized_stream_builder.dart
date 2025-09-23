import 'dart:async';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class OptimizedStreamBuilder<T extends Equatable> extends StatefulWidget {
  final Stream<T> stream;
  final T? initialData;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext constext)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  const OptimizedStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.initialData,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  State<StatefulWidget> createState() => _OptimizedStreamBuilderState<T>();
}

class _OptimizedStreamBuilderState<T extends Equatable>
    extends State<OptimizedStreamBuilder<T>> {
  T? _currentData;
  Object? _error;
  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _currentData = widget.initialData;
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant OptimizedStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _subscription?.cancel();
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.stream.listen(
      (data) {
        // 只有数据真正变化时才重建(Equatable的作用)
        if (data != _currentData) {
          if (mounted) {
            setState(() {
              _currentData = data;
              _error = null; // 清除错误状态
            });
          }
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _error = error;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!) ??
          Center(child: Text('错误：$_error'));
    }
    if (_currentData == null) {
      return widget.loadingBuilder?.call(context) ??
          Center(child: CircularProgressIndicator());
    }
    return widget.builder(context, _currentData!);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
