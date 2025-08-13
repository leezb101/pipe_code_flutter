import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter_pdfview/flutter_pdfview.dart";
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import './cubit/pdf_preview_cubit.dart';

class PdfPreviewer extends StatelessWidget {
  final String url;

  const PdfPreviewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PdfPreviewCubit()..loadPdf(url),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PDF预览'),
          // actions: [
          //   // 下载按钮
          //   BlocBuilder<PdfPreviewCubit, PdfPreviewState>(
          //     builder: (context, state) {
          //       // 仅在PDF加载成功后显示下载按钮
          //       if (state is PdfPreviewSuccess) {
          //         return IconButton(
          //           icon: const Icon(Icons.download),
          //           onPressed: () {
          //             context.read<PdfPreviewCubit>().downloadPDF();
          //           },
          //         );
          //       }
          //       return const SizedBox.shrink();
          //     },
          //   ),
          // ],
        ),
        body: BlocListener<PdfPreviewCubit, PdfPreviewState>(
          listener: (context, state) {
            if (state is PdfPreviewSuccess && state.message != null) {
              context.showSuccessToast(state.message!, isGlobal: true);
            }
          },
          child: BlocBuilder<PdfPreviewCubit, PdfPreviewState>(
            builder: (context, state) {
              if (state is PdfPreviewLoading || state is PdfPreviewInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PdfPreviewSuccess) {
                return PDFView(
                  filePath: state.tempFilePath,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: false,
                  pageFling: true,
                  onError: (error) {
                    context.showErrorToast("PDF加载失败: $error", isGlobal: true);
                  },
                );
              } else if (state is PdfPreviewFailure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "PDF加载失败: ${state.error}",
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return const Center(child: Text("未知状态，请稍后重试"));
            },
          ),
        ),
      ),
    );
  }
}
