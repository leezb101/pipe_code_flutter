import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/repositories/interfaces/install_repository.dart';

import 'install_event.dart';
import 'install_state.dart';

class InstallBloc extends Bloc<InstallEvent, InstallState> {
  final InstallRepository _installRepository;

  InstallBloc({required InstallRepository installRepository})
    : _installRepository = installRepository,
      super(const InstallReady()) {
    on<LoadInstallDetail>(_onLoadInstallDetail);
    on<DoInstall>(_onDoInstall);
    on<RefreshInstallDetail>(_onRefreshInstallDetail);
    on<AppendScannedMaterial>(_onAppendScannedMaterial);
  }

  Future<void> _onLoadInstallDetail(
    LoadInstallDetail event,
    Emitter<InstallState> emit,
  ) async {
    emit(const InstallLoading());
    try {
      final result = await _installRepository.getInstallDetail(event.id);
      if (result.isSuccess && result.data != null) {
        emit(InstallReady(detail: result.data));
      } else {
        emit(InstallFailure(result.msg));
      }
    } catch (e) {
      emit(InstallFailure('加载安装详情失败,请稍后重试'));
    }
  }

  Future<void> _onDoInstall(DoInstall event, Emitter<InstallState> emit) async {
    emit(const InstallSubmitting());
    try {
      await _installRepository.doInstall(event.request);
      emit(const InstallSuccess());
    } catch (e) {
      emit(InstallFailure('安装失败,请稍后重试'));
    }
  }

  Future<void> _onRefreshInstallDetail(
    RefreshInstallDetail event,
    Emitter<InstallState> emit,
  ) async {
    emit(const InstallLoading());
    try {
      final result = await _installRepository.getInstallDetail(event.id);
      if (result.isSuccess && result.data != null) {
        emit(InstallReady(detail: result.data));
      } else {
        emit(InstallFailure(result.msg));
      }
    } catch (e) {
      emit(InstallFailure('刷新安装详情失败,请稍后重试'));
    }
  }

  Future<void> _onAppendScannedMaterial(
    AppendScannedMaterial event,
    Emitter<InstallState> emit,
  ) async {
    final currentState = state;
    if (currentState is InstallReady) {
      final material = event.materialInfo.normals.first;
      InstallReady newReadyState;

      if (currentState.materialInfos != null) {
        // 检查是否已经存在相同的物料
        if (currentState.materialInfos!.normals.any(
          (m) => m.materialId == material.materialId,
        )) {
          // 物料已存在，发出提示信息
          newReadyState = currentState.copyWith(
            materialScanMessage: '材料 ${material.materialId} 已经匹配过了',
            clearScanMessage: false,
          );
          emit(newReadyState);
        } else {
          // 创建新的MaterialInfoForBusiness对象，而不是直接修改现有对象
          final updatedNormals = List<MaterialInfoBase>.from(
            currentState.materialInfos!.normals,
          )..add(material);

          final newMaterialInfos = MaterialInfoForBusiness(
            normals: updatedNormals,
            errors: List.from(currentState.materialInfos!.errors),
          );

          newReadyState = currentState.copyWith(
            materialInfos: newMaterialInfos,
            detail: currentState.detail,
          );
          emit(newReadyState);
        }
      } else {
        // 第一次添加物料
        final newMaterialInfos = MaterialInfoForBusiness(
          normals: [material],
          errors: [],
        );
        newReadyState = currentState.copyWith(
          materialInfos: newMaterialInfos,
          detail: currentState.detail,
        );
        emit(newReadyState);
      }
    }
  }
}
