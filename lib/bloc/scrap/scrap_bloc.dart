/*
 * @Author: LeeZB
 * @Date: 2025-08-03
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 15:13:34
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/scrap/scrap_models.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/scrap_repository.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'scrap_event.dart';
import 'scrap_state.dart';

class ScrapBloc extends Bloc<ScrapEvent, ScrapState> {
  final ScrapRepository _scrapRepository;
  final MaterialHandleRepository _materialHandleRepository;

  ScrapBloc({
    required ScrapRepository scrapRepository,
    required MaterialHandleRepository materialHandleRepository,
  }) : _scrapRepository = scrapRepository,
       _materialHandleRepository = materialHandleRepository,
       super(const ScrapInitial()) {
    on<LoadScrapDetail>(_onLoadScrapDetail);
    on<InitializeScrapSubmission>(_onInitializeScrapSubmission);
    on<InitializeScrapFromCodes>(_onInitializeScrapFromCodes);
    on<AppendMaterialsFromCodes>(_onAppendMaterialsFromCodes);
    on<RemoveMaterialsFromCodes>(_onRemoveMaterialsFromCodes);
    on<AddScrapPhoto>(_onAddScrapPhoto);
    on<RemoveScrapPhoto>(_onRemoveScrapPhoto);
    on<UpdateMaterialQuantity>(_onUpdateMaterialQuantity);
    on<SubmitScrap>(_onSubmitScrap);
    on<ClearScrapData>(_onClearScrapData);
  }

  /// 加载报废详情
  Future<void> _onLoadScrapDetail(
    LoadScrapDetail event,
    Emitter<ScrapState> emit,
  ) async {
    try {
      emit(const ScrapLoading());
      Logger.info(
        'Loading scrap detail for id: ${event.scrapId}',
        tag: 'ScrapBloc',
      );

      final result = await _scrapRepository.getScrapDetail(event.scrapId);

      if (result.isSuccess && result.data != null) {
        emit(ScrapDetailLoaded(scrapDetail: result.data!));
        Logger.info('Scrap detail loaded successfully', tag: 'ScrapBloc');
      } else {
        emit(ScrapError(message: result.msg));
        Logger.error(
          'Failed to load scrap detail: ${result.msg}',
          tag: 'ScrapBloc',
        );
      }
    } catch (e) {
      emit(ScrapError(message: '加载报废详情时发生错误: $e'));
      Logger.error(
        'Exception while loading scrap detail: $e',
        tag: 'ScrapBloc',
      );
    }
  }

  /// 从MaterialInfoForBusiness初始化报废申请
  Future<void> _onInitializeScrapSubmission(
    InitializeScrapSubmission event,
    Emitter<ScrapState> emit,
  ) async {
    try {
      Logger.info(
        'Initializing scrap submission with ${event.materialInfoForBusiness.normals.length} materials',
        tag: 'ScrapBloc',
      );

      // 将MaterialInfo转换为MaterialVO
      final materialList = event.materialInfoForBusiness.normals
          .map((materialInfo) => _convertMaterialInfoToMaterialVO(materialInfo))
          .toList();

      emit(ScrapSubmissionReady(materialList: materialList));
      Logger.info(
        'Scrap submission initialized with ${materialList.length} materials',
        tag: 'ScrapBloc',
      );
    } catch (e) {
      emit(ScrapError(message: '初始化报废申请失败: $e'));
      Logger.error(
        'Exception while initializing scrap submission: $e',
        tag: 'ScrapBloc',
      );
    }
  }

  /// 从扫码列表初始化报废申请
  Future<void> _onInitializeScrapFromCodes(
    InitializeScrapFromCodes event,
    Emitter<ScrapState> emit,
  ) async {
    try {
      emit(const ScrapLoading());
      Logger.info(
        'Initializing scrap from ${event.codes.length} codes',
        tag: 'ScrapBloc',
      );

      // 调用MaterialHandleRepository的批量查询方法
      final result = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );

      if (result.isSuccess && result.data != null) {
        // 将MaterialInfo转换为MaterialVO
        final materialList = result.data!.normals
            .map(
              (materialInfo) => _convertMaterialInfoToMaterialVO(materialInfo),
            )
            .toList();

        emit(ScrapSubmissionReady(materialList: materialList));
        Logger.info(
          'Scrap submission initialized from codes with ${materialList.length} materials',
          tag: 'ScrapBloc',
        );
      } else {
        emit(ScrapError(message: result.msg));
        Logger.error(
          'Failed to query materials from codes: ${result.msg}',
          tag: 'ScrapBloc',
        );
      }
    } catch (e) {
      emit(ScrapError(message: '从扫码结果初始化报废申请失败: $e'));
      Logger.error(
        'Exception while initializing scrap from codes: $e',
        tag: 'ScrapBloc',
      );
    }
  }

  /// 从扫码列表追加材料到现有报废申请
  Future<void> _onAppendMaterialsFromCodes(
    AppendMaterialsFromCodes event,
    Emitter<ScrapState> emit,
  ) async {
    if (state is! ScrapSubmissionReady) {
      emit(const ScrapError(message: '当前状态不支持追加材料'));
      return;
    }

    try {
      final currentState = state as ScrapSubmissionReady;
      Logger.info(
        'Appending materials from ${event.codes.length} codes',
        tag: 'ScrapBloc',
      );

      // 调用MaterialHandleRepository的批量查询方法
      final result = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );

      if (result.isSuccess && result.data != null) {
        // 将新MaterialInfo转换为MaterialVO
        final newMaterialList = result.data!.normals
            .map(
              (materialInfo) => _convertMaterialInfoToMaterialVO(materialInfo),
            )
            .toList();

        // 合并现有材料和新材料
        final allMaterials = List<MaterialVO>.from(currentState.materialList);

        // 去重：避免添加重复的材料
        for (final newMaterial in newMaterialList) {
          final existingIndex = allMaterials.indexWhere(
            (existing) => existing.materialId == newMaterial.materialId,
          );

          if (existingIndex >= 0) {
            // 如果材料已存在，增加数量
            final existing = allMaterials[existingIndex];
            allMaterials[existingIndex] = existing.copyWith(
              num: existing.num + newMaterial.num,
            );
          } else {
            // 如果是新材料，直接添加
            allMaterials.add(newMaterial);
          }
        }

        emit(currentState.copyWith(materialList: allMaterials));
        Logger.info(
          'Materials appended successfully, total: ${allMaterials.length}',
          tag: 'ScrapBloc',
        );
      } else {
        emit(ScrapError(message: result.msg));
        Logger.error(
          'Failed to query materials from codes: ${result.msg}',
          tag: 'ScrapBloc',
        );
      }
    } catch (e) {
      emit(ScrapError(message: '追加材料失败: $e'));
      Logger.error(
        'Exception while appending materials from codes: $e',
        tag: 'ScrapBloc',
      );
    }
  }

  /// 从扫码列表删除材料
  Future<void> _onRemoveMaterialsFromCodes(
    RemoveMaterialsFromCodes event,
    Emitter<ScrapState> emit,
  ) async {
    if (state is! ScrapSubmissionReady) {
      emit(const ScrapError(message: '当前状态不支持删除材料'));
      return;
    }

    try {
      final currentState = state as ScrapSubmissionReady;
      Logger.info(
        'Removing materials from ${event.codes.length} codes',
        tag: 'ScrapBloc',
      );

      // 调用MaterialHandleRepository的批量查询方法
      final result = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );

      if (result.isSuccess && result.data != null) {
        // 将要删除的MaterialInfo转换为MaterialVO，获取materialId列表
        final materialIdsToRemove = result.data!.normals
            .map((materialInfo) => materialInfo.baseInfo.materialId)
            .toSet();

        // 从现有材料列表中移除匹配的材料
        final updatedMaterials = currentState.materialList
            .where(
              (material) => !materialIdsToRemove.contains(material.materialId),
            )
            .toList();

        emit(currentState.copyWith(materialList: updatedMaterials));
        Logger.info(
          'Materials removed successfully, remaining: ${updatedMaterials.length}',
          tag: 'ScrapBloc',
        );
      } else {
        emit(ScrapError(message: result.msg));
        Logger.error(
          'Failed to query materials from codes: ${result.msg}',
          tag: 'ScrapBloc',
        );
      }
    } catch (e) {
      emit(ScrapError(message: '删除材料失败: $e'));
      Logger.error(
        'Exception while removing materials from codes: $e',
        tag: 'ScrapBloc',
      );
    }
  }

  /// 添加照片
  Future<void> _onAddScrapPhoto(
    AddScrapPhoto event,
    Emitter<ScrapState> emit,
  ) async {
    if (state is ScrapSubmissionReady) {
      final currentState = state as ScrapSubmissionReady;

      // 限制最多6张照片
      if (currentState.photoUrls.length >= 6) {
        emit(const ScrapError(message: '最多只能添加6张照片'));
        return;
      }

      final updatedPhotos = List<String>.from(currentState.photoUrls)
        ..add(event.photoPath);

      emit(currentState.copyWith(photoUrls: updatedPhotos));
      Logger.info(
        'Photo added, total photos: ${updatedPhotos.length}',
        tag: 'ScrapBloc',
      );
    }
  }

  /// 删除照片
  Future<void> _onRemoveScrapPhoto(
    RemoveScrapPhoto event,
    Emitter<ScrapState> emit,
  ) async {
    if (state is ScrapSubmissionReady) {
      final currentState = state as ScrapSubmissionReady;

      if (event.index >= 0 && event.index < currentState.photoUrls.length) {
        final updatedPhotos = List<String>.from(currentState.photoUrls)
          ..removeAt(event.index);

        emit(currentState.copyWith(photoUrls: updatedPhotos));
        Logger.info(
          'Photo removed, total photos: ${updatedPhotos.length}',
          tag: 'ScrapBloc',
        );
      }
    }
  }

  /// 更新物料数量
  Future<void> _onUpdateMaterialQuantity(
    UpdateMaterialQuantity event,
    Emitter<ScrapState> emit,
  ) async {
    if (state is ScrapSubmissionReady) {
      final currentState = state as ScrapSubmissionReady;

      final updatedMaterials = currentState.materialList.map((material) {
        if (material.materialId == event.materialId) {
          return material.copyWith(num: event.quantity);
        }
        return material;
      }).toList();

      emit(currentState.copyWith(materialList: updatedMaterials));
      Logger.info(
        'Material quantity updated for id ${event.materialId}: ${event.quantity}',
        tag: 'ScrapBloc',
      );
    }
  }

  /// 提交报废申请
  Future<void> _onSubmitScrap(
    SubmitScrap event,
    Emitter<ScrapState> emit,
  ) async {
    if (state is ScrapSubmissionReady) {
      final currentState = state as ScrapSubmissionReady;

      try {
        // 验证数据
        if (currentState.materialList.isEmpty) {
          emit(const ScrapError(message: '请至少添加一个物料'));
          return;
        }

        emit(currentState.copyWith(isSubmitting: true));
        Logger.info('Submitting scrap request', tag: 'ScrapBloc');

        // 构建附件列表
        final attachmentList = currentState.photoUrls
            .map((url) => AttachmentVO(url: url))
            .toList();

        // 构建提交数据
        final scrapDetailVO = ScrapDetailVO(
          materialList: currentState.materialList,
          attachmentList: attachmentList,
        );

        // 提交请求
        final result = await _scrapRepository.submitScrap(scrapDetailVO);

        if (result.isSuccess) {
          emit(const ScrapSubmitted());
          Logger.info('Scrap submitted successfully', tag: 'ScrapBloc');
        } else {
          emit(ScrapError(message: result.msg));
          Logger.error(
            'Failed to submit scrap: ${result.msg}',
            tag: 'ScrapBloc',
          );
        }
      } catch (e) {
        emit(ScrapError(message: '提交报废申请时发生错误: $e'));
        Logger.error('Exception while submitting scrap: $e', tag: 'ScrapBloc');
      }
    }
  }

  /// 清空数据
  Future<void> _onClearScrapData(
    ClearScrapData event,
    Emitter<ScrapState> emit,
  ) async {
    emit(const ScrapInitial());
    Logger.info('Scrap data cleared', tag: 'ScrapBloc');
  }

  /// 将MaterialInfo转换为MaterialVO
  MaterialVO _convertMaterialInfoToMaterialVO(MaterialInfo materialInfo) {
    return MaterialVO(
      materialId: materialInfo.baseInfo.materialId,
      materialName: materialInfo.baseInfo.prodNm ?? '未知物料',
      num: 1, // 默认数量为1
    );
  }
}
