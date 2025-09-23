/*
 * @Author: LeeZB
 * @Date: 2025-07-24 22:42:59
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 19:39:30
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/common/warehouse_user_info_vo.dart';
import 'package:pipe_code_flutter/models/common/warehouse_vo.dart';
import 'package:pipe_code_flutter/models/signout/signout_info_vo.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';

class SignoutState extends Equatable {
  const SignoutState();

  @override
  List<Object?> get props => [];
}

class SignoutInitial extends SignoutState {
  const SignoutInitial();
}

class SignoutLoading extends SignoutState {
  const SignoutLoading();
}

class SignoutReady extends SignoutState {
  final SignoutInfoVo? signoutDetail;
  final bool isWarehouseUsersLoading;
  final String? warehouseUsersError;
  final bool isWarehouseInfoLoading;
  final String? warehouseInfoError;
  final WarehouseVO? warehouseInfo;
  final WarehouseUserInfoVO? warehouseUsers;
  final String? submitError;
  final bool clearError;

  const SignoutReady({
    this.signoutDetail,
    this.warehouseInfo,
    this.warehouseInfoError,
    this.isWarehouseInfoLoading = false,
    this.isWarehouseUsersLoading = false,
    this.warehouseUsers,
    this.warehouseUsersError,
    this.submitError,
    this.clearError = true,
  });

  @override
  List<Object?> get props => [
    signoutDetail,
    isWarehouseUsersLoading,
    warehouseUsers,
    warehouseUsersError,
    submitError,
    warehouseInfo,
    warehouseInfoError,
    isWarehouseInfoLoading,
  ];

  SignoutReady copyWith({
    SignoutInfoVo? signoutDetail,
    WarehouseVO? warehouseInfo,
    String? warehouseInfoError,
    bool? isWarehouseInfoLoading,
    bool? isWarehouseUsersLoading,
    String? warehouseUsersError,
    WarehouseUserInfoVO? warehouseUsers,
    String? submitError,
    bool? clearError,
  }) {
    return SignoutReady(
      signoutDetail: signoutDetail ?? this.signoutDetail,
      isWarehouseUsersLoading:
          isWarehouseUsersLoading ?? this.isWarehouseUsersLoading,
      warehouseUsersError: warehouseUsersError ?? this.warehouseUsersError,
      warehouseUsers: warehouseUsers ?? this.warehouseUsers,
      submitError: submitError ?? this.submitError,
      warehouseInfo: warehouseInfo ?? this.warehouseInfo,
      warehouseInfoError: warehouseInfoError ?? this.warehouseInfoError,
      isWarehouseInfoLoading:
          isWarehouseInfoLoading ?? this.isWarehouseInfoLoading,
      clearError: clearError ?? this.clearError,
    );
  }
}

class SignoutDetailError extends SignoutState {
  final String message;

  const SignoutDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class SignoutSubmitting extends SignoutState {
  const SignoutSubmitting();
}

class SignoutSubmitted extends SignoutState {
  const SignoutSubmitted();
}

/// Editing state for SignoutPage driven by QR scanning and in-page operations
class SignoutEditingState extends SignoutState {
  final List<MaterialInfo> currentMaterials;
  final Set<int> materialIds;
  final String? message; // feedback like "新增/剔除"

  // Warehouse related (mirror a subset of SignoutReady for editing page)
  final bool isWarehouseInfoLoading;
  final String? warehouseInfoError;
  final WarehouseVO? warehouseInfo;
  final bool isWarehouseUsersLoading;
  final String? warehouseUsersError;
  final WarehouseUserInfoVO? warehouseUsers;

  // Submit status for SignoutPage
  final bool isSubmitting;
  final String? submitError;

  const SignoutEditingState({
    required this.currentMaterials,
    required this.materialIds,
    this.message,
    this.isWarehouseInfoLoading = false,
    this.warehouseInfoError,
    this.warehouseInfo,
    this.isWarehouseUsersLoading = false,
    this.warehouseUsersError,
    this.warehouseUsers,
    this.isSubmitting = false,
    this.submitError,
  });

  @override
  List<Object?> get props => [
    currentMaterials,
    materialIds,
    message,
    isWarehouseInfoLoading,
    warehouseInfoError,
    warehouseInfo,
    isWarehouseUsersLoading,
    warehouseUsersError,
    warehouseUsers,
    isSubmitting,
    submitError,
  ];

  SignoutEditingState copyWith({
    List<MaterialInfo>? currentMaterials,
    Set<int>? materialIds,
    String? message,
    bool clearMessage = false,
    bool? isWarehouseInfoLoading,
    String? warehouseInfoError,
    WarehouseVO? warehouseInfo,
    bool? isWarehouseUsersLoading,
    String? warehouseUsersError,
    WarehouseUserInfoVO? warehouseUsers,
    bool? isSubmitting,
    String? submitError,
  }) {
    return SignoutEditingState(
      currentMaterials: currentMaterials ?? this.currentMaterials,
      materialIds: materialIds ?? this.materialIds,
      message: clearMessage ? null : (message ?? this.message),
      isWarehouseInfoLoading:
          isWarehouseInfoLoading ?? this.isWarehouseInfoLoading,
      warehouseInfoError: warehouseInfoError ?? this.warehouseInfoError,
      warehouseInfo: warehouseInfo ?? this.warehouseInfo,
      isWarehouseUsersLoading:
          isWarehouseUsersLoading ?? this.isWarehouseUsersLoading,
      warehouseUsersError: warehouseUsersError ?? this.warehouseUsersError,
      warehouseUsers: warehouseUsers ?? this.warehouseUsers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError ?? this.submitError,
    );
  }
}
