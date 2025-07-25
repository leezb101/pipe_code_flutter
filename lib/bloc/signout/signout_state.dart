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
  final String? auditError;
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
    this.auditError,
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
    auditError,
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
    String? auditError,
    bool? clearError,
  }) {
    return SignoutReady(
      signoutDetail: signoutDetail ?? this.signoutDetail,
      isWarehouseUsersLoading:
          isWarehouseUsersLoading ?? this.isWarehouseUsersLoading,
      warehouseUsersError: warehouseUsersError ?? this.warehouseUsersError,
      warehouseUsers: warehouseUsers ?? this.warehouseUsers,
      submitError: submitError ?? this.submitError,
      auditError: auditError ?? this.auditError,
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

class SignoutAuditing extends SignoutState {
  const SignoutAuditing();
}

class SignoutAudited extends SignoutState {
  const SignoutAudited();
}
