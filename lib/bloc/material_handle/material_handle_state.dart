/*
 * @Author: LeeZB
 * @Date: 2025-07-24 14:27:23
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-24 14:30:24
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';

abstract class MaterialHandleState extends Equatable {
  const MaterialHandleState();
  @override
  List<Object?> get props => [];
}

class MaterialHandleInitial extends MaterialHandleState {}

class MaterialHandleInProgress extends MaterialHandleState {}

class MaterialHandleScanSuccess extends MaterialHandleState {
  final MaterialInfoForBusiness materialInfo;
  const MaterialHandleScanSuccess(this.materialInfo);
  @override
  List<Object?> get props => [materialInfo];
}

class MaterialHandleScanFailure extends MaterialHandleState {
  final String error;
  const MaterialHandleScanFailure(this.error);
  @override
  List<Object?> get props => [error];
}
