import 'package:rxdart/rxdart.dart';
import '../../models/common/document_discriptor.dart';
import '../../services/documents/document_service.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc {
  final DocumentService _documentService;
  DocumentDescriptor? _latestDescriptor;

  // 输入：UI发出的事件
  final _eventController = PublishSubject<DocumentEvent>();
  // 输出：当前状态流
  final BehaviorSubject<DocumentState> _stateController =
      BehaviorSubject<DocumentState>.seeded(DownloadIdle());

  Stream<DocumentState> get stateStream => _stateController.stream;
  DocumentState get currentState => _stateController.value;

  Sink<DocumentEvent> get eventSink => _eventController.sink;

  DocumentBloc(this._documentService) {
    _bind();
  }

  void _bind() {
    _eventController
        // 使用 switchMap 处理事件，每次新的start都会取消上一次任务
        .switchMap(_mapEventToStateStream)
        .listen(
          (state) => _stateController.add(state),
          onError: (e, s) => _stateController.add(DownloadFailed(e)),
        );
  }

  // 核心转换函数：事件流 -> 状态流
  Stream<DocumentState> _mapEventToStateStream(DocumentEvent event) async* {
    if (event is StartDownload) {
      _latestDescriptor = event.descriptor;
      yield DownloadChecking();

      try {
        // 调用下载服务并转换为DownloadState流
        await for (final progress in _documentService.downloadDocument(
          event.descriptor,
        )) {
          if (progress.isCompleted) {
            yield DownloadCompleted(progress.filePath ?? '');
          } else {
            yield DownloadInProgress(
              progress.progress,
              progress.received,
              progress.total,
            );
          }
        }
      } catch (e) {
        yield DownloadFailed(e);
      }
    }

    if (event is CancelDownload) {
      _documentService.cancel();
      yield DownloadIdle();
    }

    if (event is RetryDownload) {
      final descriptor = _latestDescriptor;
      if (descriptor != null) {
        yield* _mapEventToStateStream(StartDownload(descriptor));
      } else {
        yield DownloadFailed(
          StateError('No previous download descriptor to retry'),
        );
      }
    }
  }

  void dispose() {
    _eventController.close();
    _stateController.close();
  }
}
