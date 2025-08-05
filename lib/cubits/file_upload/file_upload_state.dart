/*
 * @Author: LeeZB
 * @Date: 2025-08-05 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-05 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/services/api/interfaces/upload_api_service.dart';

/// 文件上传状态枚举
enum UploadStatus {
  /// 初始状态，等待上传
  initial,

  /// 正在上传
  uploading,

  /// 上传成功
  success,

  /// 上传失败
  failure,
}

/// 单个文件的上传状态
class FileUploadState extends Equatable {
  /// 本地文件对象
  final File file;

  /// 上传状态
  final UploadStatus status;

  /// 上传进度 (0.0 to 1.0)
  final double progress;

  /// 上传成功后的结果
  final UploadResult? uploadResult;

  /// 上传失败时的错误信息
  final String? errorMessage;

  /// 唯一标识符，用于区分不同的文件实例
  final String uniqueId;

  const FileUploadState({
    required this.file,
    this.status = UploadStatus.initial,
    this.progress = 0.0,
    this.uploadResult,
    this.errorMessage,
    required this.uniqueId,
  });

  /// 便利的构造函数，用于从一个File对象创建初始状态
  factory FileUploadState.fromFile(File file) {
    return FileUploadState(
      file: file,
      uniqueId: '${file.path}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  FileUploadState copyWith({
    File? file,
    UploadStatus? status,
    double? progress,
    UploadResult? uploadResult,
    String? errorMessage,
    String? uniqueId,
  }) {
    return FileUploadState(
      file: file ?? this.file,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      uploadResult: uploadResult ?? this.uploadResult,
      errorMessage: errorMessage ?? this.errorMessage,
      uniqueId: uniqueId ?? this.uniqueId,
    );
  }

  @override
  List<Object?> get props => [
        file.path,
        status,
        progress,
        uploadResult,
        errorMessage,
        uniqueId,
      ];
}
