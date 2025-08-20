import 'dart:io';

import "package:flutter_bloc/flutter_bloc.dart";
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:equatable/equatable.dart';

part 'pdf_preview_state.dart';

class PdfPreviewCubit extends Cubit<PdfPreviewState> {
  // 保存当前加载的PDF的临时路径，以便下载时使用
  String? _currentTempPath;

  PdfPreviewCubit() : super(const PdfPreviewInitial());

  // 从URL加载PDF到临时目录以供预览
  Future<void> loadPdf(String url) async {
    try {
      emit(PdfPreviewLoading());
      final filename = url.substring(url.lastIndexOf('/') + 1);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');

      // 简单缓存检查
      if (await file.exists()) {
        _currentTempPath = file.path;
        emit(PdfPreviewSuccess(file.path));
        return;
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        _currentTempPath = file.path;
        emit(PdfPreviewSuccess(file.path));
      } else {
        throw Exception('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      emit(PdfPreviewFailure('Failed to load PDF: $e'));
    }
  }

  // 将PDF从临时目录下载到公共目录
  Future<void> downloadPDF() async {
    if (_currentTempPath == null) {
      emit(const PdfPreviewFailure("error: No PDF loaded"));
      return;
    }

    try {
      // 1. 请求权限
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        // 2. 获取公共下载目录
        // attention: 这在iOS上表现不同，通常保存到App专属的Documents目录
        final Directory? publicDir = await getExternalStorageDirectory();

        if (publicDir == null) {
          throw Exception("无法获取下载目录");
        }

        final filename = _currentTempPath!.split('/').last;
        final newPath = '${publicDir.path}/$filename';
        final tempFile = File(_currentTempPath!);

        // 3. 复制文件
        await tempFile.copy(newPath);
        // 4. 发出带有成功消息的状态
        emit(PdfPreviewSuccess(newPath, message: "文件已成功保存到：$newPath"));
      } else {
        throw Exception('存储权限被拒绝');
      }
    } catch (e) {
      // 若下载失败，不应改变主视图，而只显示错误
      emit(PdfPreviewSuccess(_currentTempPath!, message: "下载失败：$e"));
    }
  }
}
