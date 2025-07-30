/*
 * @Author: LeeZB
 * @Date: 2025-07-29 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-29 19:42:50
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/records/record_item.dart';
import '../../repositories/interfaces/auth_repository.dart';
import '../../models/user/wx_login_vo.dart';
import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final AuthRepository _authRepository;
  int? _pendingProjectId;
  WxLoginVO? _cachedWxLoginVO;
  TodoRecordItem? _pendingTodoRecord;

  SessionBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const SessionInitial()) {
    on<SessionInitializeRequested>(_onInitializeRequested);
    on<SessionSelectProjectParticipant>(_onSelectProjectParticipant);
    on<SessionSelectStorekeeper>(_onSelectStorekeeper);
    on<SessionProjectSelected>(_onProjectSelected);
    on<SessionSelectProject>(_onSelectProject);
    on<SessionSwitchToProjectParticipant>(_onSwitchToProjectParticipant);
    on<SessionSelectProjectWithPendingNavigation>(
      _onSelectProjectWithPendingNavigation,
    );
    on<SessionClearPendingNavigation>(_onClearPendingNavigation);
    on<SessionClearRequested>(_onClearRequested);
    on<SessionReloadRequested>(_onReloadRequested);
  }

  /// 初始化会话
  Future<void> _onInitializeRequested(
    SessionInitializeRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      final wxLoginVO = event.wxLoginVO;

      if (wxLoginVO == null) {
        emit(const SessionError(error: '用户登录信息不存在'));
        return;
      }

      _cachedWxLoginVO = wxLoginVO;

      if (wxLoginVO.storekeeper == true) {
        emit(SessionIdentitySelectionRequired(wxLoginVO: wxLoginVO));
        return;
      }

      final availableProjects = wxLoginVO.projectInfos;
      if (availableProjects.isEmpty) {
        emit(SessionNoProjectsAvailable(wxLoginVO: wxLoginVO));
        return;
      }

      final isFirstLogin = await _authRepository.isFirstLogin();
      if (isFirstLogin) {
        emit(
          SessionProjectSelectionRequired(
            wxLoginVO: wxLoginVO,
            availableProjects: availableProjects,
          ),
        );
        return;
      }

      final lastSelectedProjectId = await _authRepository
          .getLastSelectedProjectId();
      if (lastSelectedProjectId != null) {
        final projectId = int.tryParse(lastSelectedProjectId);
        if (projectId != null) {
          final hasValidProject = availableProjects.any(
            (project) => project.projectId == projectId,
          );

          if (hasValidProject) {
            add(SessionProjectSelected(projectId: projectId));
            return;
          }
        }
      }

      emit(
        SessionProjectSelectionRequired(
          wxLoginVO: wxLoginVO,
          availableProjects: availableProjects,
        ),
      );
    } catch (e) {
      emit(SessionError(error: e.toString()));
    }
  }

  /// 选择项目参与方身份
  Future<void> _onSelectProjectParticipant(
    SessionSelectProjectParticipant event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;

    if (currentState is SessionIdentitySelectionRequired ||
        currentState is SessionStorekeeperEstablished) {
      // 根据当前状态决定加载方式
      if (currentState is SessionStorekeeperEstablished) {
        // 场景1：已在主界面，进行角色切换。使用非破坏性加载。
        emit(currentState.copyWith(isSwitching: true));
      } else {
        // 场景2：在身份选择页，即将进入主流程。使用全屏加载。
        emit(const SessionLoading());
      }

      try {
        _pendingProjectId = event.pendingProjectId;
        _pendingTodoRecord = event.pendingTodoRecord;

        WxLoginVO wxLoginVO;
        if (currentState is SessionIdentitySelectionRequired) {
          wxLoginVO = currentState.wxLoginVO;
        } else {
          // 此时 currentState 必为 SessionStorekeeperEstablished
          wxLoginVO = (currentState as SessionStorekeeperEstablished).wxLoginVO;
        }

        _cachedWxLoginVO = wxLoginVO;
        final availableProjects = wxLoginVO.projectInfos;

        if (availableProjects.isEmpty) {
          emit(SessionNoProjectsAvailable(wxLoginVO: wxLoginVO));
          return;
        }

        if (_pendingProjectId != null) {
          if (_pendingTodoRecord != null) {
            add(
              SessionSelectProjectWithPendingNavigation(
                projectId: _pendingProjectId!,
                pendingTodoRecord: _pendingTodoRecord!,
              ),
            );
          } else {
            add(SessionProjectSelected(projectId: _pendingProjectId!));
          }
          return;
        }

        emit(
          SessionProjectSelectionRequired(
            wxLoginVO: wxLoginVO,
            availableProjects: availableProjects,
          ),
        );
      } catch (e) {
        emit(SessionError(error: e.toString()));
      }
    }
  }

  /// 选择独立仓管员身份
  Future<void> _onSelectStorekeeper(
    SessionSelectStorekeeper event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is SessionIdentitySelectionRequired) {
      emit(SessionStorekeeperEstablished(wxLoginVO: currentState.wxLoginVO));
    }
  }

  /// 项目选择完成
  Future<void> _onProjectSelected(
    SessionProjectSelected event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionLoading());
    try {
      final result = await _authRepository.selectProject(event.projectId);

      if (result.isSuccess) {
        final wxLoginVO = _cachedWxLoginVO;

        if (wxLoginVO != null) {
          emit(
            SessionProjectEstablished(
              wxLoginVO: wxLoginVO,
              currentUserRoleInfo: result.data!,
            ),
          );
          _pendingProjectId = null;
        } else {
          emit(const SessionError(error: '无法获取用户登录信息'));
        }
      } else {
        emit(SessionError(error: result.msg));
      }
    } catch (e) {
      emit(SessionError(error: e.toString()));
    }
  }

  /// 选择项目 (别名，转发给SessionProjectSelected)
  Future<void> _onSelectProject(
    SessionSelectProject event,
    Emitter<SessionState> emit,
  ) async {
    add(SessionProjectSelected(projectId: event.projectId));
  }

  /// 从仓管员身份切换为项目参与方
  Future<void> _onSwitchToProjectParticipant(
    SessionSwitchToProjectParticipant event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is SessionStorekeeperEstablished) {
      add(SessionSelectProjectParticipant(pendingProjectId: event.projectId));
    }
  }

  /// 选择项目并携带待处理的导航信息
  Future<void> _onSelectProjectWithPendingNavigation(
    SessionSelectProjectWithPendingNavigation event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;

    if (currentState is SessionProjectEstablished) {
      emit(currentState.copyWith(isSwitching: true));
    } else if (currentState is SessionStorekeeperEstablished) {
      emit(currentState.copyWith(isSwitching: true));
    }

    try {
      final result = await _authRepository.selectProject(event.projectId);

      if (result.isSuccess) {
        final wxLoginVO = _cachedWxLoginVO;

        if (wxLoginVO != null) {
          emit(
            SessionProjectEstablished(
              wxLoginVO: wxLoginVO,
              currentUserRoleInfo: result.data!,
              pendingTodoRecord: event.pendingTodoRecord,
            ),
          );
          _pendingProjectId = null;
        } else {
          emit(const SessionError(error: '无法获取用户登录信息'));
        }
      } else {
        emit(SessionError(error: result.msg));
      }
    } catch (e) {
      emit(SessionError(error: e.toString()));
    }
  }

  /// 清除待处理的导航信息
  Future<void> _onClearPendingNavigation(
    SessionClearPendingNavigation event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is SessionProjectEstablished) {
      emit(currentState.copyWith(clearPendingTodo: true));
    }
  }

  /// 清除会话数据
  Future<void> _onClearRequested(
    SessionClearRequested event,
    Emitter<SessionState> emit,
  ) async {
    _pendingProjectId = null;
    _cachedWxLoginVO = null;
    _pendingTodoRecord = null;
    emit(const SessionInitial());
  }

  /// 重新加载会话
  Future<void> _onReloadRequested(
    SessionReloadRequested event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is SessionProjectEstablished) {
      add(SessionInitializeRequested(wxLoginVO: currentState.wxLoginVO));
    } else if (currentState is SessionStorekeeperEstablished) {
      add(SessionInitializeRequested(wxLoginVO: currentState.wxLoginVO));
    } else if (currentState is SessionProjectSelectionRequired) {
      add(SessionInitializeRequested(wxLoginVO: currentState.wxLoginVO));
    } else if (currentState is SessionIdentitySelectionRequired) {
      add(SessionInitializeRequested(wxLoginVO: currentState.wxLoginVO));
    }
  }
}
