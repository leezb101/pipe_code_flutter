import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/enum_repository.dart';
import '../../models/common/org_models.dart';
import '../../models/common/common_enum_vo.dart';

/// 枚举数据加载状态
enum EnumStatus { initial, loading, success, failure }

/// 枚举 Cubit 状态，直接暴露所有已拉取的枚举集合（按 EnumRepository 字段对应）
class EnumState {
  final EnumStatus status;
  final List<TodoType>? todoTypes;
  final List<MaterialGroup>? materialGroups;
  final List<MaterialType>? materialTypes;
  final List<OrgType>? orgTypes;
  final List<SimpleOrg>? orgs;
  final List<AcceptStatus>? acceptStatuses;
  final List<BusinessType>? businessTypes;
  final List<ProjectStatus>? projectStatuses;
  final List<ProjectSupplyType>? projectSupplyTypes;
  final List<ProjectType>? projectTypes;
  final List<ReturnType>? returnTypes;
  final String? error;

  const EnumState({
    this.status = EnumStatus.initial,
    this.todoTypes,
    this.materialGroups,
    this.materialTypes,
    this.orgTypes,
    this.orgs,
    this.acceptStatuses,
    this.businessTypes,
    this.projectStatuses,
    this.projectSupplyTypes,
    this.projectTypes,
    this.returnTypes,
    this.error,
  });

  EnumState copyWith({
    EnumStatus? status,
    List<TodoType>? todoTypes,
    List<MaterialGroup>? materialGroups,
    List<MaterialType>? materialTypes,
    List<OrgType>? orgTypes,
    List<SimpleOrg>? orgs,
    List<AcceptStatus>? acceptStatuses,
    List<BusinessType>? businessTypes,
    List<ProjectStatus>? projectStatuses,
    List<ProjectSupplyType>? projectSupplyTypes,
    List<ProjectType>? projectTypes,
    List<ReturnType>? returnTypes,
    String? error,
  }) {
    return EnumState(
      status: status ?? this.status,
      todoTypes: todoTypes ?? this.todoTypes,
      materialGroups: materialGroups ?? this.materialGroups,
      materialTypes: materialTypes ?? this.materialTypes,
      orgTypes: orgTypes ?? this.orgTypes,
      orgs: orgs ?? this.orgs,
      acceptStatuses: acceptStatuses ?? this.acceptStatuses,
      businessTypes: businessTypes ?? this.businessTypes,
      projectStatuses: projectStatuses ?? this.projectStatuses,
      projectSupplyTypes: projectSupplyTypes ?? this.projectSupplyTypes,
      projectTypes: projectTypes ?? this.projectTypes,
      returnTypes: returnTypes ?? this.returnTypes,
      error: error,
    );
  }
}

/// 全局唯一的 EnumCubit，负责统一拉取和管理所有枚举集合
class EnumCubit extends Cubit<EnumState> {
  final EnumRepository _enumRepository;

  EnumCubit(this._enumRepository) : super(const EnumState()) {
    _fetchEnums();
  }

  /// 拉取所有枚举数据，并同步到状态
  Future<void> _fetchEnums() async {
    emit(state.copyWith(status: EnumStatus.loading));
    try {
      await _enumRepository.initializeEnums();
      emit(
        state.copyWith(
          status: EnumStatus.success,
          todoTypes: _enumRepository.todoTypes,
          materialGroups: _enumRepository.materialGroups,
          materialTypes: _enumRepository.materialTypes,
          orgTypes: _enumRepository.orgTypes,
          orgs: _enumRepository.orgs,
          acceptStatuses: _enumRepository.acceptStatuses,
          businessTypes: _enumRepository.businessTypes,
          projectStatuses: _enumRepository.projectStatuses,
          projectSupplyTypes: _enumRepository.projectSupplyTypes,
          projectTypes: _enumRepository.projectTypes,
          returnTypes: _enumRepository.returnTypes,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: EnumStatus.failure, error: e.toString()));
    }
  }
}
