/*
 * @Author: LeeZB
 * @Date: 2025-08-06 18:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 18:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

part of 'material_detail_bloc.dart';

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

/// 加载材料生命周期
class LoadMaterialLifeCycle extends MaterialDetailEvent {
  final int materialId;
  const LoadMaterialLifeCycle({required this.materialId});
  @override
  List<Object?> get props => [materialId];
}
