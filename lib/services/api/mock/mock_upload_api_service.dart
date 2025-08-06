/*
 * @Author: LeeZB
 * @Date: 2025-08-04 10:15:25
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-04 10:15:25
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:io';
import 'dart:math';
import '../../../models/common/result.dart';
import '../interfaces/upload_api_service.dart';

class MockUploadApiService implements UploadApiService {
  String? _authToken;

  @override
  void setAuthToken(String token) {
    _authToken = token;
  }

  @override
  void clearAuthToken() {
    _authToken = null;
  }

  @override
  Future<Result<UploadResult>> uploadFile(
    File file, {
    void Function(double progress)? onProgress,
  }) async {
    if (_authToken == null) {
      return Result<UploadResult>(code: -1, msg: '未设置认证令牌', data: null);
    }
    try {
      // 模拟上传进度
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (onProgress != null) {
          onProgress(i / 10);
        }
      }

      final fileName = file.path.split('/').last;
      final fileSize = await file.length();
      final fileId =
          'mock_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';

      // 模拟文件 URL
      final fileUrl =
          'https://mock.example.com/files/$fileId${fileName.substring(fileName.lastIndexOf('.'))}';

      final uploadResult = UploadResult(
        fileUrl: fileUrl,
        fileMd5: 'mock_md5_$fileId',
        filePath: file.path,
        domain: 'mock.example.com',
        scene: 'mock_scene',
        size: fileSize,
        mtime: DateTime.now().millisecondsSinceEpoch,
        src: 'mock_src',
        retmsg: 'Success',
        retcode: 0,
        fileName: fileName,
        fileType: _getFileType(fileName) ?? 'application/octet-stream',
        uploadTime: DateTime.now(),
      );

      return Result<UploadResult>(
        code: 0,
        msg: '上传成功',
        data: uploadResult,
        success: true,
      );
    } catch (e) {
      return Result<UploadResult>(
        code: -1,
        msg: '上传失败：${e.toString()}',
        data: null,
      );
    }
  }

  @override
  Future<Result<List<UploadResult>>> uploadFiles(
    List<File> files, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final results = <UploadResult>[];
      int completed = 0;

      for (int i = 0; i < files.length; i++) {
        final file = files[i];

        // 单个文件的进度回调
        void onFileProgress(double progress) {
          if (onProgress != null) {
            final overallProgress = (completed + progress) / files.length;
            onProgress(overallProgress);
          }
        }

        final result = await uploadFile(file, onProgress: onFileProgress);

        if (result.isSuccess) {
          results.add(result.data!);
        } else {
          // 如果有文件上传失败，返回错误
          return Result<List<UploadResult>>(
            code: result.code,
            msg: '文件 ${file.path.split('/').last} 上传失败：${result.msg}',
            data: null,
          );
        }

        completed++;
      }

      return Result<List<UploadResult>>(
        code: 0,
        msg: '批量上传成功',
        data: results,
        success: true,
      );
    } catch (e) {
      return Result<List<UploadResult>>(
        code: -1,
        msg: '批量上传失败：${e.toString()}',
        data: null,
      );
    }
  }

  String? _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    final supportedTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain',
    };
    return supportedTypes[extension];
  }
}
