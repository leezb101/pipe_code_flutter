/*
 * @Author: LeeZB
 * @Date: 2025-10-10
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-10-10
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_bloc.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_state.dart';
import 'package:pipe_code_flutter/utils/file_type_utils.dart';
import 'package:pipe_code_flutter/widgets/pdf_previewer/pdf_previewer.dart';
import 'package:pipe_code_flutter/widgets/file_upload/image_preview_widget.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// 文件预览辅助 Mixin
///
/// 提供通用的文件预览功能，支持：
/// - 图片预览
/// - PDF 预览
/// - 其他文件下载
mixin FilePreviewMixin {
  /// 为 URL 添加认证 token
  String addAuthToken(BuildContext context, String url) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthLoginSuccess) return url;

    final token = authState.wxLoginVO.tk;
    if (url.contains('?')) {
      return '$url&auth_toke=$token';
    } else {
      return '$url?auth_toke=$token';
    }
  }

  /// 预览文件（根据文件类型自动选择预览方式）
  void previewFile(BuildContext context, String url) {
    final fileType = FileTypeUtils.getFileType(url);
    final urlWithToken = addAuthToken(context, url);

    switch (fileType) {
      case FileType.image:
        _previewImage(context, urlWithToken);
        break;
      case FileType.pdf:
        _previewPdf(context, urlWithToken);
        break;
      case FileType.other:
        _downloadFile(context, urlWithToken);
        break;
    }
  }

  /// 预览图片
  void _previewImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ImagePreviewWidget(imageUrls: [imageUrl], initialIndex: 0),
      ),
    );
  }

  /// 预览 PDF
  void _previewPdf(BuildContext context, String pdfUrl) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => PdfPreviewer(url: pdfUrl)));
  }

  /// 下载文件
  void _downloadFile(BuildContext context, String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          context.showErrorToast('无法打开文件');
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorToast('打开文件失败: $e');
      }
    }
  }

  /// 构建文件图标（根据文件类型）
  Widget buildFileIcon(String url, {double size = 24, Color? color}) {
    final fileType = FileTypeUtils.getFileType(url);
    IconData iconData;
    Color iconColor;

    switch (fileType) {
      case FileType.image:
        iconData = Icons.image;
        iconColor = Colors.blue;
        break;
      case FileType.pdf:
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case FileType.other:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
        break;
    }

    return Icon(iconData, size: size, color: color ?? iconColor);
  }

  /// 构建文件操作按钮（预览或下载）
  Widget buildFileActionButton(
    BuildContext context,
    String url, {
    String? tooltip,
  }) {
    final fileType = FileTypeUtils.getFileType(url);
    final isPreviewable =
        fileType == FileType.image || fileType == FileType.pdf;

    return IconButton(
      icon: Icon(
        isPreviewable ? Icons.visibility : Icons.download,
        color: isPreviewable ? Colors.blue : Colors.grey,
      ),
      onPressed: () => previewFile(context, url),
      tooltip: tooltip ?? (isPreviewable ? '预览' : '下载'),
    );
  }

  /// 获取文件类型标签
  Widget buildFileTypeLabel(String url) {
    final displayName = FileTypeUtils.getFileTypeDisplayName(url);
    final fileType = FileTypeUtils.getFileType(url);

    Color backgroundColor;
    Color textColor;

    switch (fileType) {
      case FileType.image:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case FileType.pdf:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      case FileType.other:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
