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
class JsfAcceptanceState extends Equatable {
  final List<MaterialInfo> materials;
  final Set<int> materialIds;
  final List<dynamic> errorMaterials; // 错误材料列表
  final bool isLoadingMaterials;
  final bool isLoadingAppendMaterials;
  final bool isSubmitting;
  final String? message;
  final String? errorMessage;
  final List<WarehouseVO> warehouseList;
  final List<CommonUserVO> warehouseUsers;
  final bool isSubmitted;
  final bool showPurchaserValidationWarning;
  final List<String> purchaserMismatchMaterials;

  const JsfAcceptanceState({
    this.materials = const [],
    this.materialIds = const <int>{},
    this.errorMaterials = const [],
    this.isLoadingMaterials = false,
    this.isLoadingAppendMaterials = false,
    this.isSubmitting = false,
    this.message,
    this.errorMessage,
    this.warehouseList = const [],
    this.warehouseUsers = const [],
    this.isSubmitted = false,
    this.showPurchaserValidationWarning = false,
    this.purchaserMismatchMaterials = const [],
  });

  @override
  List<Object?> get props => [
    materials,
    materialIds,
    errorMaterials,
    isLoadingMaterials,
    isLoadingAppendMaterials,
    isSubmitting,
    message,
    errorMessage,
    warehouseList,
    warehouseUsers,
    isSubmitted,
    showPurchaserValidationWarning,
    purchaserMismatchMaterials,
  ];

  JsfAcceptanceState copyWith({
    List<MaterialInfo>? materials,
    Set<int>? materialIds,
    List<dynamic>? errorMaterials,
    bool? isLoadingMaterials,
    bool? isLoadingAppendMaterials,
    bool? isSubmitting,
    String? message,
    String? errorMessage,
    List<WarehouseVO>? warehouseList,
    List<CommonUserVO>? warehouseUsers,
    bool? isSubmitted,
    bool? showPurchaserValidationWarning,
    List<String>? purchaserMismatchMaterials,
  }) {
    return JsfAcceptanceState(
      materials: materials ?? this.materials,
      materialIds: materialIds ?? this.materialIds,
      errorMaterials: errorMaterials ?? this.errorMaterials,
      isLoadingMaterials: isLoadingMaterials ?? this.isLoadingMaterials,
      isLoadingAppendMaterials:
          isLoadingAppendMaterials ?? this.isLoadingAppendMaterials,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      message: message,
      errorMessage: errorMessage,
      warehouseList: warehouseList ?? this.warehouseList,
      warehouseUsers: warehouseUsers ?? this.warehouseUsers,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      showPurchaserValidationWarning:
          showPurchaserValidationWarning ?? this.showPurchaserValidationWarning,
      purchaserMismatchMaterials:
          purchaserMismatchMaterials ?? this.purchaserMismatchMaterials,
    );
  }
}
