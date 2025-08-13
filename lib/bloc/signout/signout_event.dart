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
import 'package:pipe_code_flutter/models/material/material_info_base.dart';

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

// ========== QR Scan → Material resolution (SignoutPage) ==========
/// Standalone scan finished → navigate to SignoutPage with codes; bloc resolves materials
class InitializeMaterialsFromCodes extends SignoutEvent {
  final List<String> codes;

  /// True if codes came from a batch scan session (even if length == 1)
  final bool isBatch;

  const InitializeMaterialsFromCodes({
    required this.codes,
    required this.isBatch,
  });

  @override
  List<Object?> get props => [codes, isBatch];
}

/// Embedded: initialize editing with an initial list
class InitializeEditingMaterials extends SignoutEvent {
  final List<MaterialInfo> initial;
  const InitializeEditingMaterials({required this.initial});

  @override
  List<Object?> get props => [initial];
}

/// Embedded append: scan more codes and resolve to materials
class AppendEditingMaterialsByCodes extends SignoutEvent {
  final List<String> codes;
  const AppendEditingMaterialsByCodes({required this.codes});

  @override
  List<Object?> get props => [codes];
}

/// Embedded remove: scan codes to identify materials to remove
class RemoveEditingMaterialsByCodes extends SignoutEvent {
  final List<String> codes;
  const RemoveEditingMaterialsByCodes({required this.codes});

  @override
  List<Object?> get props => [codes];
}

/// Clear transient feedback message from SignoutEditingState
class ClearEditingMessage extends SignoutEvent {
  const ClearEditingMessage();

  @override
  List<Object?> get props => [];
}
