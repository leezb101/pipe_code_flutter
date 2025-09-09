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
import 'project_detail_event.dart';
import 'project_detail_state.dart';

/// 项目详情页面BLoC
class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  final MapApiService _mapApiService;

  ProjectDetailBloc({required MapApiService mapApiService})
    : _mapApiService = mapApiService,
      super(const ProjectDetailState()) {
    on<LoadProjectDetail>(_onLoadProjectDetail);
    on<RefreshProjectDetail>(_onRefreshProjectDetail);
    on<ClearErrorMessage>(_onClearErrorMessage);
  }

  /// 加载项目详情
  Future<void> _onLoadProjectDetail(
    LoadProjectDetail event,
    Emitter<ProjectDetailState> emit,
  ) async {
    // 设置项目ID和所有接口为加载状态
    emit(
      state.copyWith(
        projectId: event.projectId,
        projectBaseStatus: ApiStatus.loading,
        projectStatisticStatus: ApiStatus.loading,
        materialStatisticsStatus: ApiStatus.loading,
        projectBaseError: null,
        projectStatisticError: null,
        materialStatisticsError: null,
      ),
    );

    // 并行调用三个接口，每个独立处理结果
    final futures = [
      _loadProjectBase(event.projectId, emit),
      _loadProjectStatistic(event.projectId, emit),
      _loadMaterialStatistics(event.projectId, emit),
    ];

    await Future.wait(futures);
    print('项目详情加载完成 - 项目ID: ${event.projectId}');
  }

  /// 加载项目基础信息
  Future<void> _loadProjectBase(
    int projectId,
    Emitter<ProjectDetailState> emit,
  ) async {
    try {
      final result = await _mapApiService.fetchMapProjectBase(projectId);

      if (result.isSuccess) {
        emit(
          state.copyWith(
            projectBaseStatus: ApiStatus.loaded,
            projectBase: result.data,
          ),
        );
        print('项目基础信息加载成功');
      } else {
        emit(
          state.copyWith(
            projectBaseStatus: ApiStatus.error,
            projectBaseError: result.msg,
          ),
        );
        print('项目基础信息加载失败: ${result.msg}');
      }
    } catch (e) {
      emit(
        state.copyWith(
          projectBaseStatus: ApiStatus.error,
          projectBaseError: '加载项目基础信息时发生异常: $e',
        ),
      );
      print('项目基础信息加载异常: $e');
    }
  }

  /// 加载项目统计信息
  Future<void> _loadProjectStatistic(
    int projectId,
    Emitter<ProjectDetailState> emit,
  ) async {
    try {
      final result = await _mapApiService.fetchMapProjectStatistic(projectId);

      if (result.isSuccess) {
        emit(
          state.copyWith(
            projectStatisticStatus: ApiStatus.loaded,
            projectStatistic: result.data,
          ),
        );
        print('项目统计信息加载成功');
      } else {
        emit(
          state.copyWith(
            projectStatisticStatus: ApiStatus.error,
            projectStatisticError: result.msg,
          ),
        );
        print('项目统计信息加载失败: ${result.msg}');
      }
    } catch (e) {
      emit(
        state.copyWith(
          projectStatisticStatus: ApiStatus.error,
          projectStatisticError: '加载项目统计信息时发生异常: $e',
        ),
      );
      print('项目统计信息加载异常: $e');
    }
  }

  /// 加载材料统计信息
  Future<void> _loadMaterialStatistics(
    int projectId,
    Emitter<ProjectDetailState> emit,
  ) async {
    try {
      final result = await _mapApiService.fetchMapProjectMaterialStatistics(
        projectId,
      );

      if (result.isSuccess) {
        emit(
          state.copyWith(
            materialStatisticsStatus: ApiStatus.loaded,
            materialStatistics: result.data ?? [],
          ),
        );
        print('材料统计信息加载成功');
      } else {
        emit(
          state.copyWith(
            materialStatisticsStatus: ApiStatus.error,
            materialStatisticsError: result.msg,
          ),
        );
        print('材料统计信息加载失败: ${result.msg}');
      }
    } catch (e) {
      emit(
        state.copyWith(
          materialStatisticsStatus: ApiStatus.error,
          materialStatisticsError: '加载材料统计信息时发生异常: $e',
        ),
      );
      print('材料统计信息加载异常: $e');
    }
  }

  /// 刷新项目详情
  Future<void> _onRefreshProjectDetail(
    RefreshProjectDetail event,
    Emitter<ProjectDetailState> emit,
  ) async {
    // 设置项目ID，对于已经有数据的接口，只清除错误状态，没有数据的设置为loading状态
    emit(
      state.copyWith(
        projectId: event.projectId,
        projectBaseStatus: state.projectBase != null
            ? state.projectBaseStatus
            : ApiStatus.loading,
        projectStatisticStatus: state.projectStatistic != null
            ? state.projectStatisticStatus
            : ApiStatus.loading,
        materialStatisticsStatus: state.materialStatistics.isNotEmpty
            ? state.materialStatisticsStatus
            : ApiStatus.loading,
        projectBaseError: null,
        projectStatisticError: null,
        materialStatisticsError: null,
      ),
    );

    // 并行调用三个接口，每个独立处理结果
    final futures = [
      _loadProjectBase(event.projectId, emit),
      _loadProjectStatistic(event.projectId, emit),
      _loadMaterialStatistics(event.projectId, emit),
    ];

    await Future.wait(futures);
    print('项目详情刷新完成 - 项目ID: ${event.projectId}');
  }

  /// 清除错误消息
  void _onClearErrorMessage(
    ClearErrorMessage event,
    Emitter<ProjectDetailState> emit,
  ) {
    emit(
      state.copyWith(
        projectBaseError: null,
        projectStatisticError: null,
        materialStatisticsError: null,
      ),
    );
  }
}
