part of 'pdf_preview_cubit.dart';

abstract class PdfPreviewState extends Equatable {
  const PdfPreviewState();

  @override
  List<Object?> get props => [];
}

// 初始化状态
class PdfPreviewInitial extends PdfPreviewState {
  const PdfPreviewInitial();
}

// 正在加载
class PdfPreviewLoading extends PdfPreviewState {
  const PdfPreviewLoading();
}

// 加载/操作成功状态
class PdfPreviewSuccess extends PdfPreviewState {
  final String tempFilePath;
  final String? message;
  const PdfPreviewSuccess(this.tempFilePath, {this.message});

  @override
  List<Object?> get props => [tempFilePath, message];
}

// 加载/操作失败状态
class PdfPreviewFailure extends PdfPreviewState {
  final String error;
  const PdfPreviewFailure(this.error);

  @override
  List<Object?> get props => [error];
}
