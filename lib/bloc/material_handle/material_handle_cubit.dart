/*
 * @Author: LeeZB
 * @Date: 2025-07-24 14:25:40
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-24 14:47:28
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/repositories/material_handle_repository.dart';
import 'material_handle_state.dart';

class MaterialHandleCubit extends Cubit<MaterialHandleState> {
  final MaterialHandleRepository _materialHandleRepository;

  MaterialHandleCubit({MaterialHandleRepository? materialHandleRepository})
    : _materialHandleRepository =
          materialHandleRepository ?? getIt<MaterialHandleRepository>(),
      super(MaterialHandleInitial());

  Future<void> getMaterialInfoFromQr(String qrCode) async {
    emit(MaterialHandleInProgress());

    final result = await _materialHandleRepository.scanBatchToQueryAll([
      qrCode,
    ]);

    if (result.isSuccess && result.data != null) {
      emit(MaterialHandleScanSuccess(result.data!));
    } else {
      emit(MaterialHandleScanFailure(result.msg ?? '扫码失败'));
    }
  }

  void reset() {
    emit(MaterialHandleInitial());
  }
}
