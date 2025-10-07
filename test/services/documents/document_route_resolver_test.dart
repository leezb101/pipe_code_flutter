import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/services/documents/document_route_resolver.dart';

void main() {
  group('relativeDocumentUri', () {
    test('converts scalar query parameters to strings', () {
      final uri = relativeDocumentUri(
        '/wd/accept',
        queryParameters: {'id': 42},
      );

      expect(uri.path, 'wd/accept');
      expect(uri.queryParameters, {'id': '42'});
    });

    test('drops null entries and stringifies iterables', () {
      final uri = relativeDocumentUri(
        '/wd/list',
        queryParameters: {
          'id': [1, 2, 3],
          'nullable': null,
          'label': '报告',
        },
      );

      expect(uri.path, 'wd/list');
      expect(uri.queryParametersAll['id'], ['1', '2', '3']);
      expect(uri.queryParameters.containsKey('nullable'), isFalse);
      expect(uri.queryParameters['label'], '报告');
    });
  });

  group('DocumentRouteResolver', () {
    test(
      'resolves acceptance report route with normalized query parameters',
      () {
        final resolver = DocumentRouteResolver(
          baseUrl: 'https://example.com/api',
          routes: {
            'acceptance-report': DocumentRouteDefinition(
              uriBuilder: (id) => relativeDocumentUri(
                '/wd/accept',
                queryParameters: {'id': id},
              ),
              nameBuilder: (id) => '验收单-$id.pdf',
            ),
          },
        );

        final descriptor = resolver.resolve('acceptance-report', 99);

        expect(descriptor.id, 99);
        expect(descriptor.name, '验收单-99.pdf');
        expect(descriptor.url, 'https://example.com/api/wd/accept?id=99');
      },
    );

    test('applies custom name while preserving extension', () {
      final resolver = DocumentRouteResolver(
        baseUrl: 'https://example.com/api',
        routes: {
          'acceptance-report': DocumentRouteDefinition(
            uriBuilder: (id) =>
                relativeDocumentUri('/wd/accept', queryParameters: {'id': id}),
            nameBuilder: (id) => '验收单-$id.pdf',
          ),
        },
      );

      final descriptor = resolver.resolve(
        'acceptance-report',
        99,
        name: '验收文件',
      );

      expect(descriptor.name, '验收文件.pdf');
    });

    test('keeps provided extension when custom name supplies one', () {
      final resolver = DocumentRouteResolver(
        baseUrl: 'https://example.com/api',
        routes: {
          'acceptance-report': DocumentRouteDefinition(
            uriBuilder: (id) =>
                relativeDocumentUri('/wd/accept', queryParameters: {'id': id}),
            nameBuilder: (id) => '验收单-$id.pdf',
          ),
        },
      );

      final descriptor = resolver.resolve(
        'acceptance-report',
        99,
        name: '验收文件.docx',
      );

      expect(descriptor.name, '验收文件.docx');
    });
  });
}
