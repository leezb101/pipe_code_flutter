import 'package:equatable/equatable.dart';
import '../../models/records/record_item.dart';
import '../../models/records/record_type.dart';

abstract class RecordsState extends Equatable {
  const RecordsState();

  @override
  List<Object?> get props => [];
}

class RecordsInitial extends RecordsState {
  final RecordType currentTab;

  const RecordsInitial({this.currentTab = RecordType.todo});

  @override
  List<Object> get props => [currentTab];
}

class RecordsLoading extends RecordsState {
  final RecordType currentTab;
  final List<RecordItem>? cachedRecords;

  const RecordsLoading({
    required this.currentTab,
    this.cachedRecords,
  });

  @override
  List<Object?> get props => [currentTab, cachedRecords];
}

class RecordsLoaded extends RecordsState {
  final RecordType currentTab;
  final List<RecordItem> records;
  final bool hasMoreData;
  final int currentPage;
  final bool isLoadingMore;

  const RecordsLoaded({
    required this.currentTab,
    required this.records,
    this.hasMoreData = true,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  @override
  List<Object> get props => [
        currentTab,
        records,
        hasMoreData,
        currentPage,
        isLoadingMore,
      ];

  RecordsLoaded copyWith({
    RecordType? currentTab,
    List<RecordItem>? records,
    bool? hasMoreData,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return RecordsLoaded(
      currentTab: currentTab ?? this.currentTab,
      records: records ?? this.records,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class RecordsError extends RecordsState {
  final RecordType currentTab;
  final String message;
  final List<RecordItem>? cachedRecords;

  const RecordsError({
    required this.currentTab,
    required this.message,
    this.cachedRecords,
  });

  @override
  List<Object?> get props => [currentTab, message, cachedRecords];
}

class RecordsEmpty extends RecordsState {
  final RecordType currentTab;

  const RecordsEmpty(this.currentTab);

  @override
  List<Object> get props => [currentTab];
}