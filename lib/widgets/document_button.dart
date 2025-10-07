import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/bloc/documents/document_bloc.dart';
import 'package:pipe_code_flutter/bloc/documents/document_event.dart';
import 'package:pipe_code_flutter/bloc/documents/document_state.dart';
import 'package:pipe_code_flutter/models/common/document_discriptor.dart';
import 'package:pipe_code_flutter/services/documents/document_route_resolver.dart';
import 'package:pipe_code_flutter/services/documents/document_service.dart';

class DocumentButton extends StatefulWidget {
  final String businessType;
  final int entityId;
  final DocumentService documentService;
  final DocumentRouteResolver routeResolver;
  final String? displayName;
  final ButtonStyle? style;
  final ValueChanged<String>? onDownloadCompleted;

  const DocumentButton({
    super.key,
    required this.businessType,
    required this.entityId,
    required this.documentService,
    required this.routeResolver,
    this.displayName,
    this.style,
    this.onDownloadCompleted,
  });

  @override
  State<DocumentButton> createState() => _DocumentButtonState();
}

class _DocumentButtonState extends State<DocumentButton> {
  late final DocumentBloc _bloc;
  late DocumentDescriptor _descriptor;
  String? _lastCompletedPath;

  @override
  void initState() {
    super.initState();
    _bloc = DocumentBloc(widget.documentService);
    _descriptor = _resolveDescriptor();
  }

  @override
  void didUpdateWidget(covariant DocumentButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.businessType != widget.businessType ||
        oldWidget.entityId != widget.entityId ||
        oldWidget.displayName != widget.displayName) {
      _descriptor = _resolveDescriptor();
    }

    assert(
      identical(oldWidget.documentService, widget.documentService),
      'DocumentButton does not support changing documentService at runtime',
    );
    assert(
      identical(oldWidget.routeResolver, widget.routeResolver),
      'DocumentButton does not support changing routeResolver at runtime',
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentState>(
      initialData: _bloc.currentState,
      stream: _bloc.stateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        return ElevatedButton(
          style:
              widget.style ??
              ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
          onPressed: _resolveOnPressed(state),
          child: _buildChild(state),
        );
      },
    );
  }

  DocumentDescriptor _resolveDescriptor() {
    return widget.routeResolver.resolve(
      widget.businessType,
      widget.entityId,
      name: widget.displayName,
    );
  }

  VoidCallback? _resolveOnPressed(DocumentState? state) {
    if (state is DownloadChecking || state is DownloadInProgress) {
      return () => _bloc.eventSink.add(CancelDownload());
    }
    return () {
      _lastCompletedPath = null;
      _descriptor = _resolveDescriptor();
      _bloc.eventSink.add(StartDownload(_descriptor));
    };
  }

  Widget _buildChild(DocumentState? state) {
    _notifySideEffects(state);

    if (state is DownloadChecking) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (state is DownloadInProgress) {
      final percent = ((state.progress ?? 0) * 100)
          .clamp(0, 100)
          .toStringAsFixed(0);
      return Text('下载中 $percent% (点击取消)');
    }

    if (state is DownloadCompleted) {
      final label = widget.displayName ?? '文档';
      return Text('$label 下载完成 (重新下载)');
    }

    if (state is DownloadFailed) {
      final label = widget.displayName ?? '文档';
      return Text('$label 下载失败，点击重试');
    }

    final label = widget.displayName;
    if (label != null && label.isNotEmpty) {
      return Text('下载 $label');
    }
    return const Text('下载文档');
  }

  void _notifySideEffects(DocumentState? state) {
    if (state is DownloadCompleted) {
      final completedPath = state.filePath;
      if (widget.onDownloadCompleted != null &&
          completedPath.isNotEmpty &&
          completedPath != _lastCompletedPath) {
        _lastCompletedPath = completedPath;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          widget.onDownloadCompleted?.call(completedPath);
        });
      }
    }
  }
}
