import 'package:equatable/equatable.dart';
import '../../models/user/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  const UserLoaded({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

class UserEmpty extends UserState {
  const UserEmpty();
}

class UserError extends UserState {
  const UserError({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}