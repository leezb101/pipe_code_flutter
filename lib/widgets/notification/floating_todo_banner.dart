import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/models/notification/notification_message_vo.dart';
import 'package:pipe_code_flutter/services/notification/notification_center.dart';
import 'package:pipe_code_flutter/services/notification/todo_navigator.dart';
import 'package:pipe_code_flutter/config/routes.dart';
import 'package:go_router/go_router.dart';

/// A global overlay banner that listens to NotificationCenter.todoStream
/// and shows a small actionable bar: [Go now] [Later]
class FloatingTodoBannerHost extends StatefulWidget {
  final Widget child;
  const FloatingTodoBannerHost({super.key, required this.child});

  @override
  State<FloatingTodoBannerHost> createState() => _FloatingTodoBannerHostState();
}

class _FloatingTodoBannerHostState extends State<FloatingTodoBannerHost>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription<List<NotificationMessageVO>> _sub;
  late final StreamSubscription<List<NotificationMessageVO>> _pendingSub;
  final List<NotificationMessageVO> _queue = [];

  bool _visible = false;
  NotificationMessageVO? _current;
  int _pendingCount = NotificationCenter.instance.pending.length;

  @override
  void initState() {
    super.initState();
    _sub = NotificationCenter.instance.todoStream.listen((batch) {
      if (batch.isEmpty) return;
      setState(() {
        _queue.addAll(batch);
      });
      _showNext();
    });

    _pendingSub = NotificationCenter.instance.pendingStream.listen((items) {
      setState(() {
        _pendingCount = items.length;
      });
    });
  }

  void _showNext() {
    if (_visible || _queue.isEmpty) return;
    setState(() {
      _current = _queue.removeAt(0);
      _visible = true;
    });
  }

  void _hide({bool andShowNext = true}) {
    if (!_visible) return;
    setState(() {
      _visible = false;
    });
    // slight delay to avoid animation jank
    Future.delayed(const Duration(milliseconds: 250), () {
      if (andShowNext) _showNext();
    });
  }

  Future<void> _onGoNow() async {
    final msg = _current;
    if (msg == null) return;
    final result = await TodoNavigator.navigate(msg);
    if (result == false) {
      // If cannot navigate, push to pending for later and fallback hide
      NotificationCenter.instance.addPending(msg);
    }
    _hide();
  }

  void _onLater() {
    final msg = _current;
    if (msg != null) {
      NotificationCenter.instance.addPending(msg);
    }
    _hide();
  }

  @override
  void dispose() {
    _sub.cancel();
    _pendingSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_visible && _current != null) _buildBanner(context, _current!),
        if (_pendingCount > 0) _buildQuickEntry(context),
      ],
    );
  }

  Widget _buildQuickEntry(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 90 + MediaQuery.of(context).padding.bottom,
      child: FloatingActionButton.extended(
        heroTag: 'pendingTodoFab',
        onPressed: () {
          // open pending list via GoRouter with global navigatorKey
          final ctx = navigatorKey.currentContext;
          if (ctx != null) {
            GoRouter.of(ctx).pushNamed('pending-todo');
          }
        },
        icon: const Icon(Icons.inbox),
        label: Text('待处理($_pendingCount)'),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, NotificationMessageVO msg) {
    final theme = Theme.of(context);
    return Positioned(
      left: 12,
      right: 12,
      bottom: 20 + MediaQuery.of(context).padding.bottom,
      child: Material(
        elevation: 6,
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.task_alt, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.title.isNotEmpty ? msg.title : '新的待办',
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      msg.content,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: _onLater, child: const Text('稍后处理')),
              const SizedBox(width: 4),
              FilledButton(onPressed: _onGoNow, child: const Text('立即前往')),
            ],
          ),
        ),
      ),
    );
  }
}
