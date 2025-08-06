/*
 * @Author: LeeZB
 * @Date: 2025-08-06 18:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 18:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';

abstract class MaterialDetailEvent extends Equatable {
  const MaterialDetailEvent();

  @override
  List<Object?> get props => [];
}

/// 加载材料详情
class LoadMaterialDetail extends MaterialDetailEvent {
  final String materialCode;

  const LoadMaterialDetail({required this.materialCode});

  @override
  List<Object?> get props => [materialCode];
}

/// 重新加载材料详情
class RefreshMaterialDetail extends MaterialDetailEvent {
  final String materialCode;

  const RefreshMaterialDetail({required this.materialCode});

  @override
  List<Object?> get props => [materialCode];
}

/// 加载截管记录
class LoadCuttingRecord extends MaterialDetailEvent {
  final String materialId;

  const LoadCuttingRecord({required this.materialId});

  @override
  List<Object?> get props => [materialId];
}

/// 材料详情加载失败
class MaterialDetailLoadFailed extends MaterialDetailEvent {
  final String message;

  const MaterialDetailLoadFailed({required this.message});

  @override
  List<Object?> get props => [message];
}

/// 截管记录加载失败
class CuttingRecordLoadFailed extends MaterialDetailEvent {
  final String message;

  const CuttingRecordLoadFailed({required this.message});

  @override
  List<Object?> get props => [message];
}