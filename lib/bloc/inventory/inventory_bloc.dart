import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/inventory/inventory_models.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/repositories/interfaces/inventory_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _inventoryRepository;
  final MaterialHandleRepository _materialHandleRepository;

  InventoryBloc({
    required InventoryRepository inventoryRepository,
    required MaterialHandleRepository materialHandleRepository,
  }) : _inventoryRepository = inventoryRepository,
       _materialHandleRepository = materialHandleRepository,
       super(const InventoryState()) {
    on<InventoryTasksFetched>(_onTasksFetched);
    on<InventoryDetailFetched>(_onDetailFetched);
    on<InventoryScanCompleted>(_onScanCompleted);
    on<InventoryMaterialsCompared>(_onMaterialsCompared);
    on<InventoryPhotosUpdated>(_onPhotosUpdated);
    on<InventorySubmitted>(_onSubmitted);
    on<InventoryReset>(_onReset);
  }

  Future<void> _onTasksFetched(
    InventoryTasksFetched event,
    Emitter<InventoryState> emit,
  ) async {
    if (state.hasReachedMax && !event.isRefresh) return;

    emit(state.copyWith(listStatus: DataStatus.loading));

    try {
      final pageNum = event.isRefresh ? 1 : state.currentPage;
      final response = await _inventoryRepository.getInventoryList(
        pageNum: pageNum,
        pageSize: 10,
      );

      final newList = event.isRefresh
          ? response.records
          : (List.of(state.inventoryList)..addAll(response.records));

      final hasReachedMax =
          response.records.isEmpty ||
          (response.pages != null && pageNum >= response.pages!);

      emit(
        state.copyWith(
          listStatus: DataStatus.success,
          inventoryList: newList,
          totalTasks: response.total,
          hasReachedMax: hasReachedMax,
          currentPage: pageNum + 1,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          listStatus: DataStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDetailFetched(
    InventoryDetailFetched event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(detailStatus: DataStatus.loading));
    try {
      final detail = await _inventoryRepository.getInventoryDetail(
        event.taskId,
      );
      emit(
        state.copyWith(
          detailStatus: DataStatus.success,
          inventoryDetail: detail,
          // 重置比对状态
          comparisonStatus: DataStatus.initial,
          matchedMaterialIds: {},
          surplusMaterials: [],
          submissionStatus: SubmissionStatus.initial,
          resetPhotos: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          detailStatus: DataStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onScanCompleted(
    InventoryScanCompleted event,
    Emitter<InventoryState> emit,
  ) async {
    if (state.inventoryDetail == null) return;
    emit(state.copyWith(comparisonStatus: DataStatus.loading));

    try {
      final result = await _materialHandleRepository.scanBatchToQueryAll(
        event.qrCodes,
      );

      if (result.isSuccess && result.data != null) {
        final scannedMaterials = result.data!.normals;
        final originalMaterialIds = state.inventoryDetail!.materials
            .map((m) => m.materialId)
            .toSet();

        final Set<int> newMatchedIds = Set.from(state.matchedMaterialIds);
        final List<MaterialInfo> newSurplusMaterials = List.from(
          state.surplusMaterials,
        );
        final existingSurplusIds = newSurplusMaterials
            .map((m) => m.baseInfo.materialId)
            .toSet();

        for (final scannedMaterial in scannedMaterials) {
          if (originalMaterialIds.contains(
            scannedMaterial.baseInfo.materialId,
          )) {
            newMatchedIds.add(scannedMaterial.baseInfo.materialId);
          } else {
            if (!existingSurplusIds.contains(
              scannedMaterial.baseInfo.materialId,
            )) {
              newSurplusMaterials.add(scannedMaterial);
              existingSurplusIds.add(scannedMaterial.baseInfo.materialId);
            }
          }
        }
        emit(
          state.copyWith(
            comparisonStatus: DataStatus.success,
            matchedMaterialIds: newMatchedIds,
            surplusMaterials: newSurplusMaterials,
          ),
        );
      } else {
        throw Exception(result.msg);
      }
    } catch (e) {
      emit(
        state.copyWith(
          comparisonStatus: DataStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMaterialsCompared(
    InventoryMaterialsCompared event,
    Emitter<InventoryState> emit,
  ) async {
    if (state.inventoryDetail == null) return;
    emit(state.copyWith(comparisonStatus: DataStatus.loading));

    try {
      final scannedMaterials = event.scannedMaterials;
      final originalMaterialIds = state.inventoryDetail!.materials
          .map((m) => m.materialId)
          .toSet();

      final Set<int> newMatchedIds = Set.from(state.matchedMaterialIds);
      final List<MaterialInfo> newSurplusMaterials = List.from(
        state.surplusMaterials,
      );
      final existingSurplusIds = newSurplusMaterials
          .map((m) => m.baseInfo.materialId)
          .toSet();

      for (final scannedMaterial in scannedMaterials) {
        if (originalMaterialIds.contains(
          scannedMaterial.baseInfo.materialId,
        )) {
          newMatchedIds.add(scannedMaterial.baseInfo.materialId);
        } else {
          if (!existingSurplusIds.contains(
            scannedMaterial.baseInfo.materialId,
          )) {
            newSurplusMaterials.add(scannedMaterial);
            existingSurplusIds.add(scannedMaterial.baseInfo.materialId);
          }
        }
      }
      emit(
        state.copyWith(
          comparisonStatus: DataStatus.success,
          matchedMaterialIds: newMatchedIds,
          surplusMaterials: newSurplusMaterials,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          comparisonStatus: DataStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onPhotosUpdated(
    InventoryPhotosUpdated event,
    Emitter<InventoryState> emit,
  ) {
    emit(state.copyWith(photo1: event.photo1, photo2: event.photo2));
  }

  Future<void> _onSubmitted(
    InventorySubmitted event,
    Emitter<InventoryState> emit,
  ) async {
    if (state.inventoryDetail == null) return;

    emit(state.copyWith(submissionStatus: SubmissionStatus.loading));

    try {
      final request = DoInventoryRequestVO(
        id: state.inventoryDetail!.id,
        materialIds: state.matchedMaterialIds.toList(),
        materialExtraIds: state.surplusMaterials
            .map((m) => m.baseInfo.materialId)
            .toList(),
        attachmentUrl1: null, // 根据需求, 暂时不处理文件上传
        attachmentUrl2: null,
      );

      await _inventoryRepository.submitInventory(request);
      emit(state.copyWith(submissionStatus: SubmissionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: SubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onReset(InventoryReset event, Emitter<InventoryState> emit) {
    emit(const InventoryState());
  }
}
