import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/repositories/interfaces/install_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';

import 'install_event.dart';
import 'install_state.dart';

class InstallBloc extends Bloc<InstallEvent, InstallState> {
  final InstallRepository _installRepository;
  final MaterialHandleRepository _materialHandleRepository;
  InstallReady? _readyBeforeSubmit; // 最近一次提交前的就绪态

  InstallBloc({
    required InstallRepository installRepository,
    required MaterialHandleRepository materialHandleRepository,
  }) : _installRepository = installRepository,
       _materialHandleRepository = materialHandleRepository,
       super(const InstallReady()) {
    on<LoadInstallDetail>(_onLoadInstallDetail);
    on<DoInstall>(_onDoInstall);
    on<RefreshInstallDetail>(_onRefreshInstallDetail);
    on<AppendScannedMaterial>(_onAppendScannedMaterial);
    on<RemoveScannedMaterialsByCodes>(_onRemoveScannedMaterialsByCodes);
    on<RestorePreviousReady>(_onRestorePreviousReady);
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
    // 在进入提交态之前，保存当前就绪态，供失败后恢复
    final current = state;
    if (current is InstallReady) {
      _readyBeforeSubmit = current;
    }
    emit(const InstallSubmitting());
    try {
      final result = await _installRepository.doInstall(event.request);
      if (result.isSuccess) {
        emit(const InstallSuccess());
      } else {
        emit(InstallFailure(result.msg));
        return;
      }
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
      final scanTime = DateTime.now();
      final updatedScanResults = List<ScanResult>.from(
        currentState.scanResults,
      );
      InstallReady newReadyState;

      // 处理正常材料
      if (event.materialInfo.normals.isNotEmpty) {
        final material = event.materialInfo.normals.first;

        // 检查是否已经存在相同的物料
        final existingMaterialIds = currentState.scanResults
            .where((r) => r.normalMaterial != null)
            .map((r) => r.normalMaterial!.baseInfo.materialId)
            .toSet();

        if (existingMaterialIds.contains(material.baseInfo.materialId)) {
          // 物料已存在，发出提示信息
          newReadyState = currentState.copyWith(
            materialScanMessage:
                '材料 ${material.baseInfo.materialCode ?? material.baseInfo.materialId} 已经匹配过了',
            clearScanMessage: false,
          );
          emit(newReadyState);
          return;
        }

        // 添加正常材料到扫码结果
        updatedScanResults.add(
          ScanResult(normalMaterial: material, scanTime: scanTime),
        );

        // 更新 materialInfos（保持向后兼容）
        final updatedNormals = updatedScanResults
            .where((r) => r.normalMaterial != null)
            .map((r) => r.normalMaterial!)
            .toList();

        final newMaterialInfos = MaterialInfoForBusiness(
          normals: updatedNormals,
          errors: event.materialInfo.errors,
        );

        newReadyState = currentState.copyWith(
          materialInfos: newMaterialInfos,
          scanResults: updatedScanResults,
          detail: currentState.detail,
        );
        emit(newReadyState);
      }
      // 处理异常材料
      else if (event.materialInfo.errors.isNotEmpty) {
        // 添加所有异常材料到扫码结果
        for (final error in event.materialInfo.errors) {
          updatedScanResults.add(
            ScanResult(errorMaterial: error, scanTime: scanTime),
          );
        }

        // 更新 materialInfos（保持向后兼容）
        final updatedNormals = updatedScanResults
            .where((r) => r.normalMaterial != null)
            .map((r) => r.normalMaterial!)
            .toList();

        final newMaterialInfos = MaterialInfoForBusiness(
          normals: updatedNormals,
          errors: event.materialInfo.errors,
        );

        newReadyState = currentState.copyWith(
          materialInfos: newMaterialInfos,
          scanResults: updatedScanResults,
          detail: currentState.detail,
          materialScanMessage: '扫描到异常材料',
          clearScanMessage: false,
        );
        emit(newReadyState);
      }
    }
  }

