/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:50:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 23:50:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const UserInitial()) {
    on<UserLoadRequested>(_onLoadRequested);
    on<UserSetData>(_onSetData);
    on<UserUpdateProfile>(_onUpdateProfile);
    on<UserClearData>(_onClearData);
  }

  Future<void> _onLoadRequested(
    UserLoadRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final wxLoginVO = await _userRepository.loadUserFromStorage();
      if (wxLoginVO != null) {
        emit(UserLoaded(wxLoginVO: wxLoginVO));
      } else {
        emit(const UserEmpty());
      }
    } catch (e) {
      emit(UserError(error: e.toString()));
    }
  }

  Future<void> _onSetData(
    UserSetData event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _userRepository.saveUserData(event.wxLoginVO);
      emit(UserLoaded(wxLoginVO: event.wxLoginVO));
    } catch (e) {
      emit(UserError(error: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UserUpdateProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final updatedUser = await _userRepository.updateUserProfile(
        name: event.name,
        nick: event.nick,
        avatar: event.avatar,
        address: event.address,
        phone: event.phone,
      );
      if (updatedUser != null) {
        emit(UserLoaded(wxLoginVO: updatedUser));
      } else {
        emit(const UserError(error: '更新用户信息失败'));
      }
    } catch (e) {
      emit(UserError(error: e.toString()));
    }
  }

  Future<void> _onClearData(
    UserClearData event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _userRepository.clearUserData();
      emit(const UserEmpty());
    } catch (e) {
      emit(UserError(error: e.toString()));
    }
  }
}