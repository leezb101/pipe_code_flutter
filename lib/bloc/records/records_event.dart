import 'package:equatable/equatable.dart';
import '../../models/records/record_type.dart';

abstract class RecordsEvent extends Equatable {
  const RecordsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecords extends RecordsEvent {
  final RecordType recordType;
  final int? projectId;
  final int? userId;
  final int pageNum;
  final int pageSize;
  final bool forceRefresh;

  const LoadRecords({
    required this.recordType,
    this.projectId,
    this.userId,
    this.pageNum = 1,
    this.pageSize = 10,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
        recordType,
        projectId,
        userId,
        pageNum,
        pageSize,
        forceRefresh,
      ];
}

class SwitchTab extends RecordsEvent {
  final RecordType recordType;

  const SwitchTab(this.recordType);

  @override
  List<Object> get props => [recordType];
}

class RefreshRecords extends RecordsEvent {
  final RecordType recordType;
  final int? projectId;
  final int? userId;

  const RefreshRecords({
    required this.recordType,
    this.projectId,
    this.userId,
  });

  @override
  List<Object?> get props => [recordType, projectId, userId];
}

class LoadMoreRecords extends RecordsEvent {
  final RecordType recordType;
  final int? projectId;
  final int? userId;
  final int pageSize;

  const LoadMoreRecords({
    required this.recordType,
    this.projectId,
    this.userId,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [recordType, projectId, userId, pageSize];
}

class ClearRecordsCache extends RecordsEvent {
  final RecordType? recordType;

  const ClearRecordsCache([this.recordType]);

  @override
  List<Object?> get props => [recordType];
}