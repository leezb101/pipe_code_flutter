/*
 * @Author: LeeZB
 * @Date: 2025-09-28
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-28
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';

/// 使用带水印相机的示例页面
class WatermarkCameraExamplePage extends StatefulWidget {
  const WatermarkCameraExamplePage({super.key});

  @override
  State<WatermarkCameraExamplePage> createState() =>
      _WatermarkCameraExamplePageState();
}

class _WatermarkCameraExamplePageState
    extends State<WatermarkCameraExamplePage> {
  List<FileUploadState> _uploadStates = [];

  void _onAddImages(List<File> newImages) {
    setState(() {
      _uploadStates.addAll(
        newImages.map((file) => FileUploadState.fromFile(file)),
      );
    });

    // 这里可以调用上传逻辑
    _uploadImages(newImages);
  }

  void _onRemoveImage(String uniqueId) {
    setState(() {
      _uploadStates.removeWhere((state) => state.uniqueId == uniqueId);
    });
  }

  void _onRetryUpload(String uniqueId) {
    final state = _uploadStates.firstWhere((s) => s.uniqueId == uniqueId);
    _uploadImages([state.file]);
  }

  Future<void> _uploadImages(List<File> images) async {
    // 模拟上传过程
    for (final image in images) {
      final state = _uploadStates.firstWhere((s) => s.file.path == image.path);
      final index = _uploadStates.indexOf(state);

      // 更新为上传中状态
      setState(() {
        _uploadStates[index] = state.copyWith(status: UploadStatus.uploading);
      });

      // 模拟上传延迟
      await Future.delayed(const Duration(seconds: 2));

      // 模拟上传结果（90%成功率）
      final isSuccess = DateTime.now().millisecondsSinceEpoch % 10 != 0;

      setState(() {
        if (isSuccess) {
          _uploadStates[index] = state.copyWith(
            status: UploadStatus.success,
            // uploadResult: UploadResult(url: 'https://example.com/uploaded/${state.uniqueId}.jpg'),
          );
        } else {
          _uploadStates[index] = state.copyWith(
            status: UploadStatus.failure,
            errorMessage: '网络连接失败，请重试',
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('带水印拍照示例')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基础用法
            const Text(
              '基础用法（默认水印）',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ImageUploadWidget(
              title: '工程照片',
              states: _uploadStates,
              onAdd: _onAddImages,
              onRemove: _onRemoveImage,
              onRetry: _onRetryUpload,
              maxImages: 6,
              requiredPhotoCount: 2,
              enableWatermark: true, // 启用水印
            ),

            const SizedBox(height: 32),

            // 自定义水印
            const Text(
              '自定义水印示例（自动获取位置）',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ImageUploadWidget(
              title: '施工现场照片',
              states: [],
              onAdd: (images) {
                // 处理自定义水印的图片
                print('收到${images.length}张带自定义水印和自动位置的图片');
              },
              onRemove: (id) {},
              onRetry: (id) {},
              maxImages: 3,
              enableWatermark: true,
              watermarkText: '高新供水工程部', // 自定义水印文本
              includeTimeWatermark: true, // 包含时间
              includeLocationWatermark: true, // 包含位置（自动获取）
              // locationText 参数已不再需要，位置信息会自动获取
            ),

            const SizedBox(height: 32),

            // 禁用水印（使用原系统相机）
            const Text(
              '禁用水印（原系统相机）',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ImageUploadWidget(
              title: '普通照片',
              states: [],
              onAdd: (images) {
                print('收到${images.length}张普通图片');
              },
              onRemove: (id) {},
              onRetry: (id) {},
              maxImages: 3,
              enableWatermark: false, // 禁用水印，使用原系统相机
            ),

            const SizedBox(height: 32),

            // 说明文档
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '使用说明',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. enableWatermark: true - 启用带水印的自定义相机\n'
                    '2. enableWatermark: false - 使用原系统相机\n'
                    '3. watermarkText: 自定义水印文本\n'
                    '4. includeTimeWatermark: 是否包含时间水印\n'
                    '5. includeLocationWatermark: 是否包含位置水印（自动获取GPS坐标）\n'
                    '6. locationText: 已废弃，位置信息现在自动获取\n'
                    '\n'
                    '水印会在拍照预览时实时显示，拍照后会自动添加到图片上。\n'
                    '启用位置水印时，系统会自动获取当前GPS坐标并添加到水印中。',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
