/*
 * @Author: LeeZB
 * @Date: 2025-07-08 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-05 11:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/pages/watermark_camera_page.dart';
import 'image_preview_widget.dart';
import 'fade_scale_route.dart';
import 'photo_watermark_preview_page.dart';

class ImageUploadWidget extends StatefulWidget {
  const ImageUploadWidget({
    super.key,
    this.title,
    required this.states,
    required this.onAdd,
    required this.onRemove,
    required this.onRetry,
    this.maxImages = 9,
    this.requiredPhotoCount,
    this.label,
    this.enableWatermark = true,
    this.watermarkText,
    this.includeTimeWatermark = true,
    this.includeLocationWatermark = false,
    this.locationText,
  });

  final String? title;
  final List<FileUploadState> states;
  final Function(List<File>) onAdd;
  final Function(String uniqueId) onRemove;
  final Function(String uniqueId) onRetry;
  final int maxImages;
  final int? requiredPhotoCount;
  final String? label;
  // 水印相关属性
  final bool enableWatermark;
  final String? watermarkText;
  final bool includeTimeWatermark;
  final bool includeLocationWatermark;
  final String? locationText;

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final context = this.context;
    if (widget.states.length >= widget.maxImages) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text('最多只能上传 ${widget.maxImages} 张图片')));
      context.showErrorToast('最多只能上传 ${widget.maxImages} 张图片');
      return;
    }
    try {
      final int remainingSlots = widget.maxImages - widget.states.length;
      List<XFile> pickedFiles = [];

      // 当只能添加1张图片时，使用单张选择；否则使用多选
      if (remainingSlots == 1) {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
          maxWidth: 1920,
        );
        if (pickedFile != null) {
          pickedFiles = [pickedFile];
        }
      } else {
        pickedFiles = await _picker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1920,
          limit: remainingSlots,
        );
      }

      if (pickedFiles.isNotEmpty) {
        // 重新计算剩余可用数量，防止在选择过程中状态发生变化
        final currentRemainingSlots = widget.maxImages - widget.states.length;

        // 截取不超过剩余数量的图片
        final limitedFiles = pickedFiles.take(currentRemainingSlots).toList();

        // 如果选择的图片数量超过了剩余限制，提示用户
        if (pickedFiles.length > currentRemainingSlots) {
          if (context.mounted) {
            context.showWarningToast(
              '最多还能添加 $currentRemainingSlots 张图片，已自动调整为 ${limitedFiles.length} 张',
            );
          }
        }

        final originalImages = limitedFiles
            .map((file) => File(file.path))
            .toList();

        if (widget.enableWatermark) {
          // 显示水印预览页面
          final List<File>? watermarkedImages = await Navigator.of(context)
              .push<List<File>>(
                MaterialPageRoute(
                  builder: (context) => PhotoWatermarkPreviewPage(
                    selectedImages: originalImages,
                    watermarkText: widget.watermarkText,
                    includeTimeWatermark: widget.includeTimeWatermark,
                    includeLocationWatermark: widget.includeLocationWatermark,
                    locationText: widget.locationText,
                  ),
                ),
              );

          if (watermarkedImages != null && watermarkedImages.isNotEmpty) {
            // 再次检查最终要添加的图片数量
            final finalRemainingSlots = widget.maxImages - widget.states.length;
            final finalImages = watermarkedImages
                .take(finalRemainingSlots)
                .toList();

            if (watermarkedImages.length > finalRemainingSlots &&
                context.mounted) {
              context.showWarningToast('最多还能添加 $finalRemainingSlots 张图片');
            }

            widget.onAdd(finalImages);
          }
        } else {
          // 直接使用原图
          widget.onAdd(originalImages);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
      }
    }
  }

  Future<void> _takePicture() async {
    final context = this.context;
    if (widget.states.length >= widget.maxImages) {
      context.showErrorToast('最多只能上传 ${widget.maxImages} 张图片');
      return;
    }

    try {
      if (widget.enableWatermark) {
        // 使用带水印的相机页面
        final String? imagePath = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (context) => WatermarkCameraPage(
              watermarkText: widget.watermarkText,
              includeTimeWatermark: widget.includeTimeWatermark,
              includeLocationWatermark: widget.includeLocationWatermark,
              locationText: widget.locationText,
            ),
          ),
        );

        if (imagePath != null) {
          // 再次检查是否还有剩余空间（防止在拍照过程中状态发生变化）
          if (widget.states.length < widget.maxImages) {
            widget.onAdd([File(imagePath)]);
          } else if (context.mounted) {
            context.showErrorToast('已达到最大上传数量，无法添加更多图片');
          }
        }
      } else {
        // 使用原有的系统相机
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          maxWidth: 1920,
        );
        if (pickedFile != null) {
          // 再次检查是否还有剩余空间
          if (widget.states.length < widget.maxImages) {
            widget.onAdd([File(pickedFile.path)]);
          } else if (context.mounted) {
            context.showErrorToast('已达到最大上传数量，无法添加更多图片');
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('拍照失败: $e')));
      }
    }
  }

  void _previewImages(int initialIndex) {
    // When previewing, we only need the File objects, not the full state.
    final images = widget.states.map((s) => s.file).toList();
    Navigator.of(context).push(
      FadeScaleRoute(
        page: ImagePreviewWidget(
          images: images,
          initialIndex: initialIndex,
          onDelete: (index) {
            // When an image is deleted in the preview, we find its uniqueId
            // from the original state list and call the onRemove callback.
            final uniqueId = widget.states[index].uniqueId;
            widget.onRemove(uniqueId);
            // Also pop the preview screen as the item is gone.
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: const Text('从相册选择'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImages();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text('拍照'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePicture();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.grey),
                  title: const Text('取消'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null && widget.title!.isNotEmpty) ...[
              _buildTitle(),
              const SizedBox(height: 12),
            ],
            _buildImageGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (widget.title != null)
          Text(
            widget.title!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        const SizedBox(width: 8),
        Text(
          '(${widget.states.length}/${widget.maxImages})',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        if (widget.requiredPhotoCount != null &&
            widget.requiredPhotoCount! > 0) ...[
          const SizedBox(width: 8),
          Text(
            '(至少${widget.requiredPhotoCount}张)',
            style: TextStyle(fontSize: 14, color: Colors.red[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildImageGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...widget.states.asMap().entries.map((entry) {
          final index = entry.key;
          final state = entry.value;
          return _buildImageItem(state, index);
        }),
        if (widget.states.length < widget.maxImages) _buildAddImageButton(),
      ],
    );
  }

  Widget _buildImageItem(FileUploadState state, int index) {
    return Hero(
      tag: 'image_upload_${state.uniqueId}',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Image container
          GestureDetector(
            onTap: () =>
                (state.status == UploadStatus.success ||
                    state.status == UploadStatus.initial)
                ? _previewImages(index)
                : null,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  state.file,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
          ),
          // Overlay for upload status
          Positioned.fill(child: _buildStatusOverlay(state)),
          // Remove button
          if (state.status != UploadStatus.uploading)
            Positioned(
              top: -8,
              right: -8,
              child: GestureDetector(
                onTap: () => widget.onRemove(state.uniqueId),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusOverlay(FileUploadState state) {
    switch (state.status) {
      case UploadStatus.uploading:
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                value: state.progress > 0 ? state.progress : null,
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
          ),
        );
      case UploadStatus.failure:
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 28),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    widget.onRetry(state.uniqueId);
                  },
                  child: const Text(
                    '重试',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      case UploadStatus.success:
        // 用 IgnorePointer 避免 overlay 拦截手势，保证图片可点击预览
        return IgnorePointer(
          ignoring: true,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.check_circle, color: Colors.white, size: 32),
            ),
          ),
        );
      case UploadStatus.initial:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAddImageButton() {
    // The button should be disabled if we are already at max capacity.
    final bool canAdd = widget.states.length < widget.maxImages;
    return GestureDetector(
      onTap: canAdd ? _showImageOptions : null,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(12),
          dashPattern: const [6, 4],
          color: canAdd ? Colors.grey[400]! : Colors.grey[300]!,
          strokeWidth: 1.5,
        ),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: canAdd ? Colors.grey[50] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 32,
                color: canAdd ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: 4),
              Text(
                '添加照片',
                style: TextStyle(
                  fontSize: 12,
                  color: canAdd ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