  Future<void> _onRemoveScannedMaterialsByCodes(
    RemoveScannedMaterialsByCodes event,
    Emitter<InstallState> emit,
  ) async {
    final currentState = state;
    if (currentState is! InstallReady) return;

    try {
      if (event.codes.isEmpty) return;

      // 调用接口解析扫码的材料ID
      final rsp = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );

      if (!rsp.isSuccess || rsp.data == null) {
        emit(
          currentState.copyWith(
            materialScanMessage: '未匹配到可剔除的材料',
            clearScanMessage: false,
          ),
        );
        return;
      }

      final updatedScanResults = List<ScanResult>.from(
        currentState.scanResults,
      );
      int removedNormal = 0;
      int removedError = 0;
      int unmatchedNormal = 0;
      int unmatchedError = 0;

      // 处理正常材料的剔除
      final idsToRemove = rsp.data!.normals
          .map((m) => m.baseInfo.materialId)
          .toSet();

      for (final id in idsToRemove) {
        final indexToRemove = updatedScanResults.indexWhere(
          (r) => r.normalMaterial?.baseInfo.materialId == id,
        );

        if (indexToRemove != -1) {
          updatedScanResults.removeAt(indexToRemove);
          removedNormal++;
        } else {
          unmatchedNormal++;
        }
      }

      // 处理异常材料的剔除
      for (final scannedError in rsp.data!.errors) {
        final scannedQrCode = _getErrorQrCode(scannedError);
        if (scannedQrCode.isEmpty) {
          unmatchedError++;
          continue;
        }

        final indexToRemove = updatedScanResults.indexWhere(
          (r) =>
              r.errorMaterial != null &&
              _getErrorQrCode(r.errorMaterial) == scannedQrCode,
        );

        if (indexToRemove != -1) {
          updatedScanResults.removeAt(indexToRemove);
          removedError++;
        } else {
          unmatchedError++;
        }
      }

      // 更新 materialInfos（保持向后兼容）
      final updatedNormals = updatedScanResults
          .where((r) => r.normalMaterial != null)
          .map((r) => r.normalMaterial!)
          .toList();

      final updatedErrors = updatedScanResults
          .where((r) => r.errorMaterial != null)
          .map((r) => r.errorMaterial)
          .toList();

      // 动态类型转换为 List<SyncVendorDataError>
      final List<dynamic> errorsList = updatedErrors.toList();

      final newMaterialInfos = MaterialInfoForBusiness(
        normals: updatedNormals,
        errors: errorsList.cast(),
      );

      // 构建消息
      final messages = <String>[];
      if (removedNormal > 0) {
        messages.add('已剔除 $removedNormal 个正常材料');
      }
      if (removedError > 0) {
        messages.add('已剔除 $removedError 个异常材料');
      }
      if (unmatchedNormal > 0 || unmatchedError > 0) {
        final total = unmatchedNormal + unmatchedError;
        messages.add('忽略未在列表 $total 个');
      }

      final message = messages.isNotEmpty ? messages.join('，') : '未找到可剔除的材料';

      emit(
        currentState.copyWith(
          scanResults: updatedScanResults,
          materialInfos: newMaterialInfos,
          materialScanMessage: message,
          clearScanMessage: false,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          materialScanMessage: '剔除材料失败，请重试',
          clearScanMessage: false,
        ),
      );
    }
  }

  void _onRestorePreviousReady(
    RestorePreviousReady event,
    Emitter<InstallState> emit,
  ) {
    // 优先恢复提交前的就绪态，否则退回到空的就绪态
    emit(_readyBeforeSubmit ?? const InstallReady());
  }

  /// 从错误材料对象中提取qrCode
  String _getErrorQrCode(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['qrCode']?.toString() ?? error['qr_code']?.toString() ?? '';
    }
    try {
      return (error as dynamic).qrCode?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }
}
