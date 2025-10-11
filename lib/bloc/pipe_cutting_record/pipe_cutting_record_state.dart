/*
 * @Author: LeeZB  
 * @Date: 2025-10-11 00:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-10-11 00:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

part of 'pipe_cutting_record_bloc.dart';

abstract class PipeCuttingRecordState extends Equatable {
  const PipeCuttingRecordState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class PipeCuttingRecordInitial extends PipeCuttingRecordState {}

/// 加载中
class PipeCuttingRecordLoading extends PipeCuttingRecordState {}

/// 加载成功
class PipeCuttingRecordLoaded extends PipeCuttingRecordState {
  final PipeCuttingRecord cuttingRecord;

  const PipeCuttingRecordLoaded({required this.cuttingRecord});

  @override
  List<Object?> get props => [cuttingRecord];
}

/// 加载失败
class PipeCuttingRecordError extends PipeCuttingRecordState {
  final String message;

  const PipeCuttingRecordError({required this.message});

  @override
  List<Object?> get props => [message];
}
