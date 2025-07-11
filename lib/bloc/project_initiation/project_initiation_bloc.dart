/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:05:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/project/project_initiation.dart';
import '../../services/api/interfaces/project_api_service.dart';
import '../../services/project_api_service_factory.dart';
import '../../utils/logger.dart';

part 'project_initiation_event.dart';
part 'project_initiation_state.dart';

/// 立项BLoC
/// 管理项目立项的所有状态和业务逻辑
class ProjectInitiationBloc extends Bloc<ProjectInitiationEvent, ProjectInitiationState> {
  final ProjectApiService _projectApiService;

  ProjectInitiationBloc({
    ProjectApiService? projectApiService,
  }) : _projectApiService = projectApiService ?? ProjectApiServiceFactory.create(),
        super(ProjectInitiationInitial()) {
    on<LoadProjectInitiationForm>(_onLoadProjectInitiationForm);
    on<SaveProjectDraft>(_onSaveProjectDraft);
    on<UpdateProjectDraft>(_onUpdateProjectDraft);
    on<SubmitProject>(_onSubmitProject);
    on<CommitProject>(_onCommitProject);
    on<LoadProjectList>(_onLoadProjectList);
    on<LoadProjectDetail>(_onLoadProjectDetail);
    on<DeleteProject>(_onDeleteProject);
    on<UpdateProjectFormField>(_onUpdateProjectFormField);
    on<AddMaterialToProject>(_onAddMaterialToProject);
    on<RemoveMaterialFromProject>(_onRemoveMaterialFromProject);
    on<UpdateMaterialInProject>(_onUpdateMaterialInProject);
    on<AddUserToProject>(_onAddUserToProject);
    on<RemoveUserFromProject>(_onRemoveUserFromProject);
    on<LoadSupplierList>(_onLoadSupplierList);
    on<LoadMaterialTypes>(_onLoadMaterialTypes);
    on<LoadUserList>(_onLoadUserList);
  }

  Future<void> _onLoadProjectInitiationForm(
    LoadProjectInitiationForm event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    emit(ProjectInitiationLoading());
    
    try {
      // 如果是编辑模式，加载项目详情
      if (event.projectId != null) {
        final result = await _projectApiService.getProjectDetail(event.projectId!);
        if (result.code == 0 && result.data != null) {
          final project = _convertDetailToInitiation(result.data!);
          emit(ProjectInitiationFormLoaded(project: project));
        } else {
          emit(ProjectInitiationError(message: result.msg));
        }
      } else {
        // 新建模式，创建空表单
        const emptyProject = ProjectInitiation(
          projectName: '',
          projectCode: '',
          projectStart: '',
          projectEnd: '',
          supplyType: 0,
        );
        emit(ProjectInitiationFormLoaded(project: emptyProject));
      }
    } catch (e) {
      Logger.error('加载立项表单失败: $e', tag: 'ProjectInitiationBloc');
      emit(ProjectInitiationError(message: '加载表单失败'));
    }
  }

  Future<void> _onSaveProjectDraft(
    SaveProjectDraft event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    emit(ProjectInitiationLoading());
    
    try {
      final result = await _projectApiService.addProject(event.project);
      if (result.code == 0) {
        emit(ProjectInitiationSuccess(message: '草稿保存成功'));
      } else {
        emit(ProjectInitiationError(message: result.msg));
      }
    } catch (e) {
      Logger.error('保存草稿失败: $e', tag: 'ProjectInitiationBloc');
      emit(ProjectInitiationError(message: '保存草稿失败'));
    }
  }

  Future<void> _onUpdateProjectDraft(
    UpdateProjectDraft event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    emit(ProjectInitiationLoading());
    
    try {
      final result = await _projectApiService.updateProject(event.project);
      if (result.code == 0) {
        emit(ProjectInitiationSuccess(message: '草稿更新成功'));
      } else {
        emit(ProjectInitiationError(message: result.msg));
      }
    } catch (e) {
      Logger.error('更新草稿失败: $e', tag: 'ProjectInitiationBloc');
      emit(ProjectInitiationError(message: '更新草稿失败'));
    }
  }

  Future<void> _onSubmitProject(
    SubmitProject event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    emit(ProjectInitiationLoading());
    
    try {
      final result = await _projectApiService.commitProject(event.project);
      if (result.code == 0) {
        emit(ProjectInitiationSuccess(message: '项目提交成功'));
      } else {
        emit(ProjectInitiationError(message: result.msg));
      }
    } catch (e) {
      Logger.error('提交项目失败: $e', tag: 'ProjectInitiationBloc');
      emit(ProjectInitiationError(message: '提交项目失败'));
    }
  }

