import 'package:equatable/equatable.dart';

class PageMeta extends Equatable {
  final int total;
  final int size;
  final int current;
  final int? pages; // optional from backend; compute when absent

  const PageMeta({
    required this.total,
    required this.size,
    required this.current,
    this.pages,
  });

  int get computedPages => pages ?? ((total + size - 1) ~/ size);
  bool get hasMore => current < computedPages;

  @override
  List<Object?> get props => [total, size, current, pages];
}

class PagedRecords<T> extends Equatable {
  final List<T> records;
  final PageMeta meta;

  const PagedRecords({required this.records, required this.meta});

  @override
  List<Object?> get props => [records, meta];
}
