/*
 * @Author: LeeZB
 * @Date: 2025-09-09 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-09 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/services/api/interfaces/map_api_service.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_user.dart';
import 'project_users_event.dart';
import 'project_users_state.dart';

/// 项目用户列表页面BLoC
class ProjectUsersBloc extends Bloc<ProjectUsersEvent, ProjectUsersState> {
  final MapApiService _mapApiService;

  ProjectUsersBloc({required MapApiService mapApiService})
    : _mapApiService = mapApiService,
      super(const ProjectUsersState()) {
    on<LoadProjectUsers>(_onLoadProjectUsers);
    on<RefreshProjectUsers>(_onRefreshProjectUsers);
    on<ClearUsersErrorMessage>(_onClearUsersErrorMessage);
  }

  /// 加载项目用户列表
  Future<void> _onLoadProjectUsers(
    LoadProjectUsers event,
    Emitter<ProjectUsersState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProjectUsersStatus.loading,
        projectId: event.projectId,
        code: event.code,
        orgName: event.orgName,
        errorMessage: null,
      ),
    );

    try {
      final result = await _mapApiService.fetchMapProjectUsers(
        event.projectId,
        event.code,
      );

      if (result.isSuccess && result.data != null) {
        emit(
          state.copyWith(
            status: ProjectUsersStatus.loaded,
            users: result.data as List<MapProjectUser>,
          ),
        );
        print('项目用户列表加载成功 - 项目ID: ${event.projectId}, 代码: ${event.code}');
      } else {
        emit(
          state.copyWith(
            status: ProjectUsersStatus.error,
            errorMessage: result.msg,
          ),
        );
        print('项目用户列表加载失败 - 项目ID: ${event.projectId}, 错误: ${result.msg}');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProjectUsersStatus.error,
          errorMessage: '加载用户列表时发生异常: $e',
        ),
      );
      print('项目用户列表加载异常: $e');
    }
  }

  /// 刷新项目用户列表
  Future<void> _onRefreshProjectUsers(
    RefreshProjectUsers event,
    Emitter<ProjectUsersState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProjectUsersStatus.refreshing,
        projectId: event.projectId,
        code: event.code,
        orgName: event.orgName,
        errorMessage: null,
      ),
    );

    try {
      final result = await _mapApiService.fetchMapProjectUsers(
        event.projectId,
        event.code,
      );

      if (result.isSuccess && result.data != null) {
        emit(
          state.copyWith(
            status: ProjectUsersStatus.loaded,
            users: result.data as List<MapProjectUser>,
          ),
        );
        print('项目用户列表刷新成功 - 项目ID: ${event.projectId}, 代码: ${event.code}');
      } else {
        emit(
          state.copyWith(
            status: ProjectUsersStatus.error,
            errorMessage: result.msg,
          ),
        );
        print('项目用户列表刷新失败 - 项目ID: ${event.projectId}, 错误: ${result.msg}');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProjectUsersStatus.error,
          errorMessage: '刷新用户列表时发生异常: $e',
        ),
      );
      print('项目用户列表刷新异常: $e');
    }
  }

  /// 清除错误消息
  void _onClearUsersErrorMessage(
    ClearUsersErrorMessage event,
    Emitter<ProjectUsersState> emit,
  ) {
    emit(state.clearError());
  }
}
