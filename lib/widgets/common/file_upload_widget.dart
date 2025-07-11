/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:05:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';

/// 文件上传组件
class FileUploadWidget extends StatelessWidget {
  final String? fileName;
  final String? fileUrl;
  final VoidCallback? onUpload;
  final VoidCallback? onRemove;
  final bool isUploading;

  const FileUploadWidget({
    super.key,
    this.fileName,
    this.fileUrl,
    this.onUpload,
    this.onRemove,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_file,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName ?? '未选择文件',
              style: TextStyle(
                color: fileName != null ? Colors.black87 : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUploading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (fileName != null) ...[
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.close,
                color: Colors.red,
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ] else
            IconButton(
              onPressed: onUpload,
              icon: Icon(
                Icons.upload_file,
                color: Colors.blue,
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}