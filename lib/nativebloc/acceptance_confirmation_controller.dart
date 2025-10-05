import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/acceptance/acceptance_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/acceptance_repository.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/services/tracing/improved_tracing_manager.dart';
import 'package:pipe_code_flutter/services/tracing/tracing_context.dart';

class AcceptanceConfirmationState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final AcceptanceInfoVO? acceptanceInfo;
  final String? errorMessage;
  final bool isSuccess;

  const AcceptanceConfirmationState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.acceptanceInfo,
    this.errorMessage,
    this.isSuccess = false,
  });

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    acceptanceInfo,
    errorMessage,
    isSuccess,
  ];

  AcceptanceConfirmationState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    AcceptanceInfoVO? acceptanceInfo,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return AcceptanceConfirmationState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      acceptanceInfo: acceptanceInfo ?? this.acceptanceInfo,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  String toString() {
    return 'AcceptanceConfirmationState('
        'isLoading: $isLoading, '
        'isSubmitting: $isSubmitting, '
        'acceptanceInfo: ${acceptanceInfo != null ? 'loaded' : 'null'}, '
        'errorMessage: $errorMessage, '
        'isSuccess: $isSuccess'
        ')';
  }
}

class AcceptanceConfirmationController {
  final AcceptanceRepository _repository;
  final ImprovedTracingManager _tracingManager = getIt<ImprovedTracingManager>();
  final _stateController =
      StreamController<AcceptanceConfirmationState>.broadcast();

  AcceptanceConfirmationState _currentState =
      const AcceptanceConfirmationState();

  // 对外暴露的状态流，使用distinct()避免重复状态
  Stream<AcceptanceConfirmationState> get state =>
      _stateController.stream.distinct();

  // 获取当前状态
  AcceptanceConfirmationState get currentState => _currentState;

  AcceptanceConfirmationController(this._repository);

  // 更新状态的私有方法，包含去重逻辑
  void _updateState(AcceptanceConfirmationState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _stateController.add(newState);
    }
  }

  // 加载验收详情
  Future<void> loadAcceptanceDetail(int acceptanceId, {TracingContext? tracingContext}) async {
    final operationContext = _tracingManager.createOperationContext(
      source: tracingContext?.source ?? 'AcceptanceConfirmationController',
      action: tracingContext?.action ?? 'loadAcceptanceDetail',
      description: tracingContext?.description ?? '加载验收详情',
      entityId: tracingContext?.entityId ?? acceptanceId.toString(),
    );

    await _tracingManager.scopeOperation(operationContext, () async {
      _updateState(
        _currentState.copyWith(
          isLoading: true,
          errorMessage: null,
          isSuccess: false,
        ),
      );

      try {
        final result = await _repository.getAcceptanceDetail(acceptanceId);
        if (result.isSuccess && result.data != null) {
          _updateState(
            _currentState.copyWith(isLoading: false, acceptanceInfo: result.data),
          );
        } else {
          _updateState(
            _currentState.copyWith(
              isLoading: false,
              errorMessage: result.msg.isNotEmpty ? result.msg : '获取验收详情失败',
            ),
          );
        }
      } catch (e) {
        _updateState(
          _currentState.copyWith(
            isLoading: false,
            errorMessage: '网络错误：${e.toString()}',
          ),
        );
      }
    });
  }

  // 确认验收
  Future<void> confirmAcceptance(int acceptanceId, {TracingContext? tracingContext}) async {
    if (_currentState.isSubmitting) return; // 防止重复提交

    final operationContext = _tracingManager.createOperationContext(
      source: tracingContext?.source ?? 'AcceptanceConfirmationController',
      action: tracingContext?.action ?? 'confirmAcceptance',
      description: tracingContext?.description ?? '确认验收',
      entityId: tracingContext?.entityId ?? acceptanceId.toString(),
    );

    await _tracingManager.scopeOperation(operationContext, () async {
      _updateState(
        _currentState.copyWith(
          isSubmitting: true,
          errorMessage: null,
          isSuccess: false,
        ),
      );

      try {
        final request = CommonDoBusinessAuditVO(id: acceptanceId, pass: true);
        final result = await _repository.auditAcceptance(request);

        if (result.isSuccess) {
          _updateState(
            _currentState.copyWith(isSubmitting: false, isSuccess: true),
          );
        } else {
          _updateState(
            _currentState.copyWith(
              isSubmitting: false,
              errorMessage: result.msg.isNotEmpty ? result.msg : '确认失败',
            ),
          );
        }
      } catch (e) {
        _updateState(
          _currentState.copyWith(
            isSubmitting: false,
            errorMessage: '网络错误：${e.toString()}',
          ),
        );
      }
    });
  }

  // 拒绝验收
  Future<void> rejectAcceptance({
    required int acceptanceId,
    required String reason,
    List<String>? reasonVoice,
    TracingContext? tracingContext,
  }) async {
    if (_currentState.isSubmitting) return; // 防止重复提交

    final operationContext = _tracingManager.createOperationContext(
      source: tracingContext?.source ?? 'AcceptanceConfirmationController',
      action: tracingContext?.action ?? 'rejectAcceptance',
      description: tracingContext?.description ?? '拒绝验收',
      entityId: tracingContext?.entityId ?? acceptanceId.toString(),
    );

    await _tracingManager.scopeOperation(operationContext, () async {
      _updateState(
        _currentState.copyWith(
          isSubmitting: true,
          errorMessage: null,
          isSuccess: false,
        ),
      );

      try {
        final request = CommonDoBusinessAuditVO(
          id: acceptanceId,
          pass: false,
          reason: reason,
          reasonVoice: reasonVoice ?? [],
        );
        final result = await _repository.auditAcceptance(request);

        if (result.isSuccess) {
          _updateState(
            _currentState.copyWith(isSubmitting: false, isSuccess: true),
          );
        } else {
          _updateState(
            _currentState.copyWith(
              isSubmitting: false,
              errorMessage: result.msg.isNotEmpty ? result.msg : '拒绝失败',
            ),
          );
        }
      } catch (e) {
        _updateState(
          _currentState.copyWith(
            isSubmitting: false,
            errorMessage: '网络错误：${e.toString()}',
          ),
        );
      }
    });
  }

  // 重置成功状态（用于处理完成功后的状态重置）
  void resetSuccess() {
    if (_currentState.isSuccess) {
      _updateState(_currentState.copyWith(isSuccess: false));
    }
  }

  // 清除错误消息
  void clearError() {
    if (_currentState.errorMessage != null) {
      _updateState(_currentState.copyWith(errorMessage: null));
    }
  }

  // 释放资源
  void dispose() {
    _stateController.close();
  }
}
