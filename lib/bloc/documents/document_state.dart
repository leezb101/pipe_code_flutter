import 'package:equatable/equatable.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object> get props => [];
}

class DownloadIdle extends DocumentState {}

class DownloadChecking extends DocumentState {}

class DownloadInProgress extends DocumentState {
  final double? progress; // 0-100
  final int? receivedBytes;
  final int? totalBytes;

  const DownloadInProgress(this.progress, this.receivedBytes, this.totalBytes);

  @override
  List<Object> get props => [
    progress ?? 0.0,
    receivedBytes ?? 0,
    totalBytes ?? 0,
  ];
}

class DownloadCompleted extends DocumentState {
  final String filePath;

  const DownloadCompleted(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class DownloadPaused extends DocumentState {}

class DownloadFailed extends DocumentState {
  final Object error;
  const DownloadFailed(this.error);
  @override
  List<Object> get props => [error];
}
