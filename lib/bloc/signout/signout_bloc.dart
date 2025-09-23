import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/repositories/interfaces/signout_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';

import 'signout_event.dart';
import 'signout_state.dart';

class SignoutBloc extends Bloc<SignoutEvent, SignoutState> {
  final SignoutRepository _repository;
  final MaterialHandleRepository _materialHandleRepository;

  SignoutBloc(this._repository, this._materialHandleRepository)
    : super(SignoutInitial()) {
    on<LoadSignoutDetail>(_onLoadSignoutDetail);
    on<SubmitSignout>(_onSubmitSignout);
    on<RefreshSignoutDetail>(_onRefreshSignoutDetail);
    on<LoadWarehouseUsers>(_onLoadWarehouseUsers);
    on<LoadWarehouseInfo>(_onLoadWarehouseInfo);
    // Editing flow
    on<InitializeMaterialsFromCodes>(_onInitializeMaterialsFromCodes);
    on<InitializeEditingMaterials>(_onInitializeEditingMaterials);
    on<AppendEditingMaterialsByCodes>(_onAppendEditingMaterialsByCodes);
    on<RemoveEditingMaterialsByCodes>(_onRemoveEditingMaterialsByCodes);
    on<ClearEditingMessage>(_onClearEditingMessage);
  }

  Future<void> _onLoadSignoutDetail(
    LoadSignoutDetail event,
    Emitter<SignoutState> emit,
  ) async {
    emit(SignoutLoading());
    final result = await _repository.getSignoutDetail(event.signinId);
    if (result.isSuccess) {
      emit(SignoutReady(signoutDetail: result.data!));
    } else {
      emit(SignoutDetailError(result.msg));
    }
  }

  Future<void> _onRefreshSignoutDetail(
    RefreshSignoutDetail event,
    Emitter<SignoutState> emit,
  ) async {
    emit(SignoutLoading());
    final result = await _repository.getSignoutDetail(event.signinId);
    if (result.isSuccess) {
      emit(SignoutReady(signoutDetail: result.data!));
    } else {
      emit(SignoutDetailError(result.msg));
    }
  }

  Future<void> _onLoadWarehouseInfo(
    LoadWarehouseInfo event,
    Emitter<SignoutState> emit,
  ) async {
    final currentState = state;
    // If we're in editing state, keep editing and mark loading there
    if (currentState is SignoutEditingState) {
      emit(currentState.copyWith(isWarehouseInfoLoading: true));
    } else {
      // 创建一个新的 readyState 来发出加载中信号
      SignoutReady newReadyState = currentState is SignoutReady
          ? currentState.copyWith(
              isWarehouseInfoLoading: true,
              clearError: true,
            )
          : const SignoutReady(isWarehouseInfoLoading: true);
      emit(newReadyState);
    }

    final result = await _repository.getWarehouseInfoByMaterialId(
      event.materialId,
    );
    if (result.isSuccess) {
      final data = result.data;
      final st = state;
      if (st is SignoutEditingState) {
        emit(
          st.copyWith(
            isWarehouseInfoLoading: false,
            warehouseInfo: data,
            warehouseInfoError: null,
          ),
        );
      } else if (st is SignoutReady) {
        emit(
          st.copyWith(
            isWarehouseInfoLoading: false,
            clearError: true,
            warehouseInfo: data,
          ),
        );
      }
      if (data != null) {
        add(LoadWarehouseUsers(warehouseId: data.id));
      }
    } else {
      final st = state;
      if (st is SignoutEditingState) {
        emit(
          st.copyWith(
            isWarehouseInfoLoading: false,
            warehouseInfoError: result.msg,
          ),
        );
      } else if (st is SignoutReady) {
        emit(
          st.copyWith(
            isWarehouseInfoLoading: false,
            warehouseInfoError: result.msg,
          ),
        );
      }
    }
  }

  Future<void> _onLoadWarehouseUsers(
    LoadWarehouseUsers event,
    Emitter<SignoutState> emit,
  ) async {
    final currentState = state;
    if (currentState is SignoutEditingState) {
      emit(currentState.copyWith(isWarehouseUsersLoading: true));
    } else {
      // 创建一个新的 readyState 来发出加载中信号
      // 如果当前是 SignoutReady，我们保留它的 signoutDetail
      // 如果当前是 SignoutInitial，我们创建一个不含 signoutDetail 的新 SignoutReady
      SignoutReady newReadyState;
      if (currentState is SignoutReady) {
        newReadyState = currentState.copyWith(
          isWarehouseUsersLoading: true,
          clearError: true,
        );
      } else {
        newReadyState = const SignoutReady(isWarehouseUsersLoading: true);
      }
      emit(newReadyState);
    }

    final result = await _repository.getWarehouseUsers(event.warehouseId);
    if (result.isSuccess) {
      final st = state;
      if (st is SignoutEditingState) {
        emit(
          st.copyWith(
            isWarehouseUsersLoading: false,
            warehouseUsers: result.data,
            warehouseUsersError: null,
          ),
        );
      } else if (st is SignoutReady) {
        emit(
          st.copyWith(
            isWarehouseUsersLoading: false,
            clearError: true,
            warehouseUsers: result.data,
          ),
        );
      }
    } else {
      final st = state;
      if (st is SignoutEditingState) {
        emit(
          st.copyWith(
            isWarehouseUsersLoading: false,
            warehouseUsersError: result.msg,
          ),
        );
      } else if (st is SignoutReady) {
        emit(
          st.copyWith(
            isWarehouseUsersLoading: false,
            warehouseUsersError: result.msg,
          ),
        );
      }
    }
  }

