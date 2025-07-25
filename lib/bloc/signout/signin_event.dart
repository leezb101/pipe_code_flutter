/*
 * @Author: LeeZB
 * @Date: 2025-07-24 22:42:59
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 11:26:21
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/signout/do_signout_request_vo.dart';

abstract class SignoutEvent extends Equatable {
  const SignoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadSignoutDetail extends SignoutEvent {
  final int signinId;

  const LoadSignoutDetail({required this.signinId});

  @override
  List<Object?> get props => [signinId];
}

class SubmitSignout extends SignoutEvent {
  final DoSignoutRequestVo request;

  const SubmitSignout({required this.request});

  @override
  List<Object?> get props => [request];
}

class AuditSignout extends SignoutEvent {
  final CommonDoBusinessAuditVO request;

  const AuditSignout({required this.request});

  @override
  List<Object?> get props => [request];
}

class RefreshSignoutDetail extends SignoutEvent {
  final int signinId;

  const RefreshSignoutDetail({required this.signinId});

  @override
  List<Object?> get props => [signinId];
}

class LoadWarehouseUsers extends SignoutEvent {
  final int warehouseId;

  const LoadWarehouseUsers({required this.warehouseId});

  @override
  List<Object?> get props => [warehouseId];
}

class LoadWarehouseInfo extends SignoutEvent {
  final int materialId;

  const LoadWarehouseInfo({required this.materialId});

  @override
  List<Object?> get props => [materialId];
}
