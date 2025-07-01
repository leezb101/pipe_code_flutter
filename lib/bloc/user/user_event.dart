import 'package:equatable/equatable.dart';
import '../../models/user/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserLoadRequested extends UserEvent {
  const UserLoadRequested();
}

class UserSetData extends UserEvent {
  const UserSetData({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

class UserUpdateProfile extends UserEvent {
  const UserUpdateProfile({
    this.firstName,
    this.lastName,
    this.email,
    this.avatar,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatar;

  @override
  List<Object?> get props => [firstName, lastName, email, avatar];
}

class UserClearData extends UserEvent {
  const UserClearData();
}