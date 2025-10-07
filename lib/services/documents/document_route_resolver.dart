import '../../models/common/document_discriptor.dart';

typedef DocumentUriBuilder = Uri Function(int id);
typedef DocumentNameBuilder = String Function(int id);

class DocumentRouteDefinition {
  final DocumentUriBuilder uriBuilder;
  final DocumentNameBuilder? nameBuilder;

  const DocumentRouteDefinition({required this.uriBuilder, this.nameBuilder});
}

class DocumentRouteResolver {
  final Uri _baseUri;
  final Map<String, DocumentRouteDefinition> _routes;

  DocumentRouteResolver({
    required String baseUrl,
    Map<String, DocumentRouteDefinition> routes = const {},
  }) : _baseUri = _ensureTrailingSlash(Uri.parse(baseUrl)),
       _routes = Map.of(routes);

  void register(String businessType, DocumentRouteDefinition definition) {
    _routes[businessType] = definition;
  }

  void registerAll(Map<String, DocumentRouteDefinition> routes) {
    _routes.addAll(routes);
  }

  DocumentDescriptor resolve(
    String businessType,
    int id, {
    String? name,
    Map<String, dynamic>? extra,
  }) {
    final definition = _routes[businessType];
    if (definition == null) {
      throw ArgumentError('No document route defined for $businessType');
    }

    final targetUri = _resolveUri(definition.uriBuilder(id));
    final resolvedName =
        name ?? definition.nameBuilder?.call(id) ?? '$businessType-$id.pdf';

    return DocumentDescriptor(
      id: id,
      name: resolvedName,
      url: targetUri.toString(),
      extra: extra,
    );
  }

  Uri _resolveUri(Uri candidate) {
    if (candidate.hasScheme) {
      return candidate;
    }
    return _baseUri.resolveUri(candidate);
  }

  static Uri _ensureTrailingSlash(Uri base) {
    final path = base.path;
    if (path.isEmpty || path.endsWith('/')) {
      return base;
    }
    return base.replace(path: '$path/');
  }
}