  Future<void> _onCommitProject(
    CommitProject event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    emit(ProjectInitiationLoading());
    
    try {
      final result = await _projectApiService.commitProject(event.project);
      if (result.code == 0) {
        emit(ProjectInitiationSuccess(message: '项目立项成功'));
      } else {
        emit(ProjectInitiationError(message: result.msg));
      }
    } catch (e) {
      Logger.error('立项失败: $e', tag: 'ProjectInitiationBloc');
      emit(ProjectInitiationError(message: '立项失败'));
    }
  }

  Future<void> _onLoadProjectList(
    LoadProjectList event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    emit(ProjectInitiationLoading());
    
    try {
      final result = await _projectApiService.getProjectList(
        pageNum: event.pageNum,
        pageSize: event.pageSize,
        projectName: event.projectName,
        projectCode: event.projectCode,
      );
      
      if (result.code == 0 && result.data != null) {
        emit(ProjectListLoaded(projects: result.data!));
      } else {
        emit(ProjectInitiationError(message: result.msg));
      }
    } catch (e) {
      Logger.error('加载项目列表失败: $e', tag: 'ProjectInitiationBloc');
      emit(ProjectInitiationError(message: '加载项目列表失败'));
    }
  }

  Future<void> _onLoadProjectDetail(
    LoadProjectDetail event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    emit(ProjectInitiationLoading());
    
    try {
      final result = await _projectApiService.getProjectDetail(event.id);
      if (result.code == 0 && result.data != null) {
        emit(ProjectDetailLoaded(project: result.data!));
      } else {
        emit(ProjectInitiationError(message: result.msg));
      }
    } catch (e) {
      Logger.error('加载项目详情失败: $e', tag: 'ProjectInitiationBloc');
      emit(ProjectInitiationError(message: '加载项目详情失败'));
    }
  }

  Future<void> _onDeleteProject(
    DeleteProject event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    emit(ProjectInitiationLoading());
    
    try {
      final result = await _projectApiService.deleteProject(event.id);
      if (result.code == 0) {
        emit(ProjectInitiationSuccess(message: '项目删除成功'));
      } else {
        emit(ProjectInitiationError(message: result.msg));
      }
    } catch (e) {
      Logger.error('删除项目失败: $e', tag: 'ProjectInitiationBloc');
      emit(ProjectInitiationError(message: '删除项目失败'));
    }
  }

  Future<void> _onUpdateProjectFormField(
    UpdateProjectFormField event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    if (state is ProjectInitiationFormLoaded) {
      final currentState = state as ProjectInitiationFormLoaded;
      final updatedProject = currentState.project.copyWith(
        projectName: event.projectName,
        projectCode: event.projectCode,
        projectStart: event.projectStart,
        projectEnd: event.projectEnd,
        supplyType: event.supplyType,
        projectReportUrl: event.projectReportUrl,
        publishBidUrl: event.publishBidUrl,
        aimBidUrl: event.aimBidUrl,
        otherDocUrl: event.otherDocUrl,
      );
      emit(ProjectInitiationFormLoaded(project: updatedProject));
    }
  }

  Future<void> _onAddMaterialToProject(
    AddMaterialToProject event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    if (state is ProjectInitiationFormLoaded) {
      final currentState = state as ProjectInitiationFormLoaded;
      final updatedMaterialList = List<ProjectMaterial>.from(currentState.project.materialList)
        ..addAll(event.materials);
      final updatedProject = currentState.project.copyWith(
        materialList: updatedMaterialList,
      );
      emit(ProjectInitiationFormLoaded(project: updatedProject));
    }
  }

  Future<void> _onRemoveMaterialFromProject(
    RemoveMaterialFromProject event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    if (state is ProjectInitiationFormLoaded) {
      final currentState = state as ProjectInitiationFormLoaded;
      final updatedMaterialList = List<ProjectMaterial>.from(currentState.project.materialList)
        ..removeAt(event.index);
      final updatedProject = currentState.project.copyWith(
        materialList: updatedMaterialList,
      );
      emit(ProjectInitiationFormLoaded(project: updatedProject));
    }
  }

  Future<void> _onUpdateMaterialInProject(
    UpdateMaterialInProject event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    if (state is ProjectInitiationFormLoaded) {
      final currentState = state as ProjectInitiationFormLoaded;
      final updatedMaterialList = List<ProjectMaterial>.from(currentState.project.materialList);
      updatedMaterialList[event.index] = event.material;
      final updatedProject = currentState.project.copyWith(
        materialList: updatedMaterialList,
      );
      emit(ProjectInitiationFormLoaded(project: updatedProject));
    }
  }

