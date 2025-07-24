import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import '../../models/acceptance/acceptance_info_vo.dart';
import '../../models/common/accept_user_info_vo.dart';
import '../../models/common/warehouse_user_info_vo.dart';
import '../../models/records/record_list_response.dart';
import '../../models/common/warehouse_vo.dart';

abstract class AcceptanceState extends Equatable {
  const AcceptanceState();

  @override
  List<Object?> get props => [];
}

class AcceptanceInitial extends AcceptanceState {
  const AcceptanceInitial();
}

class AcceptanceLoading extends AcceptanceState {
  const AcceptanceLoading();
}

class AcceptanceDetailLoaded extends AcceptanceState {
  final AcceptanceInfoVO acceptanceInfo;
  final Set<MaterialVO> matchedMaterials;

  final String? matchMessage;

  const AcceptanceDetailLoaded({
    required this.acceptanceInfo,
    this.matchedMaterials = const {},
    this.matchMessage,
  });

  @override
  List<Object?> get props => [acceptanceInfo, matchedMaterials, matchMessage];

  AcceptanceDetailLoaded copyWith({
    AcceptanceInfoVO? acceptanceInfo,
    Set<MaterialVO>? matchedMaterials,
    String? matchMessage,
    // 允许传递null来清除信息
    bool clearMatchMessage = false,
  }) {
    return AcceptanceDetailLoaded(
      acceptanceInfo: acceptanceInfo ?? this.acceptanceInfo,
      matchedMaterials: matchedMaterials ?? this.matchedMaterials,
      matchMessage: clearMatchMessage
          ? null
          : matchMessage ?? this.matchMessage,
    );
  }
}

class AcceptanceListLoaded extends AcceptanceState {
  final RecordListResponse recordList;

  const AcceptanceListLoaded({required this.recordList});

  @override
  List<Object?> get props => [recordList];
}

class AcceptanceSubmitting extends AcceptanceState {
  const AcceptanceSubmitting();
}

class AcceptanceSubmitted extends AcceptanceState {
  const AcceptanceSubmitted();
}

class AcceptanceAuditing extends AcceptanceState {
  const AcceptanceAuditing();
}

class AcceptanceAudited extends AcceptanceState {
  const AcceptanceAudited();
}

class AcceptanceSigningIn extends AcceptanceState {
  const AcceptanceSigningIn();
}

class AcceptanceSignedIn extends AcceptanceState {
  const AcceptanceSignedIn();
}

class AcceptanceError extends AcceptanceState {
  final String message;

  const AcceptanceError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AcceptanceEmpty extends AcceptanceState {
  const AcceptanceEmpty();
}

class AcceptanceUsersLoading extends AcceptanceState {
  const AcceptanceUsersLoading();
}

class AcceptanceUsersLoaded extends AcceptanceState {
  final AcceptUserInfoVO acceptUserInfo;

  const AcceptanceUsersLoaded({required this.acceptUserInfo});

  @override
  List<Object?> get props => [acceptUserInfo];
}

class WarehouseUsersLoading extends AcceptanceState {
  const WarehouseUsersLoading();
}

class WarehouseUsersLoaded extends AcceptanceState {
  final WarehouseUserInfoVO warehouseUserInfo;

  const WarehouseUsersLoaded({required this.warehouseUserInfo});

  @override
  List<Object?> get props => [warehouseUserInfo];
}

class WarehouseListLoading extends AcceptanceState {
  const WarehouseListLoading();
}

class WarehouseListLoaded extends AcceptanceState {
  final List<WarehouseVO> warehouseList;

  const WarehouseListLoaded({required this.warehouseList});

  @override
  List<Object?> get props => [warehouseList];
}
