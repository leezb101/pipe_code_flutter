/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:05:00
 * @copyright: Copyright © 2025 高新供水.
 */
part of 'project_initiation_bloc.dart';

/// 立项状态基类
abstract class ProjectInitiationState extends Equatable {
  const ProjectInitiationState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class ProjectInitiationInitial extends ProjectInitiationState {}

/// 加载中状态
class ProjectInitiationLoading extends ProjectInitiationState {}

/// 表单加载完成状态
class ProjectInitiationFormLoaded extends ProjectInitiationState {
  final ProjectInitiation project;

  const ProjectInitiationFormLoaded({required this.project});

  @override
  List<Object?> get props => [project];
}

/// 项目列表加载完成状态
class ProjectListLoaded extends ProjectInitiationState {
  final List<ProjectListItem> projects;

  const ProjectListLoaded({required this.projects});

  @override
  List<Object?> get props => [projects];
}

/// 项目详情加载完成状态
class ProjectDetailLoaded extends ProjectInitiationState {
  final ProjectDetail project;

  const ProjectDetailLoaded({required this.project});

  @override
  List<Object?> get props => [project];
}

/// 供应商列表加载完成状态
class SupplierListLoaded extends ProjectInitiationState {
  final List<ProjectSupplier> suppliers;

  const SupplierListLoaded({required this.suppliers});

  @override
  List<Object?> get props => [suppliers];
}

/// 物料类型加载完成状态
class MaterialTypesLoaded extends ProjectInitiationState {
  final List<MaterialType> materialTypes;

  const MaterialTypesLoaded({required this.materialTypes});

  @override
  List<Object?> get props => [materialTypes];
}

/// 用户列表加载完成状态
class UserListLoaded extends ProjectInitiationState {
  final List<ProjectUser> users;

  const UserListLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

/// 操作成功状态
class ProjectInitiationSuccess extends ProjectInitiationState {
  final String message;

  const ProjectInitiationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// 错误状态
class ProjectInitiationError extends ProjectInitiationState {
  final String message;

  const ProjectInitiationError({required this.message});

  @override
  List<Object?> get props => [message];
}