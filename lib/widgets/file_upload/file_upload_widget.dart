/*
 * @Author: LeeZB
 * @Date: 2025-07-08 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-05 11:30:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';

class FileUploadWidget extends StatefulWidget {
  const FileUploadWidget({
    super.key,
    required this.title,
    required this.states,
    required this.onAdd,
    required this.onRemove,
    required this.onRetry,
    this.allowedExtensions = const ['pdf', 'jpg', 'png', 'heic'],
    this.maxFiles = 5,
    this.enableGalleryPicker = true,
  });

  final String title;
  final List<FileUploadState> states;
  final Function(List<File>) onAdd;
  final Function(String uniqueId) onRemove;
  final Function(String uniqueId) onRetry;
  final List<String> allowedExtensions;
  final int maxFiles;

  /// 是否启用相册选择器，默认为 true
  /// 当设置为 false 时，点击上传按钮将直接打开文件选择器
  final bool enableGalleryPicker;

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final ImagePicker _imagePicker = ImagePicker();

  /// 从系统文件管理器选择文件
  Future<void> _pickFiles() async {
    final context = this.context;
    if (widget.states.length >= widget.maxFiles) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('最多只能上传 ${widget.maxFiles} 个文件')));
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: true,
      );

      if (result != null) {
        final newFiles = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
        widget.onAdd(newFiles);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('选择文件失败: $e')));
      }
    }
  }

  /// 从相册选择图片（仅选择图片格式文件）
  Future<void> _pickImagesFromGallery() async {
    final context = this.context;
    if (widget.states.length >= widget.maxFiles) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('最多只能上传 ${widget.maxFiles} 个文件')));
      return;
    }

    try {
      final int remainingSlots = widget.maxFiles - widget.states.length;
      List<XFile> pickedFiles = [];

      // 当只能添加1个文件时，使用单张选择；否则使用多选
      if (remainingSlots == 1) {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
          maxWidth: 1920,
        );
        if (pickedFile != null) {
          pickedFiles = [pickedFile];
        }
      } else {
        pickedFiles = await _imagePicker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1920,
          limit: remainingSlots,
        );
      }

      if (pickedFiles.isNotEmpty) {
        // 重新计算剩余可用数量，防止在选择过程中状态发生变化
        final currentRemainingSlots = widget.maxFiles - widget.states.length;

        // 截取不超过剩余数量的文件
        final limitedFiles = pickedFiles.take(currentRemainingSlots).toList();

        // 如果选择的文件数量超过了剩余限制，提示用户
        if (pickedFiles.length > currentRemainingSlots && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '最多还能添加 $currentRemainingSlots 个文件，已自动调整为 ${limitedFiles.length} 个',
              ),
            ),
          );
        }

        final newFiles = limitedFiles.map((file) => File(file.path)).toList();
        widget.onAdd(newFiles);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
      }
    }
  }

  /// 显示选择上传方式的弹窗
  void _showUploadOptions() {
    // 如果禁用相册选择，直接打开文件选择器
    if (!widget.enableGalleryPicker) {
      _pickFiles();
      return;
    }

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
                  subtitle: const Text('选择图片文件'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImagesFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder_open, color: Colors.orange),
                  title: const Text('从文件选择'),
                  subtitle: Text(
                    '支持格式: ${widget.allowedExtensions.join(', ')}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFiles();
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

  String _getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String extension) {
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${widget.states.length}/${widget.maxFiles})',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFileList(),
        const SizedBox(height: 12),
        if (widget.states.length < widget.maxFiles) _buildAddFileButton(),
      ],
    );
  }

  Widget _buildFileList() {
    if (widget.states.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: widget.states.map((state) {
        return _buildFileItem(state);
      }).toList(),
    );
  }

  Widget _buildFileItem(FileUploadState state) {
    final fileName = state.file.path.split('/').last;
    final extension = _getFileExtension(fileName);
    final fileIcon = _getFileIcon(extension);
    final fileColor = _getFileColor(extension);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(fileIcon, size: 24, color: fileColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getStatusText(state),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(state),
                      ),
                    ),
                  ],
                ),
              ),
              if (state.status != UploadStatus.uploading)
                IconButton(
                  onPressed: () => widget.onRemove(state.uniqueId),
                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                ),
              if (state.status == UploadStatus.failure)
                IconButton(
                  onPressed: () => widget.onRetry(state.uniqueId),
                  icon: const Icon(Icons.refresh, size: 18, color: Colors.blue),
                ),
            ],
          ),
          if (state.status == UploadStatus.uploading) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: state.progress > 0 ? state.progress : null,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText(FileUploadState state) {
    switch (state.status) {
      case UploadStatus.uploading:
        final percent = (state.progress * 100).toStringAsFixed(0);
        return '正在上传... $percent%';
      case UploadStatus.success:
        return '上传成功';
      case UploadStatus.failure:
        return '上传失败: ${state.errorMessage ?? '未知错误'}';
      default:
        final fileName = state.file.path.split('/').last;
        final extension = _getFileExtension(fileName);
        return '${extension.toUpperCase()} 文件';
    }
  }

  Color _getStatusColor(FileUploadState state) {
    switch (state.status) {
      case UploadStatus.uploading:
        return Colors.blue;
      case UploadStatus.success:
        return Colors.green;
      case UploadStatus.failure:
        return Colors.red;
      default:
        return Colors.grey[600]!;
    }
  }

  Widget _buildAddFileButton() {
    final bool canAdd = widget.states.length < widget.maxFiles;
    return GestureDetector(
      onTap: canAdd ? _showUploadOptions : null,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(8),
          dashPattern: const [8, 4],
          color: canAdd ? Colors.blue : Colors.grey,
          strokeWidth: 2,
        ),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: canAdd
                ? Colors.blue.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload,
                size: 24,
                color: canAdd ? Colors.blue[600] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                '点击上传文件',
                style: TextStyle(
                  fontSize: 14,
                  color: canAdd ? Colors.blue[600] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${widget.allowedExtensions.join(', ')})',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
