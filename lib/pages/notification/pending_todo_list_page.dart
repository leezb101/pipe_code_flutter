import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/models/notification/notification_message_vo.dart';
import 'package:pipe_code_flutter/services/notification/notification_center.dart';
import 'package:pipe_code_flutter/services/notification/todo_navigator.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/config/routes.dart';

class PendingTodoListPage extends StatefulWidget {
  const PendingTodoListPage({super.key});

  @override
  State<PendingTodoListPage> createState() => _PendingTodoListPageState();
}

class _PendingTodoListPageState extends State<PendingTodoListPage> {
  late final StreamSubscription<List<NotificationMessageVO>> _sub;
  List<NotificationMessageVO> _list = NotificationCenter.instance.pending;

  @override
  void initState() {
    super.initState();
    _sub = NotificationCenter.instance.pendingStream.listen((items) {
      setState(() {
        _list = items;
      });
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> _onTap(NotificationMessageVO msg) async {
    // 先移除再跳转；若用户取消，则不提示；若失败则提示
    NotificationCenter.instance.removePendingById(msg.id);
    final result = await TodoNavigator.navigate(msg);
    if (result == false && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('无法跳转，已从待处理移除')));
      // 失败时引导返回：优先返回上一个页面；若无法返回则跳到主页面
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          final ctx = navigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            GoRouter.of(ctx).goNamed('main');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('待处理')),
      body: _list.isEmpty
          ? const Center(child: Text('暂无待处理事项'))
          : ListView.separated(
              itemCount: _list.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final msg = _list[index];
                return ListTile(
                  title: Text(msg.title.isNotEmpty ? msg.title : '待办提醒'),
                  subtitle: Text(
                    msg.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _onTap(msg),
                );
              },
            ),
      bottomNavigationBar: _list.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: FilledButton.tonal(
                onPressed: () => NotificationCenter.instance.clearPending(),
                child: const Text('清空全部'),
              ),
            )
          : null,
    );
  }
}
