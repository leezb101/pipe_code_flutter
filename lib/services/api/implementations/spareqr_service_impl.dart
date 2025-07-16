/*
 * @Author: LeeZB
 * @Date: 2025-07-16 10:12:31
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-16 13:35:12
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/models/business/download_stream.dart';
import '../interfaces/spareqr_api_service.dart';
import 'base_api_service.dart';

class SpareqrServiceImpl extends BaseApiService implements SpareqrApiService {
  SpareqrServiceImpl(super.dio);

  @override
  Future<DownloadStreamResponse> downloadSpareqrZip(int num) async {
    final response = await dio.get(
      '/qr/down',
      queryParameters: {'num': num},
      options: Options(responseType: ResponseType.stream),
    );

    final total =
        int.tryParse(
          response.headers.value(Headers.contentLengthHeader) ?? '0',
        ) ??
        0;

    if (response.statusCode != 200) {
      throw DioException.badResponse(
        statusCode: response.statusCode ?? 500,
        requestOptions: response.requestOptions,
        response: response,
      );
    }

    if (response.data == null) {
      throw DioException.badResponse(
        statusCode: response.statusCode ?? 404,
        requestOptions: response.requestOptions,
        response: response,
      );
    }

    return DownloadStreamResponse(
      stream: response.data!.stream,
      totalBytes: total,
    );
  }
}
