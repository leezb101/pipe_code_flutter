import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/common/document_discriptor.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

class StartDownload extends DocumentEvent {
  final DocumentDescriptor descriptor;
  const StartDownload(this.descriptor);
  @override
  List<Object?> get props => [descriptor];
}

class PauseDownload extends DocumentEvent {}

class ResumeDownload extends DocumentEvent {}

class CancelDownload extends DocumentEvent {}

class RetryDownload extends DocumentEvent {}
