/*
 * @Author: LeeZB
 * @Date: 2025-08-04 10:15:25
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-04 10:15:25
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../config/app_config.dart';
import '../../../models/common/result.dart';
import '../interfaces/upload_api_service.dart';
import 'base_api_service.dart';

class UploadApiServiceImpl extends BaseApiService implements UploadApiService {
  String? _authToken;

  UploadApiServiceImpl(super.dio);

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
    try {
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();

      // 支持的文件类型
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

      final contentType =
          supportedTypes[fileExtension] ?? 'application/octet-stream';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'scene': "mobile",
        'output': "json",
        'fileName': fileName,
      });

      final options = Options(
        headers: {
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      );

      final response = await dio.post(
        '${AppConfig.uploadUrl}?auth_toke=$_authToken',
        data: formData,
        options: options,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        var data = response.data;
        if (data is String) {
          data = jsonDecode(data);
        }
        final uploadResult = UploadResult(
          fileUrl: data['url'] ?? '',
          fileMd5: data['md5'] ?? '',
          filePath: data['path'] ?? '',
          domain: data['domain'] ?? '',
          scene: data['scene'] ?? '',
          size: data['size'] ?? await file.length(),
          mtime: data['mtime'] ?? 0,
          src: data['src'] ?? '',
          retmsg: data['retmsg'] ?? '',
          retcode: data['retcode'] ?? -1,
          fileName: fileName,
          fileType: contentType,
          uploadTime: DateTime.now(),
        );
        return Result<UploadResult>(
          code: 0,
          msg: '上传成功',
          data: uploadResult,
          success: true,
        );
      } else {
        return Result<UploadResult>(code: -1, msg: '上传失败：服务器响应异常', data: null);
      }
    } on DioException catch (e) {
      return Result<UploadResult>(code: -1, msg: handleError(e), data: null);
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
}
