/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:20:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 18:23:01
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import '../../models/auth/rf.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    on<AuthLoginWithPasswordRequested>(_onLoginWithPasswordRequested);
    on<AuthLoginWithSmsRequested>(_onLoginWithSmsRequested);
    on<AuthSmsCodeRequested>(_onSmsCodeRequested);
    on<AuthCaptchaRequested>(_onCaptchaRequested);
    on<AuthProjectSelected>(_onProjectSelected);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthTokenRefreshRequested>(_onTokenRefreshRequested);
    on<AuthProjectModeRequested>(_onProjectModeRequested);
    on<AuthStorekeeperModeRequested>(_onStorekeeperModeRequested);
  }

  Future<void> _onLoginWithPasswordRequested(
    AuthLoginWithPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.loginWithPassword(
        event.loginRequest,
        imgCode: event.imgCode,
      );
      if (result.isSuccess) {
        _handleLoginSuccess(result.data!, emit);
      } else {
        emit(AuthLoginFailure(error: result.msg));
      }
    } catch (e) {
      emit(AuthLoginFailure(error: e.toString()));
    }
  }

  Future<void> _onLoginWithSmsRequested(
    AuthLoginWithSmsRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.loginWithSms(
        event.phone,
        event.code,
        smsCode: event.smsCode,
      );
      if (result.isSuccess) {
        _handleLoginSuccess(result.data!, emit);
      } else {
        emit(AuthLoginFailure(error: result.msg));
      }
    } catch (e) {
      emit(AuthLoginFailure(error: e.toString()));
    }
  }

  Future<void> _onSmsCodeRequested(
    AuthSmsCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthSmsCodeSending());
    try {
      final result = await _authRepository.requestSmsCode(event.phone);
      if (result.isSuccess && result.data != null) {
        final smsCodeResult = result.data!;
        emit(
          AuthSmsCodeSent(phone: event.phone, smsCode: smsCodeResult.smsCode),
        );
      } else {
        emit(AuthSmsCodeFailure(error: result.msg));
      }
    } catch (e) {
      emit(AuthSmsCodeFailure(error: e.toString()));
    }
  }

  Future<void> _onCaptchaRequested(
    AuthCaptchaRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthCaptchaLoading());
    try {
      final result = await _authRepository.requestCaptcha();
      if (result.isSuccess && result.data != null) {
        final captchaResult = result.data!;
        emit(
          AuthCaptchaLoaded(
            captchaBase64: captchaResult.base64Data,
            imgCode: captchaResult.imgCode,
          ),
        );
      } else {
        emit(AuthCaptchaFailure(error: result.msg));
      }
    } catch (e) {
      emit(AuthCaptchaFailure(error: e.toString()));
    }
  }

  Future<void> _onProjectSelected(
    AuthProjectSelected event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuthLoginSuccess) {
      emit(AuthLoading());
      try {
        final result = await _authRepository.selectProject(event.projectId);
        if (result.isSuccess) {
          emit(
            AuthFullyAuthenticated(
              wxLoginVO: currentState.wxLoginVO,
              currentUserRoleInfo: result.data!,
            ),
          );
        } else {
          emit(AuthFailure(error: result.msg));
        }
      } catch (e) {
        emit(AuthFailure(error: e.toString()));
      }
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.checkToken();
      if (result.isSuccess) {
        _handleLoginSuccess(result.data!, emit);
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final refreshRequest = RF(uid: event.uid);
      final result = await _authRepository.refreshToken(refreshRequest);
      if (result.isSuccess) {
        emit(AuthTokenRefreshed(wxLoginVO: result.data!));
      } else {
        emit(AuthFailure(error: result.msg));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// 处理登录成功，检查是否需要身份选择
  void _handleLoginSuccess(
    dynamic wxLoginVO,
    Emitter<AuthState> emit,
  ) {
    // 检查用户是否为仓管员
    if (wxLoginVO.storekeeper == true) {
      // 仓管员需要选择身份
      emit(AuthIdentitySelectionRequired(wxLoginVO: wxLoginVO));
    } else {
      // 普通用户继续原有流程
      emit(AuthLoginSuccess(wxLoginVO: wxLoginVO));
    }
  }

  /// 处理选择项目参与方模式
  void _onProjectModeRequested(
    AuthProjectModeRequested event,
    Emitter<AuthState> emit,
  ) {
    final currentState = state;
    if (currentState is AuthIdentitySelectionRequired) {
      // 继续原有的项目选择流程
      emit(AuthLoginSuccess(wxLoginVO: currentState.wxLoginVO));
    }
  }

  /// 处理选择独立仓管员模式
  void _onStorekeeperModeRequested(
    AuthStorekeeperModeRequested event,
    Emitter<AuthState> emit,
  ) {
    final currentState = state;
    if (currentState is AuthIdentitySelectionRequired) {
      // 直接进入仓管员认证完成状态
      emit(AuthStorekeeperAuthenticated(wxLoginVO: currentState.wxLoginVO));
    }
  }
}
