import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/user/current_user_on_project_role_info.dart';
import 'package:pipe_code_flutter/services/tracing/tracing_context.dart';
import '../../models/acceptance/do_accept_vo.dart';
import '../../models/acceptance/do_accept_sign_in_vo.dart';

abstract class AcceptanceEvent extends Equatable {
  const AcceptanceEvent();

  @override
  List<Object?> get props => [];
}

abstract class TracableAcceptanceEvent extends AcceptanceEvent {
  const TracableAcceptanceEvent({required this.tracingContext});

  final TracingContext tracingContext;

  @override
  List<Object?> get props => [tracingContext, ...super.props];
}

class LoadAcceptanceDetail extends TracableAcceptanceEvent {
  final int acceptanceId;

  const LoadAcceptanceDetail({
    required this.acceptanceId,
    required super.tracingContext,
  });

  @override
  List<Object?> get props => [acceptanceId, ...super.props];
}

class SubmitAcceptance extends TracableAcceptanceEvent {
  final DoAcceptVO request;

  const SubmitAcceptance({
    required this.request,
    required super.tracingContext,
  });

  @override
  List<Object?> get props => [request, ...super.props];
}

class DoAcceptanceSignIn extends TracableAcceptanceEvent {
  final DoAcceptSignInVO request;

  const DoAcceptanceSignIn({
    required this.request,
    required super.tracingContext,
  });

  @override
  List<Object?> get props => [request, ...super.props];
}

class LoadAcceptanceList extends TracableAcceptanceEvent {
  final int? projectId;
  final int? userId;
  final int pageNum;
  final int pageSize;

  const LoadAcceptanceList({
    this.projectId,
    this.userId,
    this.pageNum = 1,
    this.pageSize = 10,
    required super.tracingContext,
  });

  @override
  List<Object?> get props => [
    projectId,
    userId,
    pageNum,
    pageSize,
    ...super.props,
  ];
}

class RefreshAcceptanceDetail extends AcceptanceEvent {
  final int acceptanceId;

  const RefreshAcceptanceDetail({required this.acceptanceId});

  @override
  List<Object?> get props => [acceptanceId];
}

class ClearAcceptanceCache extends AcceptanceEvent {
  const ClearAcceptanceCache();
}

class LoadAcceptanceUsers extends TracableAcceptanceEvent {
  final int projectId;
  final int roleType;

  const LoadAcceptanceUsers({
    required this.projectId,
    required this.roleType,
    required super.tracingContext,
  });

  @override
  List<Object?> get props => [projectId, roleType, ...super.props];
}

class LoadWarehouseUsers extends TracableAcceptanceEvent {
  final int warehouseId;

  const LoadWarehouseUsers({
    required this.warehouseId,
    required super.tracingContext,
  });

  @override
  List<Object?> get props => [warehouseId, ...super.props];
}

class LoadWarehouseList extends TracableAcceptanceEvent {
  const LoadWarehouseList({required super.tracingContext});
}

class MatchScannedMaterial extends AcceptanceEvent {
  final MaterialInfoForBusiness scannedMaterial;
  const MatchScannedMaterial({required this.scannedMaterial});

  @override
  List<Object?> get props => [scannedMaterial];
}

class UnmatchScannedMaterial extends AcceptanceEvent {
  final MaterialInfoForBusiness scannedMaterial;
  const UnmatchScannedMaterial({required this.scannedMaterial});

  @override
  List<Object?> get props => [scannedMaterial];
}

// 批量剔除（仅使用 materialId 列表，无需完整MaterialInfo）
class BulkUnmatchMaterials extends AcceptanceEvent {
  final List<int> materialIds;
  const BulkUnmatchMaterials({required this.materialIds});

  @override
  List<Object?> get props => [materialIds];
}

// ========== QR Scan → Material resolution (AcceptancePage) ==========
// Standalone scan finished → navigate to AcceptancePage with codes; bloc resolves materials
class InitializeMaterialsFromCodes extends TracableAcceptanceEvent {
  final List<String> codes;

  /// True if codes came from a batch scan session (even if length == 1)
  final bool isBatch;

  /// Project purchase name for purchaser validation
  final String? projectPurNm;

  /// Project supply type for validation control
  final ProjectSupplyType? supplyType;

  const InitializeMaterialsFromCodes({
    required this.codes,
    required this.isBatch,
    this.projectPurNm,
    this.supplyType,
    required super.tracingContext,
  });

  @override
  List<Object?> get props => [
    codes,
    isBatch,
    projectPurNm,
    supplyType,
    ...super.props,
  ];
}

// Embedded append: scan more codes and resolve to materials
class AppendMaterialsByCodes extends TracableAcceptanceEvent {
  final List<String> codes;

  const AppendMaterialsByCodes({
    required this.codes,
    required super.tracingContext,
  });

  @override
  List<Object?> get props => [codes, ...super.props];
}

// Embedded remove: scan codes to identify materials to remove
class RemoveMaterialsByCodes extends TracableAcceptanceEvent {
  final List<String> codes;

  const RemoveMaterialsByCodes({
    required this.codes,
    required super.tracingContext,
  });

  @override
  List<Object?> get props => [codes, ...super.props];
}

// ========== AcceptancePage editing flow (centralize list ops in bloc) ==========
class InitializeEditingMaterials extends AcceptanceEvent {
  final List<MaterialInfo> initial;
  final List<dynamic> initialErrors;

  /// Project purchase name for purchaser validation
  final String? projectPurNm;

  /// Project supply type for validation control
  final ProjectSupplyType? supplyType;

  const InitializeEditingMaterials({
    required this.initial,
    this.initialErrors = const [],
    this.projectPurNm,
    this.supplyType,
  });

  @override
  List<Object?> get props => [initial, initialErrors, projectPurNm, supplyType];
}

class AppendEditingMaterialsByCodes extends TracableAcceptanceEvent {
  final List<String> codes;

  /// Project purchase name for purchaser validation
  final String? projectPurNm;

  /// Project supply type for validation control
  final ProjectSupplyType? supplyType;

  const AppendEditingMaterialsByCodes({
    required this.codes,
    this.projectPurNm,
    this.supplyType,
    required super.tracingContext,
  });

  @override
  List<Object?> get props => [codes, projectPurNm, supplyType, ...super.props];
}

class RemoveEditingMaterialsByCodes extends TracableAcceptanceEvent {
  final List<String> codes;

  const RemoveEditingMaterialsByCodes({
    required this.codes,
    required super.tracingContext,
  });

  @override
  List<Object?> get props => [codes, ...super.props];
}

// Clear transient feedback message from AcceptanceEditingState
class ClearEditingMessage extends AcceptanceEvent {
  const ClearEditingMessage();

  @override
  List<Object?> get props => [];
}

// Confirm purchaser validation warning and continue with acceptance
class ConfirmPurchaserValidationWarning extends AcceptanceEvent {
  const ConfirmPurchaserValidationWarning();

  @override
  List<Object?> get props => [];
}
