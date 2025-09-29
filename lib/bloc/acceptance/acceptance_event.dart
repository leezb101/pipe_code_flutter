import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/user/current_user_on_project_role_info.dart';
import '../../models/acceptance/do_accept_vo.dart';
import '../../models/acceptance/do_accept_sign_in_vo.dart';

abstract class AcceptanceEvent extends Equatable {
  const AcceptanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadAcceptanceDetail extends AcceptanceEvent {
  final int acceptanceId;

  const LoadAcceptanceDetail({required this.acceptanceId});

  @override
  List<Object?> get props => [acceptanceId];
}

class SubmitAcceptance extends AcceptanceEvent {
  final DoAcceptVO request;

  const SubmitAcceptance({required this.request});

  @override
  List<Object?> get props => [request];
}

class DoAcceptanceSignIn extends AcceptanceEvent {
  final DoAcceptSignInVO request;

  const DoAcceptanceSignIn({required this.request});

  @override
  List<Object?> get props => [request];
}

class LoadAcceptanceList extends AcceptanceEvent {
  final int? projectId;
  final int? userId;
  final int pageNum;
  final int pageSize;

  const LoadAcceptanceList({
    this.projectId,
    this.userId,
    this.pageNum = 1,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [projectId, userId, pageNum, pageSize];
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

class LoadAcceptanceUsers extends AcceptanceEvent {
  final int projectId;
  final int roleType;

  const LoadAcceptanceUsers({required this.projectId, required this.roleType});

  @override
  List<Object?> get props => [projectId, roleType];
}

class LoadWarehouseUsers extends AcceptanceEvent {
  final int warehouseId;

  const LoadWarehouseUsers({required this.warehouseId});

  @override
  List<Object?> get props => [warehouseId];
}

class LoadWarehouseList extends AcceptanceEvent {
  const LoadWarehouseList();
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
class InitializeMaterialsFromCodes extends AcceptanceEvent {
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
  });

  @override
  List<Object?> get props => [codes, isBatch, projectPurNm, supplyType];
}

// Embedded append: scan more codes and resolve to materials
class AppendMaterialsByCodes extends AcceptanceEvent {
  final List<String> codes;
  const AppendMaterialsByCodes({required this.codes});

  @override
  List<Object?> get props => [codes];
}

// Embedded remove: scan codes to identify materials to remove
class RemoveMaterialsByCodes extends AcceptanceEvent {
  final List<String> codes;
  const RemoveMaterialsByCodes({required this.codes});

  @override
  List<Object?> get props => [codes];
}

// ========== AcceptancePage editing flow (centralize list ops in bloc) ==========
class InitializeEditingMaterials extends AcceptanceEvent {
  final List<MaterialInfo> initial;

  /// Project purchase name for purchaser validation
  final String? projectPurNm;

  /// Project supply type for validation control
  final ProjectSupplyType? supplyType;

  const InitializeEditingMaterials({
    required this.initial,
    this.projectPurNm,
    this.supplyType,
  });

  @override
  List<Object?> get props => [initial, projectPurNm, supplyType];
}

class AppendEditingMaterialsByCodes extends AcceptanceEvent {
  final List<String> codes;

  /// Project purchase name for purchaser validation
  final String? projectPurNm;

  /// Project supply type for validation control
  final ProjectSupplyType? supplyType;

  const AppendEditingMaterialsByCodes({
    required this.codes,
    this.projectPurNm,
    this.supplyType,
  });

  @override
  List<Object?> get props => [codes, projectPurNm, supplyType];
}

class RemoveEditingMaterialsByCodes extends AcceptanceEvent {
  final List<String> codes;
  const RemoveEditingMaterialsByCodes({required this.codes});

  @override
  List<Object?> get props => [codes];
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
