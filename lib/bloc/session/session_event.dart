/*
 * @Author: LeeZB
 * @Date: 2025-07-29 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import '../../models/user/wx_login_vo.dart';
import '../../models/records/record_item.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化会话 - 从认证状态开始
class SessionInitializeRequested extends SessionEvent {
  const SessionInitializeRequested({this.wxLoginVO});

  final WxLoginVO? wxLoginVO;

  @override
  List<Object?> get props => [wxLoginVO];
}

/// 选择项目参与方身份
class SessionSelectProjectParticipant extends SessionEvent {
  const SessionSelectProjectParticipant({
    this.pendingProjectId,
    this.pendingTodoRecord,
  });

  /// 可选的预选项目ID，用于从仓管员身份切换到项目参与方时直接选择项目
  final int? pendingProjectId;

  /// 可选的待处理todo记录，用于切换完成后导航
  final TodoRecordItem? pendingTodoRecord;

  @override
  List<Object?> get props => [pendingProjectId, pendingTodoRecord];
}

/// 选择独立仓管员身份
class SessionSelectStorekeeper extends SessionEvent {
  const SessionSelectStorekeeper();
}

/// 项目选择完成
class SessionProjectSelected extends SessionEvent {
  const SessionProjectSelected({required this.projectId});

  final int projectId;

  @override
  List<Object> get props => [projectId];
}

/// 选择项目 (别名)
class SessionSelectProject extends SessionEvent {
  const SessionSelectProject({required this.projectId});

  final int projectId;

  @override
  List<Object> get props => [projectId];
}

/// 从仓管员身份切换为项目参与方
class SessionSwitchToProjectParticipant extends SessionEvent {
  const SessionSwitchToProjectParticipant({required this.projectId});

  final int projectId;

  @override
  List<Object> get props => [projectId];
}

/// 清除会话数据
class SessionClearRequested extends SessionEvent {
  const SessionClearRequested();
}

/// 重新加载会话
class SessionReloadRequested extends SessionEvent {
  const SessionReloadRequested();
}

/// 选择项目并携带待处理的导航信息
class SessionSelectProjectWithPendingNavigation extends SessionEvent {
  const SessionSelectProjectWithPendingNavigation({
    required this.projectId,
    required this.pendingTodoRecord,
  });

  final int projectId;
  final TodoRecordItem pendingTodoRecord;

  @override
  List<Object> get props => [projectId, pendingTodoRecord];
}

/// 清除待处理的导航信息
class SessionClearPendingNavigation extends SessionEvent {
  const SessionClearPendingNavigation();
}
