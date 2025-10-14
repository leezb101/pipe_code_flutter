/*
 * @Author: LeeZB
 * @Date: 2025-07-29 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-29 19:42:50
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../models/records/record_item.dart';
import '../../repositories/interfaces/auth_repository.dart';
import '../../repositories/interfaces/project_repository.dart';
import '../../models/user/wx_login_vo.dart';
import '../../services/notification/notification_manager.dart';
import '../../services/tracing/improved_tracing_manager.dart';
import '../../utils/logger.dart';
import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final AuthRepository _authRepository;
  final ProjectRepository _projectRepository;
  int? _pendingProjectId;
  WxLoginVO? _cachedWxLoginVO;
  TodoRecordItem? _pendingTodoRecord;

  // 用于追踪上一个状态，以便从错误状态回退
  SessionState? _previousState;

  SessionBloc({
    required AuthRepository authRepository,
    required ProjectRepository projectRepository,
  }) : _authRepository = authRepository,
       _projectRepository = projectRepository,
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
    on<SessionLoadProjectDisplayInfo>(_onLoadProjectDisplayInfo);
    on<SessionGoBackFromError>(_onGoBackFromError);
  }

  /// 初始化会话
  Future<void> _onInitializeRequested(
    SessionInitializeRequested event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    _previousState = currentState is! SessionError
        ? currentState
        : _previousState;

    emit(const SessionLoading());
    try {
      final wxLoginVO = event.wxLoginVO;

      if (wxLoginVO == null) {
        emit(const SessionError(error: '用户登录信息不存在'));
        return;
      }

      _cachedWxLoginVO = wxLoginVO;

      // 检查是否为管理方用户 (admin 或 boss)
      if (wxLoginVO.admin == true || wxLoginVO.boss == true) {
        Logger.debug(
          '检测到管理方用户: admin=${wxLoginVO.admin}, boss=${wxLoginVO.boss}',
        );
        _previousState = null; // 成功建立会话，清除上一个状态
        emit(SessionAdminEstablished(wxLoginVO: wxLoginVO));
        return;
      }

      if (wxLoginVO.storekeeper == true) {
        _previousState = null;
        emit(SessionIdentitySelectionRequired(wxLoginVO: wxLoginVO));
        return;
      }

      final availableProjects = wxLoginVO.projectInfos;
      if (availableProjects.isEmpty) {
        _previousState = null;
        emit(SessionNoProjectsAvailable(wxLoginVO: wxLoginVO));
        return;
      }

      final isFirstLogin = await _authRepository.isFirstLogin();
      if (isFirstLogin) {
        _previousState = null;
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

      _previousState = null;
      emit(
        SessionProjectSelectionRequired(
          wxLoginVO: wxLoginVO,
          availableProjects: availableProjects,
        ),
      );
    } catch (e) {
      emit(
        SessionError(
          error: e.toString(),
          previousStateType: _previousState?.runtimeType,
          wxLoginVO: _cachedWxLoginVO,
          availableProjects: _cachedWxLoginVO?.projectInfos ?? [],
        ),
      );
    }
  }

  /// 选择项目参与方身份
  Future<void> _onSelectProjectParticipant(
    SessionSelectProjectParticipant event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    _previousState = currentState is! SessionError
        ? currentState
        : _previousState;

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
          _previousState = null;
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

        // 尝试按上次选择自动进入项目（与非仓管登录流程保持一致）
        final lastSelectedProjectId = await _authRepository
            .getLastSelectedProjectId();
        if (lastSelectedProjectId != null) {
          final projectId = int.tryParse(lastSelectedProjectId);
          if (projectId != null) {
            final hasValidProject = availableProjects.any(
              (project) => project.projectId == projectId,
            );

            if (hasValidProject) {
              if (_pendingTodoRecord != null) {
                add(
                  SessionSelectProjectWithPendingNavigation(
                    projectId: projectId,
                    pendingTodoRecord: _pendingTodoRecord!,
                  ),
                );
              } else {
                add(SessionProjectSelected(projectId: projectId));
              }
              return;
            }
          }
        }

        // 未命中自动进入，进入项目选择页
        _previousState = null;
        emit(
          SessionProjectSelectionRequired(
            wxLoginVO: wxLoginVO,
            availableProjects: availableProjects,
          ),
        );
      } catch (e) {
        emit(
          SessionError(
            error: e.toString(),
            previousStateType: _previousState?.runtimeType,
            wxLoginVO: _cachedWxLoginVO,
            availableProjects: _cachedWxLoginVO?.projectInfos ?? [],
          ),
        );
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
      _previousState = null;
      emit(SessionStorekeeperEstablished(wxLoginVO: currentState.wxLoginVO));
    }
  }

  /// 项目选择完成
  Future<void> _onProjectSelected(
    SessionProjectSelected event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    _previousState = currentState is! SessionError
        ? currentState
        : _previousState;

    emit(const SessionLoading());
    try {
      final result = await GetIt.instance<ImprovedTracingManager>()
          .scopeActionWithTitle('自动选择项目', () async {
            return await _authRepository.selectProject(event.projectId);
          });

      if (result.isSuccess) {
        final wxLoginVO = _cachedWxLoginVO;

        if (wxLoginVO != null) {
          final projectEstablishedState = SessionProjectEstablished(
            wxLoginVO: wxLoginVO,
            currentUserRoleInfo: result.data!,
          );
          _previousState = null; // 成功建立会话，清除上一个状态
          emit(projectEstablishedState);
          _pendingProjectId = null;

          // 启动通知系统 (仅当用户为自有人员时)
          if (wxLoginVO.own) {
            _startNotificationSystem(wxLoginVO);
          }

          // 自动加载统计信息
          add(const SessionLoadProjectDisplayInfo());
        } else {
          emit(
            SessionError(
              error: '无法获取用户登录信息',
              previousStateType: _previousState?.runtimeType,
              wxLoginVO: _cachedWxLoginVO,
              availableProjects: _cachedWxLoginVO?.projectInfos ?? [],
            ),
          );
        }
      } else {
        // 项目选择失败，标记为自动选择项目失败
        emit(
          SessionError(
            error: result.msg,
            previousStateType: _previousState?.runtimeType,
            wxLoginVO: _cachedWxLoginVO,
            availableProjects: _cachedWxLoginVO?.projectInfos ?? [],
            wasAutoSelectingProject: true, // 标记这是自动选择项目失败
          ),
        );
      }
    } catch (e) {
      emit(
        SessionError(
          error: e.toString(),
          previousStateType: _previousState?.runtimeType,
          wxLoginVO: _cachedWxLoginVO,
          availableProjects: _cachedWxLoginVO?.projectInfos ?? [],
          wasAutoSelectingProject: true,
        ),
      );
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
    _previousState = currentState is! SessionError
        ? currentState
        : _previousState;

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
          final projectEstablishedState = SessionProjectEstablished(
            wxLoginVO: wxLoginVO,
            currentUserRoleInfo: result.data!,
            pendingTodoRecord: event.pendingTodoRecord,
          );
          _previousState = null;
          emit(projectEstablishedState);
          _pendingProjectId = null;

          // 自动加载统计信息
          add(const SessionLoadProjectDisplayInfo());
        } else {
          emit(
            SessionError(
              error: '无法获取用户登录信息',
              previousStateType: _previousState?.runtimeType,
              wxLoginVO: _cachedWxLoginVO,
              availableProjects: _cachedWxLoginVO?.projectInfos ?? [],
            ),
          );
        }
      } else {
        emit(
          SessionError(
            error: result.msg,
            previousStateType: _previousState?.runtimeType,
            wxLoginVO: _cachedWxLoginVO,
            availableProjects: _cachedWxLoginVO?.projectInfos ?? [],
            wasAutoSelectingProject: true,
          ),
        );
      }
    } catch (e) {
      emit(
        SessionError(
          error: e.toString(),
          previousStateType: _previousState?.runtimeType,
          wxLoginVO: _cachedWxLoginVO,
          availableProjects: _cachedWxLoginVO?.projectInfos ?? [],
          wasAutoSelectingProject: true,
        ),
      );
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

  /// 启动通知系统
  Future<void> _startNotificationSystem(WxLoginVO wxLoginVO) async {
    try {
      if (wxLoginVO.own) {
        Logger.info(
          'Starting notification system for user: ${wxLoginVO.name}',
          tag: 'SESSION_BLOC',
        );
        final notificationManager = NotificationManager.instance;
        final success = await notificationManager.start();

        if (!success) {
          Logger.warning(
            'Failed to start notification system for user: ${wxLoginVO.name}',
            tag: 'SESSION_BLOC',
          );
        }
      }
    } catch (e) {
      Logger.error(
        'Error starting notification system: ${e.toString()}',
        tag: 'SESSION_BLOC',
      );
    }
  }

  /// 处理加载项目统计信息事件
  Future<void> _onLoadProjectDisplayInfo(
    SessionLoadProjectDisplayInfo event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is SessionProjectEstablished) {
      try {
        final result = await GetIt.instance<ImprovedTracingManager>()
            .scopeActionWithTitle('加载项目统计信息', () async {
              return await _projectRepository.getProjectDisplayInfosForHome();
            });
        if (result.isSuccess && result.data != null) {
          emit(currentState.copyWith(projectDisplayInfo: result.data));
        }
        // 如果失败，不改变状态，保持现有的显示
      } catch (e) {
        // 静默处理错误，不影响主要功能
        Logger.error('加载项目统计信息失败: $e', tag: 'SessionBloc');
      }
    }
  }

  /// 从错误状态返回上一步
  Future<void> _onGoBackFromError(
    SessionGoBackFromError event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SessionError) return;

    // 如果是自动选择项目失败，清除本地缓存的项目ID
    if (currentState.wasAutoSelectingProject) {
      try {
        // 清除项目缓存，防止下次再自动选择同一个失败的项目
        await _projectRepository.clearProjectData();
        Logger.info('已清除自动选择失败的项目缓存', tag: 'SessionBloc');
      } catch (e) {
        Logger.error('清除项目缓存失败: $e', tag: 'SessionBloc');
      }
    }

    final wxLoginVO = currentState.wxLoginVO ?? _cachedWxLoginVO;
    final availableProjects =
        currentState.availableProjects ?? wxLoginVO?.projectInfos ?? [];

    // 根据上一个状态类型决定回退到哪个状态
    if (currentState.previousStateType == SessionIdentitySelectionRequired) {
      // 回退到身份选择页
      if (wxLoginVO != null) {
        emit(SessionIdentitySelectionRequired(wxLoginVO: wxLoginVO));
      } else {
        emit(const SessionError(error: '无法获取用户信息'));
      }
    } else if (currentState.previousStateType ==
        SessionProjectSelectionRequired) {
      // 回退到项目选择页
      if (wxLoginVO != null && availableProjects.isNotEmpty) {
        emit(
          SessionProjectSelectionRequired(
            wxLoginVO: wxLoginVO,
            availableProjects: availableProjects,
          ),
        );
      } else {
        emit(const SessionError(error: '无法获取项目信息'));
      }
    } else if (currentState.previousStateType == SessionLoading) {
      // 如果上一个状态是加载中，尝试回退到项目选择或身份选择
      if (wxLoginVO != null) {
        if (wxLoginVO.storekeeper == true) {
          emit(SessionIdentitySelectionRequired(wxLoginVO: wxLoginVO));
        } else if (availableProjects.isNotEmpty) {
          emit(
            SessionProjectSelectionRequired(
              wxLoginVO: wxLoginVO,
              availableProjects: availableProjects,
            ),
          );
        } else {
          emit(SessionNoProjectsAvailable(wxLoginVO: wxLoginVO));
        }
      }
    } else {
      // 默认回退逻辑：优先回到项目选择页，如果没有项目则回到身份选择页
      if (wxLoginVO != null) {
        if (availableProjects.isNotEmpty) {
          emit(
            SessionProjectSelectionRequired(
              wxLoginVO: wxLoginVO,
              availableProjects: availableProjects,
            ),
          );
        } else if (wxLoginVO.storekeeper == true) {
          emit(SessionIdentitySelectionRequired(wxLoginVO: wxLoginVO));
        } else {
          emit(SessionNoProjectsAvailable(wxLoginVO: wxLoginVO));
        }
      } else {
        emit(const SessionError(error: '无法获取用户信息，请重新登录'));
      }
    }

    _previousState = null; // 清除上一个状态记录
  }
}
