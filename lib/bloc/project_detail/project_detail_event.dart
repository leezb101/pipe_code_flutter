/*
 * @Author: LeeZB
 * @Date: 2025-09-09 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-09 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';

/// 项目详情事件基类
abstract class ProjectDetailEvent extends Equatable {
  const ProjectDetailEvent();

  @override
  List<Object?> get props => [];
}

/// 加载项目详情
class LoadProjectDetail extends ProjectDetailEvent {
  final int projectId;

  const LoadProjectDetail({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

/// 刷新项目详情
class RefreshProjectDetail extends ProjectDetailEvent {
  final int projectId;

  const RefreshProjectDetail({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

/// 清除错误消息
class ClearErrorMessage extends ProjectDetailEvent {
  const ClearErrorMessage();
}
