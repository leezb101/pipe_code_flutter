import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_code_flutter/models/common/document_discriptor.dart';
import 'package:pipe_code_flutter/services/documents/document_route_resolver.dart';
import 'package:pipe_code_flutter/services/documents/document_service.dart';
import 'package:pipe_code_flutter/widgets/document_button.dart';

class _StubDocumentService extends DocumentService {
  StreamController<DownloadProgress>? _controller;

  @override
  Stream<DownloadProgress> downloadDocument(DocumentDescriptor descriptor) {
    _controller?.close();
    final controller = StreamController<DownloadProgress>();
    _controller = controller;
    return controller.stream;
  }

  @override
  void cancel() {
    _controller?.close();
    _controller = null;
  }

  void complete(String path) {
    final controller = _controller;
    if (controller == null || controller.isClosed) {
      throw StateError('No active download to complete');
    }

    controller.add(
      DownloadProgress(
        received: 1,
        total: 1,
        isCompleted: true,
        filePath: path,
      ),
    );
    controller.close();
    _controller = null;
  }
}

void main() {
  group('DocumentButton', () {
    late _StubDocumentService service;
    late DocumentRouteResolver resolver;

    setUp(() {
      service = _StubDocumentService();
      resolver = DocumentRouteResolver(
        baseUrl: 'https://example.com/api/',
        routes: {
          'test-doc': DocumentRouteDefinition(
            uriBuilder: (id) => Uri(path: 'documents/$id'),
            nameBuilder: (id) => 'doc-$id.pdf',
          ),
        },
      );
    });

    testWidgets('invokes onDownloadCompleted when download finishes once', (
      tester,
    ) async {
      var callbackCount = 0;
      String? lastPath;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocumentButton(
              businessType: 'test-doc',
              entityId: 42,
              documentService: service,
              routeResolver: resolver,
              displayName: '文档',
              onDownloadCompleted: (path) {
                callbackCount += 1;
                lastPath = path;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      service.complete('/tmp/doc-42.pdf');

      await tester.pump();
      await tester.pump();

      expect(callbackCount, 1);
      expect(lastPath, '/tmp/doc-42.pdf');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      service.complete('/tmp/doc-42.pdf');

      await tester.pump();
      await tester.pump();

      expect(callbackCount, 2);
    });
  });
}
