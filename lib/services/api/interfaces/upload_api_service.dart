/*
 * @Author: LeeZB
 * @Date: 2025-08-04 10:15:25
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-04 10:15:25
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:io';
import '../../../models/common/result.dart';

/// 文件上传API服务接口
abstract class UploadApiService {
  /// 上传单个文件
  /// POST /group1/upload
  /// [file] 要上传的文件
  /// [onProgress] 上传进度回调 (0.0 - 1.0)
  Future<Result<UploadResult>> uploadFile(
    File file, {
    void Function(double progress)? onProgress,
  });

  /// 上传多个文件
  /// [files] 要上传的文件列表
  /// [onProgress] 上传进度回调 (0.0 - 1.0)
  Future<Result<List<UploadResult>>> uploadFiles(
    List<File> files, {
    void Function(double progress)? onProgress,
  });

  /// 设置认证token
  void setAuthToken(String token);

  /// 清除认证token
  void clearAuthToken();
}

/// 文件上传结果
class UploadResult {
  final String fileId;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String? fileType;
  final DateTime uploadTime;

  UploadResult({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    this.fileType,
    required this.uploadTime,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      fileId: json['fileId'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileSize: json['fileSize'] as int,
      fileType: json['fileType'] as String?,
      uploadTime: DateTime.parse(json['uploadTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'fileType': fileType,
      'uploadTime': uploadTime.toIso8601String(),
    };
  }
}