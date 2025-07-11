/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:05:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/project/project_initiation.dart';
import '../services/api/interfaces/project_api_service.dart';
import '../services/project_api_service_factory.dart';
import '../utils/logger.dart';

/// 耗材选择状态
abstract class MaterialSelectionState extends Equatable {
  const MaterialSelectionState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class MaterialSelectionInitial extends MaterialSelectionState {}

/// 加载中状态
class MaterialSelectionLoading extends MaterialSelectionState {}

/// 耗材选择页面加载完成状态
class MaterialSelectionLoaded extends MaterialSelectionState {
  final List<MaterialType> materialTypes;
  final List<ProjectMaterial> selectedMaterials;
  final String? remarks;

  const MaterialSelectionLoaded({
    required this.materialTypes,
    required this.selectedMaterials,
    this.remarks,
  });

  @override
  List<Object?> get props => [materialTypes, selectedMaterials, remarks];
}

/// 操作成功状态
class MaterialSelectionSuccess extends MaterialSelectionState {
  final List<ProjectMaterial> selectedMaterials;
  final String? remarks;

  const MaterialSelectionSuccess({
    required this.selectedMaterials,
    this.remarks,
  });

  @override
  List<Object?> get props => [selectedMaterials, remarks];
}

/// 错误状态
class MaterialSelectionError extends MaterialSelectionState {
  final String message;

  const MaterialSelectionError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// 耗材选择Cubit
/// 管理耗材选择页面的状态
class MaterialSelectionCubit extends Cubit<MaterialSelectionState> {
  final ProjectApiService _projectApiService;

  MaterialSelectionCubit({
    ProjectApiService? projectApiService,
  }) : _projectApiService = projectApiService ?? ProjectApiServiceFactory.create(),
        super(MaterialSelectionInitial());

  /// 初始化耗材选择页面
  Future<void> initializeMaterialSelection({
    List<ProjectMaterial>? existingMaterials,
    String? remarks,
  }) async {
    emit(MaterialSelectionLoading());

    try {
      final result = await _projectApiService.getMaterialTypes();
      if (result.code == 0 && result.data != null) {
        emit(MaterialSelectionLoaded(
          materialTypes: result.data!,
          selectedMaterials: existingMaterials ?? [],
          remarks: remarks,
        ));
      } else {
        emit(MaterialSelectionError(message: result.msg));
      }
    } catch (e) {
      Logger.error('初始化耗材选择失败: $e', tag: 'MaterialSelectionCubit');
      emit(MaterialSelectionError(message: '初始化失败'));
    }
  }

  /// 添加耗材
  void addMaterial(ProjectMaterial material) {
    if (state is MaterialSelectionLoaded) {
      final currentState = state as MaterialSelectionLoaded;
      final updatedMaterials = List<ProjectMaterial>.from(currentState.selectedMaterials)
        ..add(material);
      
      emit(MaterialSelectionLoaded(
        materialTypes: currentState.materialTypes,
        selectedMaterials: updatedMaterials,
        remarks: currentState.remarks,
      ));
    }
  }

  /// 批量添加耗材
  void addMaterials(List<ProjectMaterial> materials) {
    if (state is MaterialSelectionLoaded) {
      final currentState = state as MaterialSelectionLoaded;
      final updatedMaterials = List<ProjectMaterial>.from(currentState.selectedMaterials)
        ..addAll(materials);
      
      emit(MaterialSelectionLoaded(
        materialTypes: currentState.materialTypes,
        selectedMaterials: updatedMaterials,
        remarks: currentState.remarks,
      ));
    }
  }

  /// 移除耗材
  void removeMaterial(int index) {
    if (state is MaterialSelectionLoaded) {
      final currentState = state as MaterialSelectionLoaded;
      final updatedMaterials = List<ProjectMaterial>.from(currentState.selectedMaterials)
        ..removeAt(index);
      
      emit(MaterialSelectionLoaded(
        materialTypes: currentState.materialTypes,
        selectedMaterials: updatedMaterials,
        remarks: currentState.remarks,
      ));
    }
  }

  /// 更新耗材
  void updateMaterial(int index, ProjectMaterial material) {
    if (state is MaterialSelectionLoaded) {
      final currentState = state as MaterialSelectionLoaded;
      final updatedMaterials = List<ProjectMaterial>.from(currentState.selectedMaterials);
      updatedMaterials[index] = material;
      
      emit(MaterialSelectionLoaded(
        materialTypes: currentState.materialTypes,
        selectedMaterials: updatedMaterials,
        remarks: currentState.remarks,
      ));
    }
  }

  /// 更新备注
  void updateRemarks(String remarks) {
    if (state is MaterialSelectionLoaded) {
      final currentState = state as MaterialSelectionLoaded;
      emit(MaterialSelectionLoaded(
        materialTypes: currentState.materialTypes,
        selectedMaterials: currentState.selectedMaterials,
        remarks: remarks,
      ));
    }
  }

  /// 清空选择
  void clearSelection() {
    if (state is MaterialSelectionLoaded) {
      final currentState = state as MaterialSelectionLoaded;
      emit(MaterialSelectionLoaded(
        materialTypes: currentState.materialTypes,
        selectedMaterials: [],
        remarks: null,
      ));
    }
  }

  /// 确认选择
  void confirmSelection() {
    if (state is MaterialSelectionLoaded) {
      final currentState = state as MaterialSelectionLoaded;
      emit(MaterialSelectionSuccess(
        selectedMaterials: currentState.selectedMaterials,
        remarks: currentState.remarks,
      ));
    }
  }

  /// 从文件导入耗材
  Future<void> importMaterialsFromFile(String filePath) async {
    // 这里可以实现从Excel等文件导入耗材的逻辑
    // 目前先返回模拟数据
    try {
      // 模拟文件解析
      await Future.delayed(Duration(milliseconds: 800));
      
      final importedMaterials = [
        const ProjectMaterial(
          name: '导入PE管DN100',
          type: 1,
          typeName: '管材',
          needNum: 500,
        ),
        const ProjectMaterial(
          name: '导入三通DN100',
          type: 2,
          typeName: '管件',
          needNum: 25,
        ),
      ];
      
      addMaterials(importedMaterials);
    } catch (e) {
      Logger.error('导入耗材失败: $e', tag: 'MaterialSelectionCubit');
      emit(MaterialSelectionError(message: '导入失败'));
    }
  }

  /// 下载模板
  Future<void> downloadTemplate() async {
    // 这里可以实现下载模板的逻辑
    try {
      await Future.delayed(Duration(milliseconds: 500));
      Logger.info('模板下载成功', tag: 'MaterialSelectionCubit');
    } catch (e) {
      Logger.error('下载模板失败: $e', tag: 'MaterialSelectionCubit');
      emit(MaterialSelectionError(message: '下载模板失败'));
    }
  }

  /// 验证耗材数据
  bool validateMaterials() {
    if (state is MaterialSelectionLoaded) {
      final currentState = state as MaterialSelectionLoaded;
      
      // 检查是否有选择的耗材
      if (currentState.selectedMaterials.isEmpty) {
        return false;
      }
      
      // 检查每个耗材的数据完整性
      for (final material in currentState.selectedMaterials) {
        if (material.name.isEmpty || material.needNum <= 0) {
          return false;
        }
      }
      
      return true;
    }
    return false;
  }
}