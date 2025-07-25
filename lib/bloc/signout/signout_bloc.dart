import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/repositories/signout_repository.dart';

import 'signout_event.dart';
import 'signout_state.dart';

class SignoutBloc extends Bloc<SignoutEvent, SignoutState> {
  final SignoutRepository _repository;

  SignoutBloc(this._repository) : super(SignoutInitial()) {
    on<LoadSignoutDetail>(_onLoadSignoutDetail);
    on<SubmitSignout>(_onSubmitSignout);
    on<AuditSignout>(_onAuditSignout);
    on<RefreshSignoutDetail>(_onRefreshSignoutDetail);
    on<LoadWarehouseUsers>(_onLoadWarehouseUsers);
    on<LoadWarehouseInfo>(_onLoadWarehouseInfo);
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
      emit(SignoutDetailError(result.msg ?? '加载失败'));
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
      emit(SignoutDetailError(result.msg ?? '加载失败'));
    }
  }

  Future<void> _onLoadWarehouseInfo(
    LoadWarehouseInfo event,
    Emitter<SignoutState> emit,
  ) async {
    final currentState = state;
    // 创建一个新的 readyState 来发出加载中信号
    SignoutReady newReadyState = currentState is SignoutReady
        ? currentState.copyWith(isWarehouseInfoLoading: true, clearError: true)
        : const SignoutReady(isWarehouseInfoLoading: true);

    emit(newReadyState);

    final result = await _repository.getWarehouseInfoByMaterialId(
      event.materialId,
    );
    if (result.isSuccess) {
      emit(
        newReadyState.copyWith(
          isWarehouseInfoLoading: false,
          clearError: true,
          warehouseInfo: result.data,
        ),
      );
      add(LoadWarehouseUsers(warehouseId: result.data!.id));
    } else {
      emit(
        newReadyState.copyWith(
          isWarehouseInfoLoading: false,
          warehouseInfoError: result.msg ?? '获取仓库信息失败，请重试',
        ),
      );
    }
  }

  Future<void> _onLoadWarehouseUsers(
    LoadWarehouseUsers event,
    Emitter<SignoutState> emit,
  ) async {
    final currentState = state;
    // 创建一个新的 readyState 来发出加载中信号
    // 如果当前是 SignoutReady，我们保留它的 signoutDetail
    // 如果当前是 SignoutInitial，我们创建一个不含 signoutDetail 的新 SignoutReady
    SignoutReady newReadyState;
    if (currentState is SignoutReady) {
      newReadyState = currentState.copyWith(
        isWarehouseInfoLoading: true,
        clearError: true,
      );
    } else {
      newReadyState = const SignoutReady(isWarehouseUsersLoading: true);
    }
    emit(newReadyState);

    final result = await _repository.getWarehouseUsers(event.warehouseId);
    if (result.isSuccess) {
      emit(
        newReadyState.copyWith(
          isWarehouseUsersLoading: false,
          clearError: true,
          warehouseUsers: result.data,
        ),
      );
    } else {
      emit(
        newReadyState.copyWith(
          isWarehouseUsersLoading: false,
          warehouseUsersError: result.msg ?? '获取仓库用户失败，请重试',
        ),
      );
    }
  }

  Future<void> _onSubmitSignout(
    SubmitSignout event,
    Emitter<SignoutState> emit,
  ) async {
    final currentState = state;
    emit(SignoutSubmitting());
    if (currentState is SignoutReady) {
      final result = await _repository.doSignout(event.request);
      if (result.isSuccess) {
        emit(SignoutSubmitted());
      } else {
        emit(currentState.copyWith(submitError: result.msg ?? '提交失败'));
      }
    }
  }

  Future<void> _onAuditSignout(
    AuditSignout event,
    Emitter<SignoutState> emit,
  ) async {
    final currentState = state;
    if (currentState is SignoutReady) {
      final result = await _repository.auditSignout(event.request);
      if (result.isSuccess) {
        emit(SignoutAudited());
      } else {
        emit(currentState.copyWith(auditError: result.msg ?? '审核失败'));
      }
    }
  }
}
