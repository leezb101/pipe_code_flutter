/*
 * @Author: LeeZB
 * @Date: 2025-08-28 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-28 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/acceptance/sign_in_info_vo.dart';
import '../repositories/interfaces/signin_repository.dart';

class SigninDetailState extends Equatable {
  const SigninDetailState({
    this.signinInfo,
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
  });

  final SignInInfoVO? signinInfo;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;

  SigninDetailState copyWith({
    SignInInfoVO? signinInfo,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
  }) {
    return SigninDetailState(
      signinInfo: signinInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [signinInfo, isLoading, error, isRefreshing];
}

class SigninDetailCubit extends Cubit<SigninDetailState> {
  final SigninRepository _signinRepository;

  SigninDetailCubit({required SigninRepository signinRepository})
    : _signinRepository = signinRepository,
      super(const SigninDetailState());

  Future<void> loadSigninDetail(int id) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final signinInfo = await _signinRepository.getSigninDetail(id);
      emit(state.copyWith(signinInfo: signinInfo, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> refreshSigninDetail(int id) async {
    emit(state.copyWith(isRefreshing: true, error: null));
    try {
      final signinInfo = await _signinRepository.getSigninDetail(id);
      emit(state.copyWith(signinInfo: signinInfo, isRefreshing: false));
    } catch (e) {
      emit(state.copyWith(isRefreshing: false, error: e.toString()));
    }
  }
}
