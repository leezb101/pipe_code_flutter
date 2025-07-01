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
      final user = await _userRepository.loadUserFromStorage();
      if (user != null) {
        emit(UserLoaded(user: user));
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
      await _userRepository.saveUserToStorage(event.user);
      emit(UserLoaded(user: event.user));
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
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        avatar: event.avatar,
      );
      emit(UserLoaded(user: updatedUser));
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