/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:40:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 23:40:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import '../../models/user/wx_login_vo.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final AuthRepository _authRepository;

  ProjectBloc({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository,
       super(const ProjectInitial()) {
    on<ProjectLoadUserProjects>(_onLoadUserProjects);
    on<ProjectSelectProject>(_onSelectProject);
    on<ProjectSetCurrentRoleInfo>(_onSetCurrentRoleInfo);
    on<ProjectClearData>(_onClearData);
  }

  /// 加载用户项目列表
  Future<void> _onLoadUserProjects(
    ProjectLoadUserProjects event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());
    try {
      // 发射项目列表已加载状态
      emit(ProjectListLoaded(
        wxLoginVO: event.wxLoginVO,
        availableProjects: event.wxLoginVO.projectInfos,
      ));
      
      // 执行智能项目选择逻辑
      await smartProjectSelection(
        event.wxLoginVO.id,
        event.wxLoginVO.projectInfos,
        emit,
      );
    } catch (e) {
      emit(ProjectError(message: '加载项目列表失败: ${e.toString()}'));
    }
  }

  /// 选择项目
  Future<void> _onSelectProject(
    ProjectSelectProject event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    
    // 支持从项目列表加载状态和项目角色信息加载状态进行项目切换
    if (currentState is ProjectListLoaded || currentState is ProjectRoleInfoLoaded) {
      emit(const ProjectLoading());
      try {
        final result = await _authRepository.selectProject(event.projectId);
        if (result.isSuccess) {
          // 获取wxLoginVO，优先从当前状态获取
          WxLoginVO wxLoginVO;
          if (currentState is ProjectListLoaded) {
            wxLoginVO = currentState.wxLoginVO;
          } else if (currentState is ProjectRoleInfoLoaded) {
            wxLoginVO = currentState.wxLoginVO;
          } else {
            throw Exception('无法获取用户登录信息');
          }
          
          emit(ProjectRoleInfoLoaded(
            wxLoginVO: wxLoginVO,
            currentUserRoleInfo: result.data!,
          ));
        } else {
          emit(ProjectError(message: result.msg));
        }
      } catch (e) {
        emit(ProjectError(message: '选择项目失败: ${e.toString()}'));
      }
    }
  }

  /// 设置当前项目角色信息
  Future<void> _onSetCurrentRoleInfo(
    ProjectSetCurrentRoleInfo event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectRoleInfoLoaded(
      wxLoginVO: event.wxLoginVO,
      currentUserRoleInfo: event.currentUserRoleInfo,
    ));
  }

  /// 清除项目数据
  Future<void> _onClearData(
    ProjectClearData event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectInitial());
  }

  /// 智能项目选择逻辑
  Future<void> smartProjectSelection(
    String userId,
    List<dynamic> projectInfos,
    Emitter<ProjectState> emit,
  ) async {
    if (projectInfos.isEmpty) {
      emit(const ProjectEmpty());
      return;
    }

    // 检查是否为首次登录
    final isFirstLogin = await _authRepository.isFirstLogin();
    
    if (isFirstLogin) {
      // 首次登录，让用户选择项目
      // 这里应该显示项目选择界面
      return;
    }

    // 非首次登录，尝试使用最后选择的项目
    final lastSelectedProjectId = await _authRepository.getLastSelectedProjectId();
    if (lastSelectedProjectId != null) {
      final projectId = int.tryParse(lastSelectedProjectId);
      if (projectId != null) {
        // 验证项目ID是否在用户的可用项目列表中
        final hasValidProject = projectInfos.any((project) {
          final projectCode = project.projectCode as String?;
          if (projectCode != null) {
            final extractedId = int.tryParse(projectCode.replaceAll(RegExp(r'[^0-9]'), ''));
            return extractedId == projectId;
          }
          return false;
        });
        
        if (hasValidProject) {
          // 自动选择最后选择的项目
          add(ProjectSelectProject(projectId: projectId));
        }
        // 如果项目不在可用列表中，保持ProjectListLoaded状态，让用户重新选择
      }
    }
  }
}