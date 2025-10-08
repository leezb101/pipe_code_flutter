import '../../models/common/document_discriptor.dart';

abstract class DocumentService {
  Stream<DownloadProgress> downloadDocument(DocumentDescriptor descriptor);

  void cancel();

  /// 可选：暂停、恢复下载，后续扩展
}

class DownloadProgress {
  final int received;
  final int total;
  final bool isCompleted;
  final String? filePath;

  double get progress => total == 0 ? 0 : received / total;

  const DownloadProgress({
    required this.received,
    required this.total,
    this.isCompleted = false,
    this.filePath,
  });
}
