import 'dart:async';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/dispatch/dispatch_detail_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/dispatch_repository.dart';

class DispatchConfirmationState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final DispatchDetailVo? dispatchDetail;
  final String? errorMessage;
  final bool isSuccess;

  const DispatchConfirmationState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.dispatchDetail,
    this.errorMessage,
    this.isSuccess = false,
  });

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    dispatchDetail,
    errorMessage,
    isSuccess,
  ];

  DispatchConfirmationState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    DispatchDetailVo? dispatchDetail,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return DispatchConfirmationState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      dispatchDetail: dispatchDetail ?? this.dispatchDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  String toString() {
    return 'DispatchConfirmationState{isLoading: $isLoading, isSubmitting: $isSubmitting, dispatchDetail: $dispatchDetail, errorMessage: $errorMessage, isSuccess: $isSuccess}';
  }
}

class DispatchConfirmationController {
  final DispatchRepository _repository;
  final _stateController =
      StreamController<DispatchConfirmationState>.broadcast();

  DispatchConfirmationState _currentState = const DispatchConfirmationState();

  // 对外暴露的状态流，使用distinct()避免重复状态更新
  Stream<DispatchConfirmationState> get state =>
      _stateController.stream.distinct();

  // 获取当前状态
  DispatchConfirmationState get currentState => _currentState;

  DispatchConfirmationController(this._repository);

  // 更新状态的私有方法，包含去重逻辑
  void _updateState(DispatchConfirmationState newState) {
    if (newState != _currentState) {
      _currentState = newState;
      _stateController.add(_currentState);
    }
  }

  Future<void> loadDispatchDetail(int dispatchId) async {
    _updateState(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        isSuccess: false,
      ),
    );

    try {
      final result = await _repository.getDispatchDetail(dispatchId);
      if (result.isSuccess && result.data != null) {
        _updateState(
          _currentState.copyWith(isLoading: false, dispatchDetail: result.data),
        );
      } else {
        _updateState(
          _currentState.copyWith(isLoading: false, errorMessage: result.msg),
        );
      }
    } catch (e) {
      _updateState(
        _currentState.copyWith(
          isLoading: false,
          errorMessage: '网络错误: ${e.toString()}',
        ),
      );
    }
  }

  // 确认调拨
  Future<void> confirmDispatch(int dispatchId) async {
    if (_currentState.isSubmitting) return;

    _updateState(
      currentState.copyWith(
        isSubmitting: true,
        errorMessage: null,
        isSuccess: false,
      ),
    );

    try {
      final result = await _repository.auditDispatch(
        CommonDoBusinessAuditVO(id: dispatchId, pass: true, reason: null),
      );
      if (result.isSuccess) {
        _updateState(
          _currentState.copyWith(isSubmitting: false, isSuccess: true),
        );
      } else {
        _updateState(
          _currentState.copyWith(isSubmitting: false, errorMessage: result.msg),
        );
      }
    } catch (e) {
      _updateState(
        _currentState.copyWith(
          isSubmitting: false,
          errorMessage: '网络错误: ${e.toString()}',
        ),
      );
    }
  }

  // 拒绝调拨
  Future<void> rejectDispatch({
    required int dispatchId,
    required String reason,
  }) async {
    if (_currentState.isSubmitting) return;
    _updateState(
      currentState.copyWith(
        isSubmitting: true,
        errorMessage: null,
        isSuccess: false,
      ),
    );
    try {
      final result = await _repository.auditDispatch(
        CommonDoBusinessAuditVO(id: dispatchId, pass: false, reason: reason),
      );
      if (result.isSuccess) {
        _updateState(
          _currentState.copyWith(isSubmitting: false, isSuccess: true),
        );
      } else {
        _updateState(
          _currentState.copyWith(isSubmitting: false, errorMessage: result.msg),
        );
      }
    } catch (e) {
      _updateState(
        _currentState.copyWith(
          isSubmitting: false,
          errorMessage: '网络错误: ${e.toString()}',
        ),
      );
    }
  }

  void resetSuccess() {
    if (_currentState.isSuccess) {
      _updateState(_currentState.copyWith(isSuccess: false));
    }
  }

  void clearError() {
    if (_currentState.errorMessage != null) {
      _updateState(_currentState.copyWith(errorMessage: null));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
