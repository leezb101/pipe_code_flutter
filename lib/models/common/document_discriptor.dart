import 'package:equatable/equatable.dart';

class DocumentDescriptor extends Equatable {
  final int id;
  final String name;
  final String? url;
  final Map<String, dynamic>? extra;

  const DocumentDescriptor({
    required this.id,
    required this.name,
    this.url,
    this.extra,
  });

  factory DocumentDescriptor.fromJson(Map<String, dynamic> json) {
    return DocumentDescriptor(
      id: json['id'] as int,
      name: json['name'] as String,
      url: json['url'] as String?,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'url': url, 'extra': extra};
  }

  @override
  List<Object?> get props => [id, name, url, extra];
}
