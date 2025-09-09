/*
 * @Author: LeeZB
 * @Date: 2025-09-09 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-09 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_base.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_material_statistic_item.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_statistic.dart';

/// API状态枚举
enum ApiStatus { initial, loading, loaded, error }

/// 项目详情状态
class ProjectDetailState extends Equatable {
  const ProjectDetailState({
    this.projectBaseStatus = ApiStatus.initial,
    this.projectStatisticStatus = ApiStatus.initial,
    this.materialStatisticsStatus = ApiStatus.initial,
    this.projectBase,
    this.projectStatistic,
    this.materialStatistics = const [],
    this.projectBaseError,
    this.projectStatisticError,
    this.materialStatisticsError,
    this.projectId,
  });

  /// 项目基础信息状态
  final ApiStatus projectBaseStatus;

  /// 项目统计信息状态
  final ApiStatus projectStatisticStatus;

  /// 材料统计信息状态
  final ApiStatus materialStatisticsStatus;

  /// 项目基础信息
  final MapProjectBase? projectBase;

  /// 项目统计信息
  final MapProjectStatistic? projectStatistic;

  /// 材料统计列表
  final List<MapProjectMaterialStatisticItem> materialStatistics;

  /// 项目基础信息错误消息
  final String? projectBaseError;

  /// 项目统计信息错误消息
  final String? projectStatisticError;

  /// 材料统计信息错误消息
  final String? materialStatisticsError;

  /// 项目ID
  final int? projectId;

  /// 是否初始加载中（所有API都是initial状态）
  bool get isInitialLoading =>
      projectBaseStatus == ApiStatus.initial &&
      projectStatisticStatus == ApiStatus.initial &&
      materialStatisticsStatus == ApiStatus.initial;

  /// 项目基础信息是否加载中
  bool get isProjectBaseLoading => projectBaseStatus == ApiStatus.loading;

  /// 项目统计信息是否加载中
  bool get isProjectStatisticLoading =>
      projectStatisticStatus == ApiStatus.loading;

  /// 材料统计信息是否加载中
  bool get isMaterialStatisticsLoading =>
      materialStatisticsStatus == ApiStatus.loading;

  /// 是否有任何加载中的状态
  bool get hasAnyLoading =>
      isProjectBaseLoading ||
      isProjectStatisticLoading ||
      isMaterialStatisticsLoading;

  /// 项目基础信息是否有错误
  bool get hasProjectBaseError => projectBaseStatus == ApiStatus.error;

  /// 项目统计信息是否有错误
  bool get hasProjectStatisticError =>
      projectStatisticStatus == ApiStatus.error;

  /// 材料统计信息是否有错误
  bool get hasMaterialStatisticsError =>
      materialStatisticsStatus == ApiStatus.error;

  /// 是否有任何数据（至少一个API成功）
  bool get hasAnyData =>
      projectBase != null ||
      projectStatistic != null ||
      materialStatistics.isNotEmpty;

  /// 复制状态
  ProjectDetailState copyWith({
    ApiStatus? projectBaseStatus,
    ApiStatus? projectStatisticStatus,
    ApiStatus? materialStatisticsStatus,
    MapProjectBase? projectBase,
    MapProjectStatistic? projectStatistic,
    List<MapProjectMaterialStatisticItem>? materialStatistics,
    String? projectBaseError,
    String? projectStatisticError,
    String? materialStatisticsError,
    int? projectId,
  }) {
    return ProjectDetailState(
      projectBaseStatus: projectBaseStatus ?? this.projectBaseStatus,
      projectStatisticStatus:
          projectStatisticStatus ?? this.projectStatisticStatus,
      materialStatisticsStatus:
          materialStatisticsStatus ?? this.materialStatisticsStatus,
      projectBase: projectBase ?? this.projectBase,
      projectStatistic: projectStatistic ?? this.projectStatistic,
      materialStatistics: materialStatistics ?? this.materialStatistics,
      projectBaseError: projectBaseError,
      projectStatisticError: projectStatisticError,
      materialStatisticsError: materialStatisticsError,
      projectId: projectId ?? this.projectId,
    );
  }

  /// 清除项目基础信息错误
  ProjectDetailState clearProjectBaseError() {
    return copyWith(projectBaseError: null);
  }

  /// 清除项目统计信息错误
  ProjectDetailState clearProjectStatisticError() {
    return copyWith(projectStatisticError: null);
  }

  /// 清除材料统计信息错误
  ProjectDetailState clearMaterialStatisticsError() {
    return copyWith(materialStatisticsError: null);
  }

  @override
  List<Object?> get props => [
    projectBaseStatus,
    projectStatisticStatus,
    materialStatisticsStatus,
    projectBase,
    projectStatistic,
    materialStatistics,
    projectBaseError,
    projectStatisticError,
    materialStatisticsError,
    projectId,
  ];
}
