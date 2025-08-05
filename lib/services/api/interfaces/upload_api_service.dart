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
  final String fileUrl;
  final String fileMd5;
  final String filePath;
  final String domain;
  final String scene;
  final int size;
  final int mtime;
  final String src;
  final String retmsg;
  final int retcode;
  final String fileName;
  final String fileType;
  final DateTime uploadTime;

  UploadResult({
    required this.fileUrl,
    required this.fileMd5,
    required this.filePath,
    required this.domain,
    required this.scene,
    required this.size,
    required this.mtime,
    required this.src,
    required this.retmsg,
    required this.retcode,
    required this.fileName,
    required this.fileType,
    required this.uploadTime,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      fileUrl: json['url'] ?? '',
      fileMd5: json['md5'] ?? '',
      filePath: json['path'] ?? '',
      domain: json['domain'] ?? '',
      scene: json['scene'] ?? '',
      size: json['size'] ?? 0,
      mtime: json['mtime'] ?? 0,
      src: json['src'] ?? '',
      retmsg: json['retmsg'] ?? '',
      retcode: json['retcode'] ?? -1,
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'] ?? '',
      uploadTime: json['uploadTime'] != null
          ? DateTime.parse(json['uploadTime'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': fileUrl,
      'md5': fileMd5,
      'path': filePath,
      'domain': domain,
      'scene': scene,
      'size': size,
      'mtime': mtime,
      'src': src,
      'retmsg': retmsg,
      'retcode': retcode,
      'fileName': fileName,
      'fileType': fileType,
      'uploadTime': uploadTime.toIso8601String(),
    };
  }
}
