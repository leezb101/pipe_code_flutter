/*
 * Helper to navigate to appropriate pages for Todo notifications
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/config/routes.dart';
import 'package:pipe_code_flutter/models/notification/notification_message_vo.dart';
import 'package:pipe_code_flutter/models/notification/todo_subtype.dart';
import 'package:pipe_code_flutter/bloc/session/session_bloc.dart';
import 'package:pipe_code_flutter/bloc/session/session_state.dart';
import 'package:pipe_code_flutter/bloc/session/session_event.dart';
import 'package:pipe_code_flutter/models/records/record_item.dart';
import 'package:pipe_code_flutter/models/todo/todo_task.dart';

class TodoNavigator {
  /// Navigate based on message metadata.
  /// Returns true (成功), false (失败), 或 null (用户取消切换)。
  static Future<bool?> navigate(NotificationMessageVO message) async {
    final meta = message.metadata ?? const <String, dynamic>{};
    final subtypeName = meta['todoSubtype']?.toString();
    TodoSubtype subtype;
    try {
      subtype = subtypeName != null
          ? TodoSubtype.values.firstWhere(
              (e) => e.name.toLowerCase() == subtypeName.toLowerCase(),
              orElse: () => TodoSubtype.unknown,
            )
          : TodoSubtype.unknown;
    } catch (_) {
      subtype = TodoSubtype.unknown;
    }

    final idValue = meta['businessId']?.toString();
    final targetProjectId = _asInt(meta['projectId']);

    Future<bool> openTodoListFallback() async {
      final ctx = navigatorKey.currentContext;
      if (ctx == null) return false;
      GoRouter.of(ctx).goNamed('records', queryParameters: {'tab': 'todo'});
      return true;
    }

    if (idValue == null || idValue.isEmpty) {
      return openTodoListFallback();
    }

    final ctx = navigatorKey.currentContext;
    if (ctx == null) return false;

    // 项目不一致时，提示并切换
    if (targetProjectId != null) {
      final session = ctx.read<SessionBloc>();
      final state = session.state;
      int? currentProjectId;
      String? targetProjectName;
      if (state is SessionProjectEstablished) {
        currentProjectId = state.currentUserRoleInfo.currentProjectId;
        targetProjectName = state.availableProjects
            .firstWhere(
              (p) => p.projectId == targetProjectId,
              orElse: () => state.currentProject,
            )
            .projectName;
      }

      if (currentProjectId != null && currentProjectId != targetProjectId) {
        final confirmed = await showDialog<bool>(
          context: ctx,
          builder: (dCtx) {
            return AlertDialog(
              title: const Text('切换项目'),
              content: Text(
                '即将切换到项目“${targetProjectName ?? targetProjectId}”，是否继续？',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dCtx).pop(false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dCtx).pop(true),
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );

        if (confirmed != true) {
          return null; // 用户取消
        }
        if (ctx.mounted) {
          // 切换项目 Loading 蒙层
          // await showDialog<void>(
          //   context: ctx,
          //   barrierDismissible: false,
          //   builder: (_) => const Center(child: CircularProgressIndicator()),
          // );

          bool switched = false;
          Object? switchError;
          try {
            session.add(
              SessionSelectProjectWithPendingNavigation(
                projectId: targetProjectId,
                pendingTodoRecord: TodoRecordItem(TodoTask.fromJson(meta)),
              ),
            );
            // session.add(SessionSelectProject(projectId: targetProjectId));
            // 轮询 SessionBloc.state 直到切换成功或超时
            final start = DateTime.now();
            while (DateTime.now().difference(start) <
                const Duration(seconds: 8)) {
              final s = session.state;
              if (s is SessionProjectEstablished &&
                  s.currentUserRoleInfo.currentProjectId == targetProjectId) {
                switched = true;
                break;
              }
              await Future.delayed(const Duration(milliseconds: 120));
            }
          } catch (e) {
            switchError = e;
          } finally {
            // // 关闭 Loading（用同一 ctx 的 Navigator）
            // if (Navigator.of(ctx).canPop()) {
            //   Navigator.of(ctx).pop();
            // }
          }

          if (!switched && ctx.mounted) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(
                  '切换项目失败${switchError != null ? ': $switchError' : ''}',
                ),
              ),
            );
            return false;
          }
        }
      }
    }

    if (ctx.mounted) {
      switch (subtype) {
        case TodoSubtype.acceptConfirm:
          GoRouter.of(ctx).goNamed(
            'acceptance-confirmation',
            queryParameters: {'id': idValue},
          );
          return true;
        case TodoSubtype.acceptAfterSignin:
          GoRouter.of(ctx).goNamed(
            'acceptance-after-signin',
            queryParameters: {'id': idValue},
          );
          return true;
        case TodoSubtype.outboundConfirm:
          GoRouter.of(
            ctx,
          ).goNamed('signout-audit', queryParameters: {'id': idValue});
          return true;
        case TodoSubtype.outboundInstall:
          GoRouter.of(ctx).goNamed('install', queryParameters: {'id': idValue});
          return true;
        case TodoSubtype.transferConfirm:
          GoRouter.of(
            ctx,
          ).goNamed('dispatch-confirmation', queryParameters: {'id': idValue});
          return true;
        case TodoSubtype.transferAfterSignin:
          GoRouter.of(
            ctx,
          ).goNamed('dispatch-after-signin', queryParameters: {'id': idValue});
          return true;
        case TodoSubtype.unknown:
          return openTodoListFallback();
      }
    } else {
      return null;
    }
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
