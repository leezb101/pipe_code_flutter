import 'package:equatable/equatable.dart';

abstract class CutRecordsEvent extends Equatable {
  const CutRecordsEvent();

  @override
  List<Object?> get props => [];
}

/// 加载截管记录和统计数据
class LoadCutRecords extends CutRecordsEvent {
  final int pageNum;
  final bool forceRefresh;

  const LoadCutRecords({this.pageNum = 1, this.forceRefresh = false});

  @override
  List<Object?> get props => [pageNum, forceRefresh];
}

/// 刷新截管记录
class RefreshCutRecords extends CutRecordsEvent {
  const RefreshCutRecords();
}

/// 加载更多截管记录
class LoadMoreCutRecords extends CutRecordsEvent {
  const LoadMoreCutRecords();
}

/// 清除截管记录缓存
class ClearCutRecordsCache extends CutRecordsEvent {
  const ClearCutRecordsCache();
}
