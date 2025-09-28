/*
 * @Author: LeeZB
 * @Date: 2025-09-28
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-28
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pipe_code_flutter/services/location_service.dart';

class ImageWatermarkUtils {
  /// 给图片添加文字水印
  static Future<String?> addTextWatermark(
    String imagePath,
    String watermarkText, {
    TextStyle? textStyle,
    Alignment alignment = Alignment.bottomRight,
    EdgeInsets padding = const EdgeInsets.all(20),
    Color backgroundColor = const Color.fromRGBO(0, 0, 0, 0.6),
  }) async {
    try {
      // 读取原始图片
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image originalImage = frameInfo.image;

      // 创建画布
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Size imageSize = Size(
        originalImage.width.toDouble(),
        originalImage.height.toDouble(),
      );

      // 绘制原始图片
      canvas.drawImage(originalImage, Offset.zero, Paint());

      // 准备水印文字样式
      // Canvas渲染在图像像素级别工作，不需要考虑设备像素密度
      final TextStyle finalTextStyle =
          textStyle ??
          const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          );

      // 创建文字绘制器
      final TextSpan textSpan = TextSpan(
        text: watermarkText,
        style: finalTextStyle,
      );
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // 计算水印位置
      final Size textSize = textPainter.size;
      final double paddingHorizontal = 12.0;
      final double paddingVertical = 6.0;
      final Size backgroundSize = Size(
        textSize.width + paddingHorizontal * 2,
        textSize.height + paddingVertical * 2,
      );

      Offset watermarkOffset;
      switch (alignment) {
        case Alignment.topLeft:
          watermarkOffset = Offset(padding.left, padding.top);
          break;
        case Alignment.topCenter:
          watermarkOffset = Offset(
            (imageSize.width - backgroundSize.width) / 2,
            padding.top,
          );
          break;
        case Alignment.topRight:
          watermarkOffset = Offset(
            imageSize.width - backgroundSize.width - padding.right,
            padding.top,
          );
          break;
        case Alignment.centerLeft:
          watermarkOffset = Offset(
            padding.left,
            (imageSize.height - backgroundSize.height) / 2,
          );
          break;
        case Alignment.center:
          watermarkOffset = Offset(
            (imageSize.width - backgroundSize.width) / 2,
            (imageSize.height - backgroundSize.height) / 2,
          );
          break;
        case Alignment.centerRight:
          watermarkOffset = Offset(
            imageSize.width - backgroundSize.width - padding.right,
            (imageSize.height - backgroundSize.height) / 2,
          );
          break;
        case Alignment.bottomLeft:
          watermarkOffset = Offset(
            padding.left,
            imageSize.height - backgroundSize.height - padding.bottom,
          );
          break;
        case Alignment.bottomCenter:
          watermarkOffset = Offset(
            (imageSize.width - backgroundSize.width) / 2,
            imageSize.height - backgroundSize.height - padding.bottom,
          );
          break;
        case Alignment.bottomRight:
        default:
          watermarkOffset = Offset(
            imageSize.width - backgroundSize.width - padding.right,
            imageSize.height - backgroundSize.height - padding.bottom,
          );
          break;
      }

      // 绘制背景
      final Paint backgroundPaint = Paint()..color = backgroundColor;
      final RRect backgroundRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          watermarkOffset.dx,
          watermarkOffset.dy,
          backgroundSize.width,
          backgroundSize.height,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(backgroundRect, backgroundPaint);

      // 绘制文字
      final Offset textOffset = Offset(
        watermarkOffset.dx + paddingHorizontal,
        watermarkOffset.dy + paddingVertical,
      );
      textPainter.paint(canvas, textOffset);

      // 完成绘制
      final ui.Picture picture = recorder.endRecording();
      final ui.Image finalImage = await picture.toImage(
        imageSize.width.toInt(),
        imageSize.height.toInt(),
      );

      // 转换为字节数据
      final ByteData? byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        return null;
      }

      // 保存到临时文件
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'watermarked_${DateTime.now().millisecondsSinceEpoch}.png';
      final String outputPath = path.join(tempDir.path, fileName);
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(byteData.buffer.asUint8List());

      // 释放资源
      originalImage.dispose();
      finalImage.dispose();

      return outputPath;
    } catch (e) {
      print('添加水印失败: $e');
      return null;
    }
  }

  /// 给图片添加自动生成的水印（包含位置信息）
  static Future<String?> addAutoWatermark(
    String imagePath, {
    String? customText,
    bool includeTime = true,
    bool includeLocation = false,
    String? locationText, // 已废弃，仅保留向后兼容性
    TextStyle? textStyle,
    Alignment alignment = Alignment.bottomRight,
    EdgeInsets padding = const EdgeInsets.all(20),
    Color backgroundColor = const Color.fromRGBO(0, 0, 0, 0.6),
  }) async {
    // 生成带位置信息的水印文本
    final watermarkText = await generateDefaultWatermarkText(
      customText: customText,
      includeTime: includeTime,
      includeLocation: includeLocation,
      locationText: locationText,
    );

    // 获取图片尺寸以计算合适的字体大小
    final File imageFile = File(imagePath);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image originalImage = frameInfo.image;

    // 根据图片宽度动态计算字体大小
    // 以1080p为基准（1920x1080），字体大小为48
    // 这样在各种分辨率下都能保持合适的比例
    final double baseFontSize = (originalImage.width / 1920.0) * 48.0;
    final double fontSize = baseFontSize.clamp(32.0, 96.0); // 限制字体大小范围

    // 释放临时资源
    originalImage.dispose();

    // 使用计算出的字体大小
    final TextStyle finalTextStyle =
        textStyle?.copyWith(fontSize: fontSize) ??
        TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        );

    // 添加水印
    return await addTextWatermark(
      imagePath,
      watermarkText,
      textStyle: finalTextStyle,
      alignment: alignment,
      padding: padding,
      backgroundColor: backgroundColor,
    );
  }

  /// 生成默认的水印文本（包含时间和位置等信息）
  static Future<String> generateDefaultWatermarkText({
    String? customText,
    bool includeTime = true,
    bool includeLocation = false,
    String? locationText, // 已废弃，保留向后兼容性
  }) async {
    final StringBuffer buffer = StringBuffer();

    if (customText != null && customText.isNotEmpty) {
      buffer.write(customText);
      if (includeTime || includeLocation) {
        buffer.write('\n');
      }
    }

    if (includeTime) {
      final DateTime now = DateTime.now();
      buffer.write(
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ',
      );
      buffer.write(
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      );
    }

    if (includeLocation) {
      String? locationInfo;

      // 优先使用传入的locationText（向后兼容）
      if (locationText != null && locationText.isNotEmpty) {
        locationInfo = locationText;
      } else {
        // 自动获取位置信息
        try {
          final location = await LocationService.getCurrentLocation();
          if (location != null) {
            // 格式化位置信息，保留4位小数
            locationInfo =
                '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
          }
        } catch (e) {
          print('获取位置信息失败: $e');
          // 如果获取失败，使用默认文本
          locationInfo = '位置信息获取失败';
        }
      }

      if (locationInfo != null) {
        if (includeTime) {
          buffer.write('\n');
        }
        buffer.write(locationInfo);
      }
    }

    return buffer.toString();
  }

  /// 同步版本的水印文本生成（不包含自动位置获取）
  /// 主要用于向后兼容和预览显示
  static String generateDefaultWatermarkTextSync({
    String? customText,
    bool includeTime = true,
    bool includeLocation = false,
    String? locationText,
  }) {
    final StringBuffer buffer = StringBuffer();

    if (customText != null && customText.isNotEmpty) {
      buffer.write(customText);
      if (includeTime || (includeLocation && locationText != null)) {
        buffer.write('\n');
      }
    }

    if (includeTime) {
      final DateTime now = DateTime.now();
      buffer.write(
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ',
      );
      buffer.write(
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      );
    }

    if (includeLocation && locationText != null && locationText.isNotEmpty) {
      if (includeTime) {
        buffer.write('\n');
      }
      buffer.write(locationText);
    }

    return buffer.toString();
  }
}
