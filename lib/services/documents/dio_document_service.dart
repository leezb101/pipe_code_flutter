import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/common/document_discriptor.dart';
import 'document_service.dart';

class DioDocumentService extends DocumentService {
  final Dio _dio;
  CancelToken? _cancelToken;

  DioDocumentService(this._dio);

  @override
  Stream<DownloadProgress> downloadDocument(
    DocumentDescriptor descriptor,
  ) async* {
    final url = descriptor.url;
    if (url == null || url.isEmpty) {
      throw ArgumentError('DocumentDescriptor.url is missing');
    }

    _cancelToken?.cancel('cancelled by new download');
    final token = CancelToken();
    _cancelToken = token;

    final response = await _dio.get<ResponseBody>(
      url,
      options: Options(responseType: ResponseType.stream),
      cancelToken: token,
    );

    final total =
        int.tryParse(
          response.headers.value(HttpHeaders.contentLengthHeader) ?? '',
        ) ??
        0;

    final body = response.data;
    if (body == null) {
      throw StateError('Empty response body for document download');
    }

    final targetFile = await _prepareTargetFile(descriptor.name);
    final sink = targetFile.openWrite();
    var received = 0;

    try {
      await for (final chunk in body.stream) {
        if (token.isCancelled) {
          throw DioException(
            requestOptions: RequestOptions(path: url),
            type: DioExceptionType.cancel,
          );
        }
        received += chunk.length;
        sink.add(chunk);
        yield DownloadProgress(received: received, total: total);
      }
      await sink.flush();
      yield DownloadProgress(
        received: received,
        total: total,
        isCompleted: true,
        filePath: targetFile.path,
      );
    } finally {
      await sink.close();
      if (identical(_cancelToken, token)) {
        _cancelToken = null;
      }
    }
  }

  @override
  void cancel() {
    _cancelToken?.cancel('cancelled by user');
    _cancelToken = null;
  }

  Future<File> _prepareTargetFile(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final safeName = name.trim().isEmpty
        ? 'document_${DateTime.now().millisecondsSinceEpoch}'
        : name.trim();
    final filePath = p.join(directory.path, safeName);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    return file;
  }
}
