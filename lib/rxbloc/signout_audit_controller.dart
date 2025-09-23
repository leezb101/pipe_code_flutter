import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/signout/signout_info_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/signout_repository.dart';
import 'package:rxdart/rxdart.dart';

// lib/nativebloc/signout_audit_state.dart (简化版)

class SignoutAuditState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final SignoutInfoVo? signoutDetail; // 只需要这一个数据源！
  final String? errorMessage;
  final bool isSuccess;

  const SignoutAuditState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.signoutDetail,
    this.errorMessage,
    this.isSuccess = false,
  });

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitting,
    signoutDetail,
    errorMessage,
    isSuccess,
  ];

  SignoutAuditState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    SignoutInfoVo? signoutDetail,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return SignoutAuditState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      signoutDetail: signoutDetail ?? this.signoutDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class SignoutAuditController {
  final SignoutRepository _repository;

  // 使用BehaviorSubject保持最新状态
  final _stateSubject = BehaviorSubject<SignoutAuditState>.seeded(
    const SignoutAuditState(),
  );

  // 对外暴露的状态流
  Stream<SignoutAuditState> get state => _stateSubject
      .distinctUnique() // 避免重复状态更新
      .shareReplay(maxSize: 1);

  // 获取当前状态
  SignoutAuditState get currentState => _stateSubject.value;

  SignoutAuditController(this._repository);

  // 更新状态的私有方法
  void _updateState(SignoutAuditState newState) {
    _stateSubject.add(newState);
  }

  /// 🎯 核心方法：只需要加载出库详情，无需额外的仓库/用户信息请求
  Future<void> loadSignoutDetail(int signoutId) async {
    _updateState(
      currentState.copyWith(
        isLoading: true,
        errorMessage: null,
        isSuccess: false,
      ),
    );

    try {
      final result = await _repository.getSignoutDetail(signoutId);

      if (result.isSuccess && result.data != null) {
        _updateState(
          currentState.copyWith(isLoading: false, signoutDetail: result.data),
        );
      } else {
        _updateState(
          currentState.copyWith(isLoading: false, errorMessage: result.msg),
        );
      }
    } catch (e) {
      _updateState(
        currentState.copyWith(
          isLoading: false,
          errorMessage: '网络错误: ${e.toString()}',
        ),
      );
    }
  }

  /// 确认审核
  Future<void> confirmAudit(int signoutId) async {
    if (currentState.isSubmitting) return;

    _updateState(
      currentState.copyWith(
        isSubmitting: true,
        errorMessage: null,
        isSuccess: false,
      ),
    );

    try {
      final result = await _repository.auditSignout(
        CommonDoBusinessAuditVO(id: signoutId, pass: true, reason: null),
      );

      if (result.isSuccess) {
        _updateState(
          currentState.copyWith(isSubmitting: false, isSuccess: true),
        );
      } else {
        _updateState(
          currentState.copyWith(isSubmitting: false, errorMessage: result.msg),
        );
      }
    } catch (e) {
      _updateState(
        currentState.copyWith(
          isSubmitting: false,
          errorMessage: '网络错误: ${e.toString()}',
        ),
      );
    }
  }

  /// 拒绝审核
  Future<void> rejectAudit({
    required int signoutId,
    required String reason,
    List<String>? reasonVoice,
  }) async {
    if (currentState.isSubmitting) return;

    _updateState(
      currentState.copyWith(
        isSubmitting: true,
        errorMessage: null,
        isSuccess: false,
      ),
    );

    try {
      final result = await _repository.auditSignout(
        CommonDoBusinessAuditVO(
          id: signoutId,
          pass: false,
          reason: reason,
          reasonVoice: reasonVoice ?? [],
        ),
      );

      if (result.isSuccess) {
        _updateState(
          currentState.copyWith(isSubmitting: false, isSuccess: true),
        );
      } else {
        _updateState(
          currentState.copyWith(isSubmitting: false, errorMessage: result.msg),
        );
      }
    } catch (e) {
      _updateState(
        currentState.copyWith(
          isSubmitting: false,
          errorMessage: '网络错误: ${e.toString()}',
        ),
      );
    }
  }

  /// 清除错误信息
  void clearError() {
    if (currentState.errorMessage != null) {
      _updateState(currentState.copyWith(errorMessage: null));
    }
  }

  /// 重置成功状态
  void resetSuccess() {
    if (currentState.isSuccess) {
      _updateState(currentState.copyWith(isSuccess: false));
    }
  }

  /// 释放资源
  void dispose() {
    _stateSubject.close();
  }
}
