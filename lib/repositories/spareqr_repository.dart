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

class SpareqrRepository {
  final ApiServiceInterface _apiservice;

  SpareqrRepository({required ApiServiceInterface apiservice})
    : _apiservice = apiservice;

  Stream<SpareQrState> downloadSpareqrZipFile() async* {
    try {
      yield const SpareQrInProgress(0.0);

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'qrcode_for_backup${DateTime.now().toIso8601String()}.zip';
      final savePath = '${tempDir.path}/$fileName';

      final response = await _apiservice.spare.downloadSpareqrZip(20);
      final byteStream = response.stream;
      final totalBytes = response.totalBytes;

      final file = File(savePath);
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

      yield SpareQrSuccess(savePath);
    } catch (e) {
      yield SpareQrFailure(e.toString());
    }
  }
}
