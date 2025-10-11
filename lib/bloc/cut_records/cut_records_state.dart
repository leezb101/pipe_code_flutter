import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/cut/cut_records_item_vo.dart';
import 'package:pipe_code_flutter/models/cut/cut_statistic_vo.dart';

abstract class CutRecordsState extends Equatable {
  const CutRecordsState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class CutRecordsInitial extends CutRecordsState {
  const CutRecordsInitial();
}

/// 加载中
class CutRecordsLoading extends CutRecordsState {
  final CutStatisticVo? statistics;
  final List<CutRecordsItemVO> cachedRecords;

  const CutRecordsLoading({this.statistics, this.cachedRecords = const []});

  @override
  List<Object?> get props => [statistics, cachedRecords];
}

/// 加载成功
class CutRecordsLoaded extends CutRecordsState {
  final CutStatisticVo statistics;
  final List<CutRecordsItemVO> records;
  final bool hasMoreData;
  final int currentPage;
  final bool isLoadingMore;

  const CutRecordsLoaded({
    required this.statistics,
    required this.records,
    required this.hasMoreData,
    required this.currentPage,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    statistics,
    records,
    hasMoreData,
    currentPage,
    isLoadingMore,
  ];

  CutRecordsLoaded copyWith({
    CutStatisticVo? statistics,
    List<CutRecordsItemVO>? records,
    bool? hasMoreData,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return CutRecordsLoaded(
      statistics: statistics ?? this.statistics,
      records: records ?? this.records,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// 空数据
class CutRecordsEmpty extends CutRecordsState {
  final CutStatisticVo statistics;

  const CutRecordsEmpty({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

/// 错误状态
class CutRecordsError extends CutRecordsState {
  final String message;
  final CutStatisticVo? statistics;
  final List<CutRecordsItemVO> cachedRecords;

  const CutRecordsError({
    required this.message,
    this.statistics,
    this.cachedRecords = const [],
  });

  @override
  List<Object?> get props => [message, statistics, cachedRecords];
}
