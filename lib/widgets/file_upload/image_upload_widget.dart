/*
 * @Author: LeeZB
 * @Date: 2025-07-08 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-04 18:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'image_preview_widget.dart';

class ImageUploadWidget extends StatefulWidget {
  const ImageUploadWidget({
    super.key,
    this.title,
    required this.onImagesChanged,
    this.maxImages = 9,
    this.requiredPhotoCount,
    this.initialImages = const [],
    this.label,
  });

  final String? title;
  final Function(List<File>) onImagesChanged;
  final int maxImages;
  final int? requiredPhotoCount;
  final List<File> initialImages;
  final String? label;

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  @override
  void didUpdateWidget(covariant ImageUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Allow external changes to update the internal list of images.
    if (widget.initialImages != oldWidget.initialImages) {
      setState(() {
        _images = List.from(widget.initialImages);
      });
    }
  }

  Future<void> _pickImages() async {
    final context = this.context;
    if (_images.length >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多只能上传 ${widget.maxImages} 张图片')),
      );
      return;
    }
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
      );
      if (pickedFiles.isNotEmpty) {
        final List<File> newImages =
            pickedFiles.map((file) => File(file.path)).toList();
        setState(() {
          _images.addAll(newImages);
          if (_images.length > widget.maxImages) {
            _images = _images.take(widget.maxImages).toList();
          }
        });
        widget.onImagesChanged(_images);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
      }
    }
  }

  Future<void> _takePicture() async {
    final context = this.context;
    if (_images.length >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多只能上传 ${widget.maxImages} 张图片')),
      );
      return;
    }
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
      );
      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
        widget.onImagesChanged(_images);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('拍照失败: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    widget.onImagesChanged(_images);
  }

  void _previewImages(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImagePreviewWidget(
          images: _images,
          initialIndex: initialIndex,
          onDelete: (index) {
            _removeImage(index);
          },
          onImagesChanged: (updatedImages) {
            setState(() {
              _images = updatedImages;
            });
            widget.onImagesChanged(_images);
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
          '(${_images.length}/${widget.maxImages})',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        if (widget.requiredPhotoCount != null &&
            widget.requiredPhotoCount! > 0) ...[
          const SizedBox(width: 8),
          Text(
            '(至少${widget.requiredPhotoCount}张)',
            style: TextStyle(fontSize: 14, color: Colors.red[600]),
          ),
        ]
      ],
    );
  }

  Widget _buildImageGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ..._images.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;
          return _buildImageItem(image, index);
        }),
        if (_images.length < widget.maxImages) _buildAddImageButton(),
      ],
    );
  }

  Widget _buildImageItem(File image, int index) {
    return Hero(
      tag: 'image_upload_${image.path}_$index',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () => _previewImages(index),
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
                  image,
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
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
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

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _showImageOptions,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: const [6, 4],
        color: Colors.grey[400]!,
        strokeWidth: 1.5,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 32,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                '添加照片',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}