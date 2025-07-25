import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/repositories/install_repository.dart';

import 'install_event.dart';
import 'install_state.dart';

class InstallBloc extends Bloc<InstallEvent, InstallState> {
  final InstallRepository _installRepository;

  InstallBloc({required InstallRepository installRepository})
    : _installRepository = installRepository,
      super(const InstallInitial()) {
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
        emit(InstallFailure(result.msg ?? '加载安装详情失败'));
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
        emit(InstallFailure(result.msg ?? '刷新安装详情失败'));
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
      final newMaterialInfos = currentState.materialInfos;
      if (newMaterialInfos != null) {
        if (newMaterialInfos.normals.any(
          (m) => m.materialId == material.materialId,
        )) {
          newReadyState = currentState.copyWith(
            materialInfos: newMaterialInfos,
          );
          emit(
            newReadyState.copyWith(
              materialScanMessage: '材料 ${material.materialId} 已经匹配过了',
              clearScanMessage: false,
            ),
          );
        } else {
          newMaterialInfos.normals.add(material);
          newReadyState = currentState.copyWith(
            materialInfos: newMaterialInfos,
          );
        }
      } else {
        newReadyState = currentState;
      }
      emit(newReadyState);
    }
  }
}
