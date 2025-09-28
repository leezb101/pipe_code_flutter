/*
 * @Author: LeeZB
 * @Date: 2025-09-28 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-28 15:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/utils/image_watermark_utils.dart';

class PhotoWatermarkPreviewPage extends StatefulWidget {
  const PhotoWatermarkPreviewPage({
    super.key,
    required this.selectedImages,
    this.watermarkText,
    this.includeTimeWatermark = true,
    this.includeLocationWatermark = false,
    this.locationText,
  });

  final List<File> selectedImages;
  final String? watermarkText;
  final bool includeTimeWatermark;
  final bool includeLocationWatermark;
  final String? locationText;

  @override
  State<PhotoWatermarkPreviewPage> createState() =>
      _PhotoWatermarkPreviewPageState();
}

class _PhotoWatermarkPreviewPageState extends State<PhotoWatermarkPreviewPage> {
  bool _isProcessing = false;
  int _currentIndex = 0;
  List<Uint8List?> _previewImages = [];

  @override
  void initState() {
    super.initState();
    _previewImages = List.filled(widget.selectedImages.length, null);
    _generatePreviews();
  }

  Future<void> _generatePreviews() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      for (int i = 0; i < widget.selectedImages.length; i++) {
        // 生成预览图（带水印的缩略图）
        final previewBytes = await _generatePreviewImage(
          widget.selectedImages[i],
        );
        if (previewBytes != null) {
          _previewImages[i] = previewBytes;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('生成预览失败: $e')));
      }
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<Uint8List?> _generatePreviewImage(File imageFile) async {
    try {
      // 生成预览用的水印图片（使用与拍照功能相同的方法）
      final watermarkedFilePath = await ImageWatermarkUtils.addAutoWatermark(
        imageFile.path,
        customText: widget.watermarkText,
        includeTime: widget.includeTimeWatermark,
        includeLocation: widget.includeLocationWatermark,
        locationText: widget.locationText,
      );

      if (watermarkedFilePath != null) {
        final watermarkedFile = File(watermarkedFilePath);
        final bytes = await watermarkedFile.readAsBytes();
        // 删除临时文件
        try {
          await watermarkedFile.delete();
        } catch (e) {
          // 忽略删除错误
        }
        return bytes;
      }
    } catch (e) {
      print('生成预览水印失败: $e');
    }
    return null;
  }

  Future<void> _processAndConfirm() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      List<File> processedImages = [];

      for (int i = 0; i < widget.selectedImages.length; i++) {
        final watermarkedFile = await _generateWatermarkedImage(
          widget.selectedImages[i],
        );
        if (watermarkedFile != null) {
          processedImages.add(watermarkedFile);
        }
      }

      if (mounted) {
        Navigator.of(context).pop(processedImages);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('处理图片失败: $e')));
      }
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<File?> _generateWatermarkedImage(File imageFile) async {
    try {
      final watermarkedFilePath = await ImageWatermarkUtils.addAutoWatermark(
        imageFile.path,
        customText: widget.watermarkText,
        includeTime: widget.includeTimeWatermark,
        includeLocation: widget.includeLocationWatermark,
        locationText: widget.locationText,
      );

      if (watermarkedFilePath != null) {
        return File(watermarkedFilePath);
      }

      return null;
    } catch (e) {
      print('生成水印图片失败: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: Text(
          '水印预览 (${_currentIndex + 1}/${widget.selectedImages.length})',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (!_isProcessing)
            TextButton(
              onPressed: _processAndConfirm,
              child: const Text(
                '确认使用',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    '正在处理图片...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // 主要预览区域
                Expanded(
                  child: PageView.builder(
                    itemCount: widget.selectedImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          child: _previewImages[index] != null
                              ? InteractiveViewer(
                                  child: Image.memory(
                                    _previewImages[index]!,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),

                // 底部缩略图栏（如果有多张图片）
                if (widget.selectedImages.length > 1)
                  Container(
                    height: 80,
                    margin: const EdgeInsets.all(16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.selectedImages.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _currentIndex == index
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: _previewImages[index] != null
                                  ? Image.memory(
                                      _previewImages[index]!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey[700],
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // 说明文字
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '预览带水印的效果，点击"确认使用"将添加水印并上传',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}
