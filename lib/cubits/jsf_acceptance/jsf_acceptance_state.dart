/*
 * @Author: LeeZB
 * @Date: 2025-09-29
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-29
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/common/warehouse_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';

/// 建设方验收状态
sealed class JsfAcceptanceState extends Equatable {
  const JsfAcceptanceState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
final class JsfAcceptanceInitial extends JsfAcceptanceState {
  const JsfAcceptanceInitial();
}

/// 材料加载中
final class JsfAcceptanceMaterialsLoading extends JsfAcceptanceState {
  const JsfAcceptanceMaterialsLoading();
}

/// 追加材料加载中
final class JsfAcceptanceMaterialsAppending extends JsfAcceptanceState {
  final List<MaterialInfo> currentMaterials;
  final Set<int> materialIds;

  const JsfAcceptanceMaterialsAppending({
    required this.currentMaterials,
    required this.materialIds,
  });

  @override
  List<Object?> get props => [currentMaterials, materialIds];
}

/// 编辑状态 - 包含当前材料列表和其他状态
final class JsfAcceptanceEditingState extends JsfAcceptanceState {
  final List<MaterialInfo> currentMaterials;
  final Set<int> materialIds;
  final bool isLoadingAppendMaterials;
  final String? message;
  final List<WarehouseVO> warehouseList;
  final List<CommonUserVO> warehouseUsers;

  const JsfAcceptanceEditingState({
    required this.currentMaterials,
    required this.materialIds,
    this.isLoadingAppendMaterials = false,
    this.message,
    this.warehouseList = const [],
    this.warehouseUsers = const [],
  });

  @override
  List<Object?> get props => [
    currentMaterials,
    materialIds,
    isLoadingAppendMaterials,
    message,
    warehouseList,
    warehouseUsers,
  ];

  JsfAcceptanceEditingState copyWith({
    List<MaterialInfo>? currentMaterials,
    Set<int>? materialIds,
    bool? isLoadingAppendMaterials,
    String? message,
    List<WarehouseVO>? warehouseList,
    List<CommonUserVO>? warehouseUsers,
  }) {
    return JsfAcceptanceEditingState(
      currentMaterials: currentMaterials ?? this.currentMaterials,
      materialIds: materialIds ?? this.materialIds,
      isLoadingAppendMaterials:
          isLoadingAppendMaterials ?? this.isLoadingAppendMaterials,
      message: message,
      warehouseList: warehouseList ?? this.warehouseList,
      warehouseUsers: warehouseUsers ?? this.warehouseUsers,
    );
  }
}

/// 提交中状态
final class JsfAcceptanceSubmitting extends JsfAcceptanceState {
  const JsfAcceptanceSubmitting();
}

/// 提交成功状态
final class JsfAcceptanceSubmitted extends JsfAcceptanceState {
  const JsfAcceptanceSubmitted();
}

/// 仓库列表加载成功
final class JsfAcceptanceWarehouseLoaded extends JsfAcceptanceState {
  final List<WarehouseVO> warehouseList;

  const JsfAcceptanceWarehouseLoaded({required this.warehouseList});

  @override
  List<Object?> get props => [warehouseList];
}

/// 仓库用户加载成功
final class JsfAcceptanceWarehouseUsersLoaded extends JsfAcceptanceState {
  final List<CommonUserVO> warehouseUsers;

  const JsfAcceptanceWarehouseUsersLoaded({required this.warehouseUsers});

  @override
  List<Object?> get props => [warehouseUsers];
}

/// 错误状态
final class JsfAcceptanceError extends JsfAcceptanceState {
  final String message;

  const JsfAcceptanceError({required this.message});

  @override
  List<Object?> get props => [message];
}
