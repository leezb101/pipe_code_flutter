/*
 * @Author: LeeZB
 * @Date: 2025-10-10
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-10-10
 * @copyright: Copyright © 2025 高新供水.
 */

/// 文件类型枚举
enum FileType { image, pdf, other }

/// 文件类型识别工具类
class FileTypeUtils {
  // 图片格式扩展名
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'heic',
    'heif',
  ];

  // PDF 格式扩展名
  static const List<String> pdfExtensions = ['pdf'];

  /// 从 URL 中提取文件扩展名
  ///
  /// 支持的 URL 格式：
  /// - https://host.com/path/file.jpg
  /// - https://host.com/path/file.jpg?download=0
  /// - https://host.com/path/file.jpg?download=0&auth_toke=xxx
  /// - https://host.com/path/file.jpg?auth_toke=xxx
  static String? getFileExtension(String url) {
    try {
      // 移除 query 参数和 fragment
      final cleanUrl = url.split('?').first.split('#').first;

      // 获取文件名部分
      final uri = Uri.parse(cleanUrl);
      final path = uri.path;

      // 从路径中提取文件名
      final segments = path.split('/');
      if (segments.isEmpty) return null;

      final fileName = segments.last;

      // 提取扩展名
      final parts = fileName.split('.');
      if (parts.length < 2) return null;

      return parts.last.toLowerCase();
    } catch (e) {
      // Fallback: 简单的字符串分割
      try {
        final cleanUrl = url.split('?').first.split('#').first;
        final parts = cleanUrl.split('.');
        if (parts.length >= 2) {
          return parts.last.toLowerCase();
        }
      } catch (_) {
        return null;
      }
      return null;
    }
  }

  /// 判断是否为图片文件
  static bool isImage(String url) {
    final extension = getFileExtension(url);
    if (extension == null) return false;
    return imageExtensions.contains(extension);
  }

  /// 判断是否为 PDF 文件
  static bool isPdf(String url) {
    final extension = getFileExtension(url);
    if (extension == null) return false;
    return pdfExtensions.contains(extension);
  }

  /// 获取文件类型
  static FileType getFileType(String url) {
    if (isImage(url)) return FileType.image;
    if (isPdf(url)) return FileType.pdf;
    return FileType.other;
  }

  /// 从 URL 中提取文件名（不含扩展名）
  static String getFileNameWithoutExtension(String url) {
    try {
      final cleanUrl = url.split('?').first.split('#').first;
      final uri = Uri.parse(cleanUrl);
      final segments = uri.path.split('/');
      if (segments.isEmpty) return 'unknown';

      final fileName = Uri.decodeComponent(segments.last);
      final parts = fileName.split('.');
      if (parts.length > 1) {
        return parts.sublist(0, parts.length - 1).join('.');
      }
      return fileName;
    } catch (_) {
      return 'unknown';
    }
  }

  /// 从 URL 中提取完整文件名
  static String getFileName(String url) {
    try {
      final cleanUrl = url.split('?').first.split('#').first;
      final uri = Uri.parse(cleanUrl);
      final segments = uri.path.split('/');
      if (segments.isEmpty) return 'unknown';
      return Uri.decodeComponent(segments.last);
    } catch (_) {
      // Fallback
      final cleanUrl = url.split('?').first.split('#').first;
      final parts = cleanUrl.split('/');
      return parts.isNotEmpty ? parts.last : 'unknown';
    }
  }

  /// 获取文件类型的图标
  static String getFileTypeIcon(String url) {
    final fileType = getFileType(url);
    switch (fileType) {
      case FileType.image:
        return '📷';
      case FileType.pdf:
        return '📄';
      case FileType.other:
        return '📎';
    }
  }

  /// 获取文件类型的显示名称
  static String getFileTypeDisplayName(String url) {
    final fileType = getFileType(url);
    switch (fileType) {
      case FileType.image:
        return '图片';
      case FileType.pdf:
        return 'PDF';
      case FileType.other:
        final ext = getFileExtension(url);
        return ext != null ? ext.toUpperCase() : '文件';
    }
  }
}
