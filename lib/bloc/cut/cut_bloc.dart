import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/cut/cut_material_sub_vo.dart';
import 'package:pipe_code_flutter/models/cut/cut_request_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/cut_repository.dart';

import 'cut_event.dart';
import 'cut_state.dart';

class CutBloc extends Bloc<CutEvent, CutState> {
  final CutRepository _cutRepository;

  CutBloc({CutRepository? cutRepository})
    : _cutRepository = cutRepository ?? getIt<CutRepository>(),
      super(const CutState()) {
    on<CutReset>(_onReset);
    on<CutOriginalMaterialScanned>(_onOriginalMaterialScanned);
    on<CutOriginalPhotoUpdated>(_onOriginalPhotoUpdated);
    on<CutDescriptionUpdated>(_onDescriptionUpdated);
    on<CutDescriptionVoiceUpdated>(_onDescriptionVoiceUpdated);
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
    emit(
      state.copyWith(
        originalMaterialPhotoPath: event.photoPath,
        status: CutStatus.initial,
        clearMessages: true,
      ),
    );
  }

  void _onDescriptionUpdated(
    CutDescriptionUpdated event,
    Emitter<CutState> emit,
  ) {
    emit(
      state.copyWith(
        cutDescription: event.description,
        status: CutStatus.initial,
        clearMessages: true,
      ),
    );
  }

  void _onDescriptionVoiceUpdated(
    CutDescriptionVoiceUpdated event,
    Emitter<CutState> emit,
  ) {
    // 获取原本的录音文件路径列表
    final existingPaths = state.cutDescriptionVoicePaths ?? [];
    existingPaths.addAll(event.voicePaths);
    emit(
      state.copyWith(
        cutDescriptionVoicePaths: existingPaths,
        status: CutStatus.initial,
        clearMessages: true,
      ),
    );
  }

  void _onNewMaterialsScanned(
    CutNewMaterialsScanned event,
    Emitter<CutState> emit,
  ) {
    if (state.originalMaterialInfo == null) return;

    final existingQrCodes = state.newCutItems
        .map((item) => item.qrCode)
        .toSet();
    final uniqueNewQrCodes = event.qrCodes
        .where((qr) => !existingQrCodes.contains(qr))
        .toList();
    final duplicateCount = event.qrCodes.length - uniqueNewQrCodes.length;

    String? tip;
    if (duplicateCount > 0) {
      tip = '已自动过滤 $duplicateCount 个重复的耗材码';
    }

    // If there are no new unique items to add, just show the tip and return.
    if (uniqueNewQrCodes.isEmpty) {
      if (tip != null) {
        emit(
          state.copyWith(
            status: CutStatus.tip,
            tipMessage: tip,
            clearMessages: true, // Clear old error, set new tip
          ),
        );
      }
      return;
    }

    final newItems = uniqueNewQrCodes.map((qr) {
      return NewCutMaterialItem(
        qrCode: qr,
        materialName:
            state.originalMaterialInfo!.normals.first.baseInfo.prodNm ?? '未知产品',
      );
    }).toList();

    emit(
      state.copyWith(
        status: tip != null ? CutStatus.tip : CutStatus.initial,
        newCutItems: [...state.newCutItems, ...newItems],
        tipMessage: tip,
        clearMessages: true, // Clear old messages, set new tip if any
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
      emit(
        state.copyWith(
          newCutItems: updatedItems,
          status: CutStatus.initial,
          clearMessages: true,
        ),
      );
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
      emit(
        state.copyWith(
          newCutItems: updatedItems,
          status: CutStatus.initial,
          clearMessages: true,
        ),
      );
    }
  }

  void _onNewItemDeleted(CutNewItemDeleted event, Emitter<CutState> emit) {
    final updatedItems = List<NewCutMaterialItem>.from(state.newCutItems);
    if (event.index >= 0 && event.index < updatedItems.length) {
      updatedItems.removeAt(event.index);
      emit(
        state.copyWith(
          newCutItems: updatedItems,
          status: CutStatus.initial,
          clearMessages: true,
        ),
      );
    }
  }

  Future<void> _onSubmitted(CutSubmitted event, Emitter<CutState> emit) async {
    // --- Validation ---
    if (state.originalMaterialInfo?.normals.first.baseInfo.materialCode ==
        null) {
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
        return CutMaterialSubVO(
          qrCode: item.qrCode,
          img: item.photoPath!,
          len: item.length.toString(),
        );
      }).toList();

      final request = CutRequestVo(
        qrCode:
            state.originalMaterialInfo!.normals.first.baseInfo.materialCode!,
        img: state.originalMaterialPhotoPath!,
        description: state.cutDescription,
        descriptionVoice: state.cutDescriptionVoicePaths,
        cutMaterialSubVOS: subItems,
      );

      // --- API Calls ---
      // 1. Pre-check call. If it returns, it's a success (code 0).
      // If it has a tip (code -1), it will throw a TipException.
      // For other errors, it will throw a general exception.
      await _cutRepository.getTipsForCutting(request);

      // 2. If the pre-check was successful, execute the actual cut.
      await _cutRepository.doCut(request);

      emit(state.copyWith(status: CutStatus.success));
    } on TipException catch (e) {
      // Handle the specific tip case (code -1)
      emit(state.copyWith(status: CutStatus.tip, tipMessage: e.message));
    } catch (e) {
      // Handle all other errors
      emit(
        state.copyWith(status: CutStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
