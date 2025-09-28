/*
 * @Author: LeeZB
 * @Date: 2025-09-28
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-28
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../bloc/camera/camera_cubit.dart';
import '../widgets/camera_preview_with_watermark.dart';
import '../utils/image_watermark_utils.dart';

class WatermarkCameraPage extends StatefulWidget {
  final String? watermarkText;
  final bool includeTimeWatermark;
  final bool includeLocationWatermark;
  final String? locationText;

  const WatermarkCameraPage({
    super.key,
    this.watermarkText,
    this.includeTimeWatermark = true,
    this.includeLocationWatermark = false,
    this.locationText,
  });

  @override
  State<WatermarkCameraPage> createState() => _WatermarkCameraPageState();
}

class _WatermarkCameraPageState extends State<WatermarkCameraPage> {
  late CameraCubit _cameraCubit;
  String _watermarkDisplayText = '';

  @override
  void initState() {
    super.initState();
    _cameraCubit = CameraCubit();
    _cameraCubit.initializeCamera();
    _generateWatermarkDisplayText();
  }

  @override
  void dispose() {
    _cameraCubit.dispose();
    super.dispose();
  }

  /// 生成用于预览显示的水印文本
  Future<void> _generateWatermarkDisplayText() async {
    String displayText = '';

    if (widget.includeLocationWatermark) {
      // 如果需要位置信息，使用异步方法获取
      displayText = await ImageWatermarkUtils.generateDefaultWatermarkText(
        customText: widget.watermarkText,
        includeTime: widget.includeTimeWatermark,
        includeLocation: widget.includeLocationWatermark,
        locationText: widget.locationText,
      );
    } else {
      // 如果不需要位置信息，使用同步方法
      displayText = ImageWatermarkUtils.generateDefaultWatermarkTextSync(
        customText: widget.watermarkText,
        includeTime: widget.includeTimeWatermark,
        includeLocation: false,
        locationText: widget.locationText,
      );
    }

    if (mounted) {
      setState(() {
        _watermarkDisplayText = displayText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('拍照'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<CameraCubit, CameraState>(
        bloc: _cameraCubit,
        listener: (context, state) {
          if (state.status == CameraStatus.error && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // 相机预览
              _buildCameraPreview(state),
              // 底部控制栏
              _buildBottomControls(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraPreview(CameraState state) {
    switch (state.status) {
      case CameraStatus.initial:
      case CameraStatus.initializing:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                '正在初始化相机...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        );

      case CameraStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                state.error ?? '未知错误',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _cameraCubit.initializeCamera(),
                child: const Text('重试'),
              ),
            ],
          ),
        );

      case CameraStatus.ready:
      case CameraStatus.capturing:
        if (state.controller != null) {
          // 根据相机分辨率计算预览水印的合适字体大小
          final double previewFontSize = _calculatePreviewFontSize(
            state.controller!,
          );

          return CameraPreviewWithWatermark(
            controller: state.controller!,
            watermarkText: _watermarkDisplayText,
            watermarkStyle: TextStyle(
              color: Colors.white,
              fontSize: previewFontSize,
              fontWeight: FontWeight.w500,
            ),
          );
        }
        return const Center(
          child: Text(
            '相机未就绪',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
    }
  }

  /// 根据相机分辨率计算预览水印的合适字体大小
  double _calculatePreviewFontSize(CameraController controller) {
    if (!controller.value.isInitialized) {
      return 16.0; // 默认字体大小
    }

    // 获取相机预览尺寸和屏幕信息
    final Size previewSize = controller.value.previewSize!;
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;

    // 获取相机的实际分辨率宽度（通常previewSize中较大的值是宽度）
    final double cameraWidth = previewSize.width > previewSize.height
        ? previewSize.width
        : previewSize.height;

    // 计算最终图像会使用的字体大小（与ImageWatermarkUtils中的算法一致）
    final double baseFontSize = (cameraWidth / 1920.0) * 48.0;
    final double finalImageFontSize = baseFontSize.clamp(32.0, 96.0);

    // 计算预览中应该显示的字体大小
    // 预览是在屏幕上显示的，需要考虑屏幕宽度与相机分辨率的比例
    final double previewScale = screenWidth / cameraWidth;
    final double previewFontSize = finalImageFontSize * previewScale;

    // 限制预览字体大小在合理范围内，并稍微增加以匹配最终图片
    return (previewFontSize * 1.2).clamp(10.0, 64.0);
  }

  Widget _buildBottomControls(CameraState state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 返回按钮
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
            ),

            // 拍照按钮
            GestureDetector(
              onTap: state.status == CameraStatus.ready ? _takePicture : null,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: state.status == CameraStatus.capturing
                      ? Colors.grey
                      : Colors.transparent,
                ),
                child: state.status == CameraStatus.capturing
                    ? const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const Icon(Icons.camera, color: Colors.white, size: 32),
              ),
            ),

            // 占位空间保持对称
            const SizedBox(width: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _takePicture() async {
    try {
      // 拍照
      final String? imagePath = await _cameraCubit.takePicture();
      if (imagePath == null) {
        return;
      }

      // 使用自动水印方法添加水印（包含自动位置获取）
      final String? watermarkedImagePath =
          await ImageWatermarkUtils.addAutoWatermark(
            imagePath,
            customText: widget.watermarkText,
            includeTime: widget.includeTimeWatermark,
            includeLocation: widget.includeLocationWatermark,
            locationText: widget.locationText, // 仅用于向后兼容
            // 不再指定 textStyle，让系统根据图片分辨率自动计算字体大小
          );

      if (watermarkedImagePath != null && mounted) {
        // 删除临时文件（原始无水印图片）
        try {
          await File(imagePath).delete();
        } catch (e) {
          // 忽略删除错误
        }

        // 返回带水印的图片路径
        Navigator.of(context).pop(watermarkedImagePath);
      } else if (mounted) {
        // 如果添加水印失败，返回原始图片
        Navigator.of(context).pop(imagePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
