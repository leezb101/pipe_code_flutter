/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:20:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 23:20:00
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
  }

  Future<void> _onLoginWithPasswordRequested(
    AuthLoginWithPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.loginWithPassword(event.loginRequest);
      if (result.isSuccess) {
        emit(AuthLoginSuccess(wxLoginVO: result.data!));
      } else {
        emit(AuthFailure(error: result.msg));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onLoginWithSmsRequested(
    AuthLoginWithSmsRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.loginWithSms(event.phone, event.code);
      if (result.isSuccess) {
        emit(AuthLoginSuccess(wxLoginVO: result.data!));
      } else {
        emit(AuthFailure(error: result.msg));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onSmsCodeRequested(
    AuthSmsCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthSmsCodeSending());
    try {
      final result = await _authRepository.requestSmsCode(event.phone);
      if (result.isSuccess) {
        emit(AuthSmsCodeSent(phone: event.phone));
      } else {
        emit(AuthFailure(error: result.msg));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onCaptchaRequested(
    AuthCaptchaRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthCaptchaLoading());
    try {
      final result = await _authRepository.requestCaptcha();
      if (result.isSuccess) {
        emit(AuthCaptchaLoaded(captchaBase64: result.data!));
      } else {
        emit(AuthFailure(error: result.msg));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
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
          emit(AuthFullyAuthenticated(
            wxLoginVO: currentState.wxLoginVO,
            currentUserRoleInfo: result.data!,
          ));
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
        emit(AuthLoginSuccess(wxLoginVO: result.data!));
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
}