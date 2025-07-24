import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import '../../models/acceptance/do_accept_vo.dart';
import '../../models/acceptance/do_accept_sign_in_vo.dart';
import '../../models/acceptance/common_do_business_audit_vo.dart';

abstract class AcceptanceEvent extends Equatable {
  const AcceptanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadAcceptanceDetail extends AcceptanceEvent {
  final int acceptanceId;
  final bool forceRefresh;

  const LoadAcceptanceDetail({
    required this.acceptanceId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [acceptanceId, forceRefresh];
}

class SubmitAcceptance extends AcceptanceEvent {
  final DoAcceptVO request;

  const SubmitAcceptance({required this.request});

  @override
  List<Object?> get props => [request];
}

class AuditAcceptance extends AcceptanceEvent {
  final CommonDoBusinessAuditVO request;

  const AuditAcceptance({required this.request});

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
