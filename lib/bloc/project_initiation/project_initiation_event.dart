/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:05:00
 * @copyright: Copyright © 2025 高新供水.
 */
part of 'project_initiation_bloc.dart';

/// 立项事件基类
abstract class ProjectInitiationEvent extends Equatable {
  const ProjectInitiationEvent();

  @override
  List<Object?> get props => [];
}

/// 加载立项表单
class LoadProjectInitiationForm extends ProjectInitiationEvent {
  final int? projectId; // 为空表示新建，有值表示编辑

  const LoadProjectInitiationForm({this.projectId});

  @override
  List<Object?> get props => [projectId];
}

/// 保存项目草稿
class SaveProjectDraft extends ProjectInitiationEvent {
  final ProjectInitiation project;

  const SaveProjectDraft({required this.project});

  @override
  List<Object?> get props => [project];
}

/// 更新项目草稿
class UpdateProjectDraft extends ProjectInitiationEvent {
  final ProjectInitiation project;

  const UpdateProjectDraft({required this.project});

  @override
  List<Object?> get props => [project];
}

/// 提交项目
class SubmitProject extends ProjectInitiationEvent {
  final ProjectInitiation project;

  const SubmitProject({required this.project});

  @override
  List<Object?> get props => [project];
}

/// 立项提交
class CommitProject extends ProjectInitiationEvent {
  final ProjectInitiation project;

  const CommitProject({required this.project});

  @override
  List<Object?> get props => [project];
}

/// 加载项目列表
class LoadProjectList extends ProjectInitiationEvent {
  final int pageNum;
  final int pageSize;
  final String? projectName;
  final String? projectCode;

  const LoadProjectList({
    this.pageNum = 1,
    this.pageSize = 10,
    this.projectName,
    this.projectCode,
  });

  @override
  List<Object?> get props => [pageNum, pageSize, projectName, projectCode];
}

/// 加载项目详情
class LoadProjectDetail extends ProjectInitiationEvent {
  final int id;

  const LoadProjectDetail({required this.id});

  @override
  List<Object?> get props => [id];
}

/// 删除项目
class DeleteProject extends ProjectInitiationEvent {
  final int id;

  const DeleteProject({required this.id});

  @override
  List<Object?> get props => [id];
}

/// 更新项目表单字段
class UpdateProjectFormField extends ProjectInitiationEvent {
  final String? projectName;
  final String? projectCode;
  final String? projectStart;
  final String? projectEnd;
  final int? supplyType;
  final String? projectReportUrl;
  final String? publishBidUrl;
  final String? aimBidUrl;
  final String? otherDocUrl;

  const UpdateProjectFormField({
    this.projectName,
    this.projectCode,
    this.projectStart,
    this.projectEnd,
    this.supplyType,
    this.projectReportUrl,
    this.publishBidUrl,
    this.aimBidUrl,
    this.otherDocUrl,
  });

  @override
  List<Object?> get props => [
        projectName,
        projectCode,
        projectStart,
        projectEnd,
        supplyType,
        projectReportUrl,
        publishBidUrl,
        aimBidUrl,
        otherDocUrl,
      ];
}

/// 添加耗材到项目
class AddMaterialToProject extends ProjectInitiationEvent {
  final List<ProjectMaterial> materials;

  const AddMaterialToProject({required this.materials});

  @override
  List<Object?> get props => [materials];
}

/// 从项目中移除耗材
class RemoveMaterialFromProject extends ProjectInitiationEvent {
  final int index;

  const RemoveMaterialFromProject({required this.index});

  @override
  List<Object?> get props => [index];
}

/// 更新项目中的耗材
class UpdateMaterialInProject extends ProjectInitiationEvent {
  final int index;
  final ProjectMaterial material;

  const UpdateMaterialInProject({
    required this.index,
    required this.material,
  });

  @override
  List<Object?> get props => [index, material];
}

/// 添加用户到项目
class AddUserToProject extends ProjectInitiationEvent {
  final ProjectUser user;
  final String userType; // 'construction', 'supervisor', 'builder'

  const AddUserToProject({
    required this.user,
    required this.userType,
  });

  @override
  List<Object?> get props => [user, userType];
}

/// 从项目中移除用户
class RemoveUserFromProject extends ProjectInitiationEvent {
  final int index;
  final String userType; // 'construction', 'supervisor', 'builder'

  const RemoveUserFromProject({
    required this.index,
    required this.userType,
  });

  @override
  List<Object?> get props => [index, userType];
}

/// 加载供应商列表
class LoadSupplierList extends ProjectInitiationEvent {
  const LoadSupplierList();
}

/// 加载物料类型
class LoadMaterialTypes extends ProjectInitiationEvent {
  const LoadMaterialTypes();
}

/// 加载用户列表
class LoadUserList extends ProjectInitiationEvent {
  final String? roleType;
  final String? orgCode;

  const LoadUserList({this.roleType, this.orgCode});

  @override
  List<Object?> get props => [roleType, orgCode];
}