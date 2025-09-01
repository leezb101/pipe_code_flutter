import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/session/session_bloc.dart';
import 'package:pipe_code_flutter/bloc/session/session_state.dart';
import 'package:pipe_code_flutter/models/common/common_enum_vo.dart';
import 'package:pipe_code_flutter/models/user/current_user_on_project_role_info.dart';

enum TemporaryPageStatus {
  loadingRole,
  optionSelection,
  formReady,
  submitting,
  success,
  error,
}

enum TemporaryAuthType {
  subRole('授权下级账户'),
  labor('授权临时用户');

  final String label;
  const TemporaryAuthType(this.label);
}

class TemporaryAuthState extends Equatable {
  final TemporaryPageStatus status;

  /// 选择授权类型时的数据
  final List<TemporaryAuthType> availableOptions;
  final TemporaryAuthType? selectedOption;

  /// 表单字段
  final String? name;
  final String? phone;
  final Interval? interval;

  final String? errorMessage;

  const TemporaryAuthState({
    required this.status,
    required this.availableOptions,
    this.selectedOption,
    this.name,
    this.phone,
    this.interval,
    this.errorMessage,
  });

  TemporaryAuthState copyWith({
    TemporaryPageStatus? status,
    List<TemporaryAuthType>? availableOptions,
    TemporaryAuthType? selectedOption,
    String? name,
    String? phone,
    Interval? interval,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TemporaryAuthState(
      status: status ?? this.status,
      availableOptions: availableOptions ?? this.availableOptions,
      selectedOption: selectedOption ?? this.selectedOption,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      interval: interval ?? this.interval,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    availableOptions,
    selectedOption,
    name,
    phone,
    interval,
    errorMessage,
  ];
}

class TemporaryAuthCubit extends Cubit<TemporaryAuthState> {
  final SessionBloc _sessionBloc;
  late final StreamSubscription _sessionSubscription;

  TemporaryAuthCubit({required SessionBloc sessionBloc})
    : _sessionBloc = sessionBloc,
      super(
        const TemporaryAuthState(
          status: TemporaryPageStatus.loadingRole,
          availableOptions: [],
        ),
      ) {
    _sessionSubscription = _sessionBloc.stream.listen((sessionState) {
      if (sessionState is SessionProjectEstablished) {
        _onRoleDetermined(sessionState.currentUserRoleInfo);
      }
    });

    // 上面的只是sessionblo发生变化时，如果在初始化时已经创建好了sessionbloc，则需要走下面的方法
    final initialSessionState = _sessionBloc.state;
    if (initialSessionState is SessionProjectEstablished) {
      _onRoleDetermined(initialSessionState.currentUserRoleInfo);
    }
  }

  void _onRoleDetermined(CurrentUserOnProjectRoleInfo roleInfo) {
    List<TemporaryAuthType> options = [];
    if (roleInfo.projectRoleType.canSetDelegateLabor) {
      options.addAll([TemporaryAuthType.labor]);
    }
    if (roleInfo.projectRoleType.canSetDelegateSub) {
      options.addAll([TemporaryAuthType.subRole]);
    }

    emit(
      state.copyWith(
        status: TemporaryPageStatus.optionSelection,
        availableOptions: options,
      ),
    );
  }

  void selectTemporaryTypeOption(TemporaryAuthType option) {
    if (state.availableOptions.contains(option)) {
      emit(
        state.copyWith(
          selectedOption: option,
          status: TemporaryPageStatus.formReady,
          clearErrorMessage: true,
        ),
      );
    }
  }

  void clearErrorMessage() {
    emit(state.copyWith(clearErrorMessage: true));
  }

  void onNameChanged(String value) {
    emit(state.copyWith(name: value, clearErrorMessage: true));
  }

  void onPhoneChanged(String value) {
    emit(state.copyWith(phone: value, clearErrorMessage: true));
  }

  void onIntervalChanged(Interval value) {
    emit(state.copyWith(interval: value, clearErrorMessage: true));
  }

  Future<void> submitForm() async {
    if (state.selectedOption == TemporaryAuthType.subRole) {
      // Perform form submission logic here
    } else if (state.selectedOption == TemporaryAuthType.labor) {}

    // TODO: submit提交逻辑
  }

  @override
  Future<void> close() {
    _sessionSubscription.cancel();
    return super.close();
  }
}
