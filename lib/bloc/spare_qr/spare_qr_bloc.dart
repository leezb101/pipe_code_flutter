import 'package:pipe_code_flutter/bloc/spare_qr/spare_qr_event.dart';
import 'package:pipe_code_flutter/bloc/spare_qr/spare_qr_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/repositories/spareqr_repository.dart';

class SpareQrBloc extends Bloc<SpareQrEvent, SpareQrState> {
  final SpareqrRepository _repository;

  SpareQrBloc({required SpareqrRepository repository})
    : _repository = repository,
      super(SpareQrInitial()) {
    on<SpareQrDownloadRequested>(_onStartSpareQr);
    on<SpareQrReset>(_onReset);
    on<SpareQrResetWithFileCleanup>(_onResetWithFileCleanup);
    on<SpareQrFileShared>(_onFileShared);
  }

  Future<void> _onStartSpareQr(
    SpareQrDownloadRequested event,
    Emitter<SpareQrState> emit,
  ) async {
    await emit.forEach<SpareQrState>(
      _repository.downloadSpareqrZipFile(event.num),
      onData: (state) => state,
      onError: (error, stackTrace) => SpareQrFailure(error.toString()),
    );
  }

  void _onReset(SpareQrReset event, Emitter<SpareQrState> emit) {
    emit(SpareQrInitial());
  }

  Future<void> _onResetWithFileCleanup(
    SpareQrResetWithFileCleanup event,
    Emitter<SpareQrState> emit,
  ) async {
    await _repository.deleteFile(event.filePath);
    emit(SpareQrInitial());
  }

  Future<void> _onFileShared(
    SpareQrFileShared event,
    Emitter<SpareQrState> emit,
  ) async {
    await _repository.deleteFile(event.filePath);
    emit(SpareQrInitial());
  }
}
