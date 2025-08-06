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
    this.allowedExtensions = const ['pdf', 'doc', 'docx'],
    this.maxFiles = 5,
  });

  final String title;
  final List<FileUploadState> states;
  final Function(List<File>) onAdd;
  final Function(String uniqueId) onRemove;
  final Function(String uniqueId) onRetry;
  final List<String> allowedExtensions;
  final int maxFiles;

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
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
      onTap: canAdd ? _pickFiles : null,
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
                ? Colors.blue.withOpacity(0.05)
                : Colors.grey.withOpacity(0.05),
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
