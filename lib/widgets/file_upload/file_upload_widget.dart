/*
 * @Author: LeeZB
 * @Date: 2025-07-08 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-08 15:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class FileUploadWidget extends StatefulWidget {
  const FileUploadWidget({
    super.key,
    required this.title,
    required this.onFilesChanged,
    this.allowedExtensions = const ['pdf', 'doc', 'docx'],
    this.maxFiles = 5,
    this.initialFiles = const [],
  });

  final String title;
  final Function(List<File>) onFilesChanged;
  final List<String> allowedExtensions;
  final int maxFiles;
  final List<File> initialFiles;

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _files = List.from(widget.initialFiles);
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: true,
      );

      if (result != null) {
        final List<File> newFiles = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
        
        setState(() {
          _files.addAll(newFiles);
          if (_files.length > widget.maxFiles) {
            _files = _files.take(widget.maxFiles).toList();
          }
        });
        widget.onFilesChanged(_files);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择文件失败: $e')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
    widget.onFilesChanged(_files);
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
              '(${_files.length}/${widget.maxFiles})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFileList(),
        const SizedBox(height: 12),
        if (_files.length < widget.maxFiles) _buildAddFileButton(),
      ],
    );
  }

  Widget _buildFileList() {
    if (_files.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: _files.asMap().entries.map((entry) {
        final index = entry.key;
        final file = entry.value;
        return _buildFileItem(file, index);
      }).toList(),
    );
  }

  Widget _buildFileItem(File file, int index) {
    final fileName = file.path.split('/').last;
    final extension = _getFileExtension(fileName);
    final fileIcon = _getFileIcon(extension);
    final fileColor = _getFileColor(extension);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            fileIcon,
            size: 24,
            color: fileColor,
          ),
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
                  '${extension.toUpperCase()} 文件',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeFile(index),
            icon: const Icon(
              Icons.close,
              size: 18,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFileButton() {
    return GestureDetector(
      onTap: _pickFiles,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(8),
        dashPattern: const [8, 4],
        color: Colors.blue,
        strokeWidth: 2,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload,
                size: 24,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Text(
                '点击上传文件',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${widget.allowedExtensions.join(', ')})',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}