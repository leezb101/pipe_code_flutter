/*
 * @Author: LeeZB
 * @Date: 2025-08-06 18:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 18:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import '../../models/material/scan_identification_response.dart';
import '../../models/cut/pipe_cutting_record.dart';

abstract class MaterialDetailState extends Equatable {
  const MaterialDetailState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class MaterialDetailInitial extends MaterialDetailState {}

/// 材料详情加载中
class MaterialDetailLoading extends MaterialDetailState {}

/// 材料详情加载成功
class MaterialDetailLoaded extends MaterialDetailState {
  final ScanIdentificationData materialDetail;
  final PipeCuttingRecord? cuttingRecord;
  final bool isLoadingCuttingRecord;

  const MaterialDetailLoaded({
    required this.materialDetail,
    this.cuttingRecord,
    this.isLoadingCuttingRecord = false,
  });

  @override
  List<Object?> get props => [materialDetail, cuttingRecord, isLoadingCuttingRecord];

  /// 复制对象并更新部分字段
  MaterialDetailLoaded copyWith({
    ScanIdentificationData? materialDetail,
    PipeCuttingRecord? cuttingRecord,
    bool? isLoadingCuttingRecord,
  }) {
    return MaterialDetailLoaded(
      materialDetail: materialDetail ?? this.materialDetail,
      cuttingRecord: cuttingRecord ?? this.cuttingRecord,
      isLoadingCuttingRecord: isLoadingCuttingRecord ?? this.isLoadingCuttingRecord,
    );
  }
}

/// 材料详情加载失败
class MaterialDetailError extends MaterialDetailState {
  final String message;
  final bool isCuttingRecordError;

  const MaterialDetailError({
    required this.message,
    this.isCuttingRecordError = false,
  });

  @override
  List<Object?> get props => [message, isCuttingRecordError];
}

/// 截管记录加载中（在MaterialDetailLoaded状态下的局部加载）
class CuttingRecordLoading extends MaterialDetailState {
  final ScanIdentificationData materialDetail;

  const CuttingRecordLoading({required this.materialDetail});

  @override
  List<Object?> get props => [materialDetail];
}