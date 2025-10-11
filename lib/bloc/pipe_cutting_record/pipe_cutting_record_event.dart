/*
 * @Author: LeeZB  
 * @Date: 2025-10-11 00:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-10-11 00:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

part of 'pipe_cutting_record_bloc.dart';

abstract class PipeCuttingRecordEvent extends Equatable {
  const PipeCuttingRecordEvent();

  @override
  List<Object?> get props => [];
}

/// 加载截管记录详情
class LoadPipeCuttingRecord extends PipeCuttingRecordEvent {
  final String materialId;

  const LoadPipeCuttingRecord({required this.materialId});

  @override
  List<Object?> get props => [materialId];
}

/// 刷新截管记录详情
class RefreshPipeCuttingRecord extends PipeCuttingRecordEvent {
  final String materialId;

  const RefreshPipeCuttingRecord({required this.materialId});

  @override
  List<Object?> get props => [materialId];
}