  Future<void> _onAddUserToProject(
    AddUserToProject event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    if (state is ProjectInitiationFormLoaded) {
      final currentState = state as ProjectInitiationFormLoaded;
      var updatedProject = currentState.project;
      
      switch (event.userType) {
        case 'construction':
          final updatedList = List<ProjectUser>.from(updatedProject.constructionUserList)
            ..add(event.user);
          updatedProject = updatedProject.copyWith(constructionUserList: updatedList);
          break;
        case 'supervisor':
          final updatedList = List<ProjectUser>.from(updatedProject.supervisorUserList)
            ..add(event.user);
          updatedProject = updatedProject.copyWith(supervisorUserList: updatedList);
          break;
        case 'builder':
          final updatedList = List<ProjectUser>.from(updatedProject.builderUserList)
            ..add(event.user);
          updatedProject = updatedProject.copyWith(builderUserList: updatedList);
          break;
      }
      
      emit(ProjectInitiationFormLoaded(project: updatedProject));
    }
  }

  Future<void> _onRemoveUserFromProject(
    RemoveUserFromProject event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    if (state is ProjectInitiationFormLoaded) {
      final currentState = state as ProjectInitiationFormLoaded;
      var updatedProject = currentState.project;
      
      switch (event.userType) {
        case 'construction':
          final updatedList = List<ProjectUser>.from(updatedProject.constructionUserList)
            ..removeAt(event.index);
          updatedProject = updatedProject.copyWith(constructionUserList: updatedList);
          break;
        case 'supervisor':
          final updatedList = List<ProjectUser>.from(updatedProject.supervisorUserList)
            ..removeAt(event.index);
          updatedProject = updatedProject.copyWith(supervisorUserList: updatedList);
          break;
        case 'builder':
          final updatedList = List<ProjectUser>.from(updatedProject.builderUserList)
            ..removeAt(event.index);
          updatedProject = updatedProject.copyWith(builderUserList: updatedList);
          break;
      }
      
      emit(ProjectInitiationFormLoaded(project: updatedProject));
    }
  }

  Future<void> _onLoadSupplierList(
    LoadSupplierList event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    try {
      final result = await _projectApiService.getSupplierList();
      if (result.code == 0 && result.data != null) {
        emit(SupplierListLoaded(suppliers: result.data!));
      } else {
        emit(ProjectInitiationError(message: result.msg));
      }
    } catch (e) {
      Logger.error('加载供应商列表失败: $e', tag: 'ProjectInitiationBloc');
      emit(ProjectInitiationError(message: '加载供应商列表失败'));
    }
  }

  Future<void> _onLoadMaterialTypes(
    LoadMaterialTypes event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    try {
      final result = await _projectApiService.getMaterialTypes();
      if (result.code == 0 && result.data != null) {
        emit(MaterialTypesLoaded(materialTypes: result.data!));
      } else {
        emit(ProjectInitiationError(message: result.msg));
      }
    } catch (e) {
      Logger.error('加载物料类型失败: $e', tag: 'ProjectInitiationBloc');
      emit(ProjectInitiationError(message: '加载物料类型失败'));
    }
  }

  Future<void> _onLoadUserList(
    LoadUserList event,
    Emitter<ProjectInitiationState> emit,
  ) async {
    try {
      final result = await _projectApiService.getUserList(
        roleType: event.roleType,
        orgCode: event.orgCode,
      );
      if (result.code == 0 && result.data != null) {
        emit(UserListLoaded(users: result.data!));
      } else {
        emit(ProjectInitiationError(message: result.msg));
      }
    } catch (e) {
      Logger.error('加载用户列表失败: $e', tag: 'ProjectInitiationBloc');
      emit(ProjectInitiationError(message: '加载用户列表失败'));
    }
  }

  /// 将项目详情转换为立项模型
  ProjectInitiation _convertDetailToInitiation(ProjectDetail detail) {
    return ProjectInitiation(
      id: detail.id,
      projectName: detail.projectName,
      projectCode: detail.projectCode,
      projectStart: detail.projectStart,
      projectEnd: detail.projectEnd,
      supplyType: detail.supplyType,
      projectReportUrl: detail.projectReportUrl,
      publishBidUrl: detail.publishBidUrl,
      aimBidUrl: detail.aimBidUrl,
      otherDocUrl: detail.otherDocUrl,
      materialList: detail.materialList,
      constructionUserList: detail.constructionUserList,
      supervisorUserList: detail.supervisorUserList,
      builderUserList: detail.builderUserList,
    );
  }
}