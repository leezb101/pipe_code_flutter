/*
 * @Author: LeeZB
 * @Date: 2025-08-05 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-05 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/services/api/interfaces/upload_api_service.dart';
import 'file_upload_state.dart';

class FileUploadCubit extends Cubit<List<FileUploadState>> {
  final UploadApiService _uploadApiService;

  FileUploadCubit()
      : _uploadApiService = getIt<UploadApiService>(),
        super([]);

  /// 添加文件并立即开始上传
  Future<void> addFiles(List<File> files) async {
    final newUploadStates =
        files.map((file) => FileUploadState.fromFile(file)).toList();

    // 先将文件以initial状态添加到UI
    emit([...state, ...newUploadStates]);

    // 逐个触发上传
    for (final uploadState in newUploadStates) {
      _uploadFile(uploadState.uniqueId);
    }
  }

  /// 内部方法，执行单个文件的上传
  Future<void> _uploadFile(String uniqueId) async {
    final stateIndex = state.indexWhere((s) => s.uniqueId == uniqueId);
    if (stateIndex == -1) return;

    final currentState = state[stateIndex];

    // 更新状态为uploading
    _updateState(uniqueId,
        status: UploadStatus.uploading, progress: 0.0, errorMessage: null);

    final result = await _uploadApiService.uploadFile(
      currentState.file,
      onProgress: (progress) {
        _updateState(uniqueId, progress: progress);
      },
    );

    if (result.isSuccess && result.data != null) {
      _updateState(
        uniqueId,
        status: UploadStatus.success,
        progress: 1.0,
        uploadResult: result.data,
      );
    } else {
      _updateState(
        uniqueId,
        status: UploadStatus.failure,
        errorMessage: result.msg ?? '上传失败',
      );
    }
  }

  /// 更新指定文件的状态
  void _updateState(
    String uniqueId, {
    UploadStatus? status,
    double? progress,
    UploadResult? uploadResult,
    String? errorMessage,
  }) {
    final stateIndex = state.indexWhere((s) => s.uniqueId == uniqueId);
    if (stateIndex != -1) {
      final updatedStates = List<FileUploadState>.from(state);
      updatedStates[stateIndex] = updatedStates[stateIndex].copyWith(
        status: status,
        progress: progress,
        uploadResult: uploadResult,
        errorMessage: errorMessage,
      );
      emit(updatedStates);
    }
  }

  /// 移除一个文件
  void removeFile(String uniqueId) {
    // 在这里可以添加取消上传的逻辑（如果Dio支持）
    final updatedStates = state.where((s) => s.uniqueId != uniqueId).toList();
    emit(updatedStates);
  }

  /// 重试上传失败的文件
  void retryUpload(String uniqueId) {
    final stateIndex = state.indexWhere((s) => s.uniqueId == uniqueId);
    if (stateIndex != -1 && state[stateIndex].status == UploadStatus.failure) {
      _uploadFile(uniqueId);
    }
  }

  /// 清空所有文件
  void clearAll() {
    emit([]);
  }
}
