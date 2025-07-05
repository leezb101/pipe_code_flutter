/*
 * @Author: LeeZB
 * @Date: 2025-07-01 18:40:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-01 18:40:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/project_repository.dart';
import '../../repositories/user_repository.dart';
import '../../models/user/user_project_role.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository _projectRepository;
  final UserRepository _userRepository;

  ProjectBloc({
    required ProjectRepository projectRepository,
    required UserRepository userRepository,
  }) : _projectRepository = projectRepository,
       _userRepository = userRepository,
       super(const ProjectInitial()) {
    on<ProjectLoadUserContext>(_onLoadUserContext);
    on<ProjectSwitchProject>(_onSwitchProject);
    on<ProjectSetContext>(_onSetContext);
    on<ProjectRefreshUserRoles>(_onRefreshUserRoles);
    on<ProjectUpdateUserRole>(_onUpdateUserRole);
    on<ProjectClearData>(_onClearData);
  }

  /// 加载用户项目上下文
  Future<void> _onLoadUserContext(
    ProjectLoadUserContext event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());
    try {
      // 首先获取用户信息
      final user = await _userRepository.loadUserFromStorage();
      if (user == null) {
        emit(const ProjectError(error: '用户未登录，无法加载项目信息'));
        return;
      }

      // 尝试从缓存或存储加载项目上下文
      UserProjectContext? context;
      try {
        context = await _projectRepository.loadUserProjectContext(event.userId);
      } catch (e) {
        // 如果加载失败，尝试重新构建
        context = await _projectRepository.buildUserProjectContext(user);
      }

      if (context != null) {
        emit(ProjectContextLoaded(context: context));
      } else {
        emit(const ProjectEmpty(message: '您还没有被分配到任何项目'));
      }
    } catch (e) {
      emit(ProjectError(error: e.toString()));
    }
  }

  /// 切换项目
  Future<void> _onSwitchProject(
    ProjectSwitchProject event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProjectContextLoaded) {
      emit(const ProjectError(error: '当前状态不支持项目切换'));
      return;
    }

    if (!currentState.canSwitchToProject(event.projectId)) {
      emit(const ProjectError(error: '您没有在该项目中的权限'));
      return;
    }

    emit(ProjectSwitching(targetProjectId: event.projectId));
    
    try {
      final newContext = await _projectRepository.switchToProject(event.projectId);
      if (newContext != null) {
        emit(ProjectContextLoaded(context: newContext));
      } else {
        emit(const ProjectError(error: '项目切换失败'));
      }
    } catch (e) {
      emit(ProjectError(error: e.toString()));
    }
  }

  /// 设置项目上下文
  Future<void> _onSetContext(
    ProjectSetContext event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _projectRepository.saveUserProjectContext(event.context);
      emit(ProjectContextLoaded(context: event.context));
    } catch (e) {
      emit(ProjectError(error: e.toString()));
    }
  }

  /// 刷新用户项目角色
  Future<void> _onRefreshUserRoles(
    ProjectRefreshUserRoles event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());
    try {
      final user = await _userRepository.loadUserFromStorage();
      if (user == null) {
        emit(const ProjectError(error: '用户未登录，无法刷新项目信息'));
        return;
      }

      final refreshedContext = await _projectRepository.refreshUserProjectRoles(event.userId);
      if (refreshedContext != null) {
        emit(ProjectContextLoaded(context: refreshedContext));
      } else {
        // 尝试重新构建项目上下文
        final newContext = await _projectRepository.buildUserProjectContext(user);
        if (newContext != null) {
          emit(ProjectContextLoaded(context: newContext));
        } else {
          emit(const ProjectEmpty(message: '您还没有被分配到任何项目'));
        }
      }
    } catch (e) {
      emit(ProjectError(error: e.toString()));
    }
  }

  /// 更新用户在项目中的角色
  Future<void> _onUpdateUserRole(
    ProjectUpdateUserRole event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _projectRepository.updateUserProjectRole(event.projectId, event.role);
      
      // 如果更新的是当前项目的角色，则重新加载上下文
      final currentState = state;
      if (currentState is ProjectContextLoaded && 
          event.projectId == currentState.currentProject.id) {
        add(ProjectRefreshUserRoles(userId: currentState.context.user.id));
      }
    } catch (e) {
      emit(ProjectError(error: e.toString()));
    }
  }

  /// 清除项目数据
  Future<void> _onClearData(
    ProjectClearData event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _projectRepository.clearProjectData();
      emit(const ProjectInitial());
    } catch (e) {
      emit(ProjectError(error: e.toString()));
    }
  }
}