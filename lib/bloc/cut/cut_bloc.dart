import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/cut/cut_request_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/cut_repository.dart';

import 'cut_event.dart';
import 'cut_state.dart';

// Note: For a larger project, this custom exception should be in its own file.
/// Custom exception to handle server tips that are not critical errors.
class TipException implements Exception {
  final String message;
  TipException(this.message);

  @override
  String toString() => message;
}

class CutBloc extends Bloc<CutEvent, CutState> {
  final CutRepository _cutRepository;

  CutBloc({CutRepository? cutRepository})
    : _cutRepository = cutRepository ?? getIt<CutRepository>(),
      super(const CutState()) {
    on<CutReset>(_onReset);
    on<CutOriginalMaterialScanned>(_onOriginalMaterialScanned);
    on<CutOriginalPhotoUpdated>(_onOriginalPhotoUpdated);
    on<CutDescriptionUpdated>(_onDescriptionUpdated);
    on<CutNewMaterialsScanned>(_onNewMaterialsScanned);
    on<CutNewItemLengthUpdated>(_onNewItemLengthUpdated);
    on<CutNewItemPhotoUpdated>(_onNewItemPhotoUpdated);
    on<CutNewItemDeleted>(_onNewItemDeleted);
    on<CutSubmitted>(_onSubmitted);
  }

  void _onReset(CutReset event, Emitter<CutState> emit) {
    emit(const CutState());
  }

  void _onOriginalMaterialScanned(
    CutOriginalMaterialScanned event,
    Emitter<CutState> emit,
  ) {
    // When a new original material is scanned, clear all related fields.
    emit(
      state.copyWith(
        status: CutStatus.initial,
        originalMaterialInfo: event.materialInfo,
        newCutItems: [],
        clearMessages: true,
        clearOriginalMaterial:
            true, // This will clear photo and description as well
      ),
    );
    // We need to set the new material info after clearing
    emit(state.copyWith(originalMaterialInfo: event.materialInfo));
  }

  void _onOriginalPhotoUpdated(
    CutOriginalPhotoUpdated event,
    Emitter<CutState> emit,
  ) {
    emit(state.copyWith(originalMaterialPhotoPath: event.photoPath));
  }

  void _onDescriptionUpdated(
    CutDescriptionUpdated event,
    Emitter<CutState> emit,
  ) {
    emit(state.copyWith(cutDescription: event.description));
  }

  void _onNewMaterialsScanned(
    CutNewMaterialsScanned event,
    Emitter<CutState> emit,
  ) {
    if (state.originalMaterialInfo == null) return;

    final newItems = event.qrCodes.map((qr) {
      return NewCutMaterialItem(
        qrCode: qr,
        materialName: state.originalMaterialInfo!.normals[0].prodNm ?? '未知产品',
      );
    }).toList();

    emit(
      state.copyWith(
        status: CutStatus.initial,
        newCutItems: [...state.newCutItems, ...newItems],
      ),
    );
  }

  void _onNewItemLengthUpdated(
    CutNewItemLengthUpdated event,
    Emitter<CutState> emit,
  ) {
    final updatedItems = List<NewCutMaterialItem>.from(state.newCutItems);
    if (event.index >= 0 && event.index < updatedItems.length) {
      updatedItems[event.index] = updatedItems[event.index].copyWith(
        length: event.length,
      );
      emit(state.copyWith(newCutItems: updatedItems));
    }
  }

  void _onNewItemPhotoUpdated(
    CutNewItemPhotoUpdated event,
    Emitter<CutState> emit,
  ) {
    final updatedItems = List<NewCutMaterialItem>.from(state.newCutItems);
    if (event.index >= 0 && event.index < updatedItems.length) {
      updatedItems[event.index] = updatedItems[event.index].copyWith(
        photoPath: event.photoPath,
      );
      emit(state.copyWith(newCutItems: updatedItems));
    }
  }

  void _onNewItemDeleted(CutNewItemDeleted event, Emitter<CutState> emit) {
    final updatedItems = List<NewCutMaterialItem>.from(state.newCutItems);
    if (event.index >= 0 && event.index < updatedItems.length) {
      updatedItems.removeAt(event.index);
      emit(state.copyWith(newCutItems: updatedItems));
    }
  }

  Future<void> _onSubmitted(CutSubmitted event, Emitter<CutState> emit) async {
    // --- Validation ---
    if (state.originalMaterialInfo?.normals[0].materialCode == null) {
      emit(state.copyWith(status: CutStatus.failure, errorMessage: '缺少原耗材信息'));
      return;
    }
    if (state.originalMaterialPhotoPath == null ||
        state.originalMaterialPhotoPath!.isEmpty) {
      emit(state.copyWith(status: CutStatus.failure, errorMessage: '请上传原耗材照片'));
      return;
    }
    if (state.cutDescription == null || state.cutDescription!.isEmpty) {
      emit(state.copyWith(status: CutStatus.failure, errorMessage: '请输入业务描述'));
      return;
    }
    if (state.newCutItems.isEmpty) {
      emit(state.copyWith(status: CutStatus.failure, errorMessage: '请添加新耗材'));
      return;
    }

    final isAllValid = state.newCutItems.every(
      (item) =>
          item.length != null &&
          item.length! > 0 &&
          item.photoPath != null &&
          item.photoPath!.isNotEmpty,
    );

    if (!isAllValid) {
      emit(
        state.copyWith(
          status: CutStatus.failure,
          errorMessage: '请为所有新耗材填写有效的管节长并上传照片',
        ),
      );
      return;
    }

    emit(state.copyWith(status: CutStatus.submitting, clearMessages: true));

    try {
      // --- Request Body Construction ---
      final subItems = state.newCutItems.map((item) {
        return CutRequestVo(
          qrCode: item.qrCode,
          img: item.photoPath!,
          description: item.length.toString(),
          cutMaterialSubVOS: const [], // Must be empty for sub-items
        );
      }).toList();

      final request = CutRequestVo(
        qrCode: state.originalMaterialInfo!.normals[0].materialCode!,
        img: state.originalMaterialPhotoPath!,
        description: state.cutDescription,
        cutMaterialSubVOS: subItems,
      );

      // --- API Calls ---
      await _cutRepository.getTipsForCutting(request);
      await _cutRepository.doCut(request);

      emit(state.copyWith(status: CutStatus.success));
    } on TipException catch (e) {
      emit(state.copyWith(status: CutStatus.tip, tipMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(status: CutStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
