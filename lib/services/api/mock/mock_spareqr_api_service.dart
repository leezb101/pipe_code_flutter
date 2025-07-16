/*
 * @Author: LeeZB
 * @Date: 2025-07-16 10:37:05
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-16 13:36:17
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/services/api/interfaces/spareqr_api_service.dart';
import 'package:pipe_code_flutter/models/business/download_stream.dart';

class MockSpareqrApiService implements SpareqrApiService {
  @override
  Future<DownloadStreamResponse> downloadSpareqrZip(int num) async {
    return DownloadStreamResponse(
      stream: Stream<List<int>>.fromIterable([
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
      ]),
      totalBytes: 0,
    );
  }
}
