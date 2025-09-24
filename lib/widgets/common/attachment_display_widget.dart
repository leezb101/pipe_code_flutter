/*
 * @Author: LeeZB
 * @Date: 2025-07-30 17:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 17:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';

class AttachmentDisplayWidget extends StatelessWidget {
  const AttachmentDisplayWidget({super.key, required this.attachments});

  final List<AttachmentVO> attachments;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: attachments.asMap().entries.map((entry) {
        final index = entry.key;
        final attachment = entry.value;
        return _buildAttachmentItem(attachment, index);
      }).toList(),
    );
  }

  Widget _buildAttachmentItem(AttachmentVO attachment, int index) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _previewAttachment(context, attachment),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildAttachmentContent(attachment),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentContent(AttachmentVO attachment) {
    if (attachment.attachFormat == 'image' ||
        attachment.url.toLowerCase().endsWith('.jpg') ||
        attachment.url.toLowerCase().endsWith('.jpeg') ||
        attachment.url.toLowerCase().endsWith('.png') ||
        attachment.url.toLowerCase().endsWith('.gif') ||
        attachment.url.toLowerCase().endsWith('.webp')) {
      return Image.network(
        attachment.url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      return Container(
        color: Colors.grey[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 32, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                attachment.name ?? '附件',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _previewAttachment(BuildContext context, AttachmentVO attachment) {
    if (attachment.attachFormat == 'image' ||
        (attachment.attachFormat != null &&
            (attachment.attachFormat!.toLowerCase().endsWith('.jpg') ||
                attachment.attachFormat!.toLowerCase().endsWith('.jpeg') ||
                attachment.attachFormat!.toLowerCase().endsWith('.png') ||
                attachment.attachFormat!.toLowerCase().endsWith('.gif') ||
                attachment.attachFormat!.toLowerCase().endsWith('.webp')))) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _ImagePreviewPage(attachment: attachment),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('暂不支持预览此类型文件: ${attachment.name}')),
      );
    }
  }
}

class _ImagePreviewPage extends StatelessWidget {
  const _ImagePreviewPage({required this.attachment});

  final AttachmentVO attachment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(attachment.name ?? '图片预览'),
        centerTitle: true,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            attachment.url,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.white54,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
