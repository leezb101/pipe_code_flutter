/*
 * @Author: LeeZB
 * @Date: 2025-07-16 10:30:21
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-16 14:05:12
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pipe_code_flutter/bloc/spare_qr/spare_qr_state.dart';
import 'package:pipe_code_flutter/services/api/interfaces/api_service_interface.dart';
import 'package:pipe_code_flutter/repositories/interfaces/spareqr_repository.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

class SpareqrRepositoryImpl implements SpareqrRepository {
  final ApiServiceInterface _apiservice;

  SpareqrRepositoryImpl({required ApiServiceInterface apiservice})
    : _apiservice = apiservice;

  @override
  Stream<SpareQrState> downloadSpareqrZipFile(int num) async* {
    try {
      yield const SpareQrInProgress(0.0);

      // 使用外部应用目录，其他应用可以访问
      Directory? externalDir;

      if (Platform.isAndroid) {
        // Android: 使用外部应用文件目录
        externalDir = await getExternalStorageDirectory();
      } else {
        // iOS: 使用应用文档目录
        externalDir = await getApplicationDocumentsDirectory();
      }

      if (externalDir == null) {
        throw Exception('无法获取存储目录');
      }

      final fileName =
          'qrcode_backup_${DateTime.now().millisecondsSinceEpoch}.zip';
      final savePath = '${externalDir.path}/$fileName';

      Logger.info('下载文件到: $savePath', tag: 'SpareQrRepository');

      final response = await _apiservice.spare.downloadSpareqrZip(num);
      final byteStream = response.stream;
      final totalBytes = response.totalBytes;

      final file = File(savePath);

      // 确保目录存在
      await file.parent.create(recursive: true);

      final fileSink = file.openSync(mode: FileMode.write);

      int receivedBytes = 0;

      await for (final chunk in byteStream) {
        fileSink.writeFromSync(chunk);
        receivedBytes += chunk.length;

        if (totalBytes != 0) {
          final progress = receivedBytes / totalBytes;
          yield SpareQrInProgress(progress);
        }
      }

      await fileSink.close();

      // 验证文件是否成功创建
      if (await file.exists()) {
        final fileSize = await file.length();
        Logger.info(
          '文件下载成功: $savePath, 大小: ${fileSize}B',
          tag: 'SpareQrRepository',
        );
        yield SpareQrSuccess(savePath);
      } else {
        throw Exception('文件下载后不存在');
      }
    } catch (e) {
      Logger.error('下载失败', tag: 'SpareQrRepository', error: e);
      yield SpareQrFailure('下载失败: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        Logger.info('文件已删除: $filePath', tag: 'SpareQrRepository');
        return true;
      }
      Logger.warning('文件不存在，无需删除: $filePath', tag: 'SpareQrRepository');
      return false;
    } catch (e) {
      Logger.error('删除文件失败: $filePath', tag: 'SpareQrRepository', error: e);
      return false;
    }
  }
}