  Future<void> _onSubmitSignout(
    SubmitSignout event,
    Emitter<SignoutState> emit,
  ) async {
    final currentState = state;
    if (currentState is SignoutEditingState) {
      // stay in editing mode to keep UI context stable
      emit(currentState.copyWith(isSubmitting: true));
      final result = await _repository.doSignout(event.request);
      if (result.isSuccess) {
        emit(const SignoutSubmitted());
      } else {
        emit(
          currentState.copyWith(isSubmitting: false, submitError: result.msg),
        );
      }
      return;
    }
    if (currentState is SignoutReady) {
      emit(const SignoutSubmitting());
      final result = await _repository.doSignout(event.request);
      if (result.isSuccess) {
        emit(const SignoutSubmitted());
      } else {
        emit(currentState.copyWith(submitError: result.msg));
      }
    }
  }

  // ========== QR Scan integration & Editing for SignoutPage ==========
  Future<void> _onInitializeMaterialsFromCodes(
    InitializeMaterialsFromCodes event,
    Emitter<SignoutState> emit,
  ) async {
    try {
      if (event.codes.isEmpty) return;
      final rsp = event.isBatch
          ? await _materialHandleRepository.scanBatchToQueryAll(event.codes)
          : await _materialHandleRepository.scanSingleToQueryAll(
              event.codes.first,
            );
      if (rsp.isSuccess && rsp.data != null) {
        final MaterialInfoForBusiness bundle = rsp.data!;
        final ids = bundle.normals.map((m) => m.baseInfo.materialId).toSet();
        emit(
          SignoutEditingState(
            currentMaterials: bundle.normals,
            materialIds: ids,
            message: null,
          ),
        );
        // preload warehouse info using first materialId
        if (bundle.normals.isNotEmpty) {
          add(
            LoadWarehouseInfo(
              materialId: bundle.normals.first.baseInfo.materialId,
            ),
          );
        }
      } else {
        emit(SignoutDetailError(rsp.msg));
      }
    } catch (e) {
      emit(const SignoutDetailError('解析扫码列表失败'));
    }
  }

  void _onInitializeEditingMaterials(
    InitializeEditingMaterials event,
    Emitter<SignoutState> emit,
  ) {
    final ids = event.initial.map((m) => m.baseInfo.materialId).toSet();
    emit(
      SignoutEditingState(
        currentMaterials: List.of(event.initial),
        materialIds: ids,
        message: null,
      ),
    );
  }

  Future<void> _onAppendEditingMaterialsByCodes(
    AppendEditingMaterialsByCodes event,
    Emitter<SignoutState> emit,
  ) async {
    try {
      if (event.codes.isEmpty) return;
      final rsp = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );
      if (!rsp.isSuccess || rsp.data == null) {
        emit(const SignoutDetailError('新增码未查到物料信息'));
        return;
      }
      final currentState = state;
      final editing = currentState is SignoutEditingState
          ? currentState
          : const SignoutEditingState(currentMaterials: [], materialIds: {});
      final list = List.of(editing.currentMaterials);
      final ids = Set<int>.from(editing.materialIds);
      int added = 0;
      int dup = 0;
      for (final m in rsp.data!.normals) {
        final id = m.baseInfo.materialId;
        if (ids.contains(id)) {
          dup++;
          continue;
        }
        ids.add(id);
        list.add(m);
        added++;
      }
      emit(
        editing.copyWith(
          currentMaterials: list,
          materialIds: ids,
          message: added > 0
              ? '新增 $added 个${dup > 0 ? '，忽略重复 $dup 个' : ''}'
              : '暂无可新增物料',
        ),
      );
    } catch (e) {
      emit(const SignoutDetailError('获取物料信息失败'));
    }
  }

  Future<void> _onRemoveEditingMaterialsByCodes(
    RemoveEditingMaterialsByCodes event,
    Emitter<SignoutState> emit,
  ) async {
    try {
      if (event.codes.isEmpty) return;
      final rsp = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );
      if (!rsp.isSuccess || rsp.data == null) {
        emit(const SignoutDetailError('未匹配到可剔除的码'));
        return;
      }
      final currentState = state;
      final editing = currentState is SignoutEditingState
          ? currentState
          : const SignoutEditingState(currentMaterials: [], materialIds: {});
      final idsToRemove = rsp.data!.normals
          .map((m) => m.baseInfo.materialId)
          .toSet();
      final before = editing.currentMaterials.length;
      final newList = editing.currentMaterials
          .where((m) => !idsToRemove.contains(m.baseInfo.materialId))
          .toList();
      final removed = before - newList.length;
      final existingIds = editing.currentMaterials
          .map((m) => m.baseInfo.materialId)
          .toSet();
      final unmatched = idsToRemove.difference(existingIds).length;
      final newIds = Set<int>.from(editing.materialIds)..removeAll(idsToRemove);
      final msg = removed > 0
          ? '已剔除 $removed 个${unmatched > 0 ? '，忽略未在页面 $unmatched 个' : ''}'
          : '未找到可剔除的物料';
      emit(
        editing.copyWith(
          currentMaterials: newList,
          materialIds: newIds,
          message: msg,
        ),
      );
    } catch (e) {
      emit(const SignoutDetailError('剔除失败'));
    }
  }

  void _onClearEditingMessage(
    ClearEditingMessage event,
    Emitter<SignoutState> emit,
  ) {
    final currentState = state;
    if (currentState is SignoutEditingState) {
      emit(currentState.copyWith(clearMessage: true));
    }
  }
}
