/*
 * @Author: LeeZB
 * @Date: 2025-08-06 18:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 18:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

part of 'material_detail_bloc.dart';

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
  // 主数据，不受另外两个系列数据加载影响
  final ScanIdentificationData materialDetail;
  // 截管记录相关状态
  final PipeCuttingRecord? cuttingRecord;
  final bool isLoadingCuttingRecord;
  final String? cuttingRecordError;
  // 生命周期记录
  final List<MaterialLifecycleNode>? lifecycleNodes;
  final bool isLoadingLifecycle;
  final String? lifecycleError;

  const MaterialDetailLoaded({
    required this.materialDetail,
    this.cuttingRecord,
    this.isLoadingCuttingRecord = false,
    this.cuttingRecordError,
    this.lifecycleNodes,
    this.isLoadingLifecycle = false,
    this.lifecycleError,
  });

  @override
  List<Object?> get props => [
    materialDetail,
    cuttingRecord,
    isLoadingCuttingRecord,
    cuttingRecordError,
    lifecycleNodes,
    isLoadingLifecycle,
    lifecycleError,
  ];

  /// 复制对象并更新部分字段
  MaterialDetailLoaded copyWith({
    ScanIdentificationData? materialDetail,
    PipeCuttingRecord? cuttingRecord,
    bool? isLoadingCuttingRecord,
    String? cuttingRecordError,
    bool clearCuttingRecordError = false,
    List<MaterialLifecycleNode>? lifecycleNodes,
    bool? isLoadingLifecycle,
    String? lifecycleError,
    bool clearLifecycleError = false,
  }) {
    return MaterialDetailLoaded(
      materialDetail: materialDetail ?? this.materialDetail,
      cuttingRecord: cuttingRecord ?? this.cuttingRecord,
      isLoadingCuttingRecord:
          isLoadingCuttingRecord ?? this.isLoadingCuttingRecord,
      cuttingRecordError: clearCuttingRecordError
          ? null
          : (cuttingRecordError ?? this.cuttingRecordError),
      lifecycleNodes: lifecycleNodes ?? this.lifecycleNodes,
      isLoadingLifecycle: isLoadingLifecycle ?? this.isLoadingLifecycle,
      lifecycleError: clearLifecycleError
          ? null
          : (lifecycleError ?? this.lifecycleError),
    );
  }
}

/// 材料详情加载失败
class MaterialDetailError extends MaterialDetailState {
  final String message;

  const MaterialDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
