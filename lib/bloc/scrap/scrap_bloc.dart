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
    on<InitializeScrapSubmission>(_onInitializeScrapSubmission);
    on<InitializeScrapFromCodes>(_onInitializeScrapFromCodes);
    on<AppendMaterialsFromCodes>(_onAppendMaterialsFromCodes);
    on<RemoveMaterialsFromCodes>(_onRemoveMaterialsFromCodes);
    on<UpdateScrapPhotos>(_onUpdateScrapPhotos);
    on<SubmitScrap>(_onSubmitScrap);
    on<LoadScrapDetail>(_onLoadScrapDetail);
    on<UpdateMaterialQuantity>(_onUpdateMaterialQuantity);
    on<ClearScrapData>(_onClearScrapData);
    on<ClearScrapErrorMessage>(_onClearScrapErrorMessage);
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
        emit(ScrapFatalError(message: result.msg));
        Logger.error(
          'Failed to load scrap detail: ${result.msg}',
          tag: 'ScrapBloc',
        );
      }
    } catch (e) {
      emit(ScrapFatalError(message: '加载报废详情时发生错误: $e'));
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
      emit(ScrapFatalError(message: '初始化报废申请失败: $e'));
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
        emit(ScrapSubmissionReady(errorMessage: result.msg));
        Logger.error(
          'Failed to query materials from codes: ${result.msg}',
          tag: 'ScrapBloc',
        );
      }
    } catch (e) {
      emit(ScrapFatalError(message: '从扫码结果初始化报废申请失败: $e'));
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
      emit(ScrapFatalError(message: '当前状态不支持追加材料'));
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
        final existedMaterials = <MaterialVO>[];

        // 去重：避免添加重复的材料
        for (final newMaterial in newMaterialList) {
          final existingIndex = allMaterials.indexWhere(
            (existing) => existing.materialId == newMaterial.materialId,
          );

          if (existingIndex >= 0) {
            // 弹出提示
            existedMaterials.add(newMaterial);
          } else {
            // 如果是新材料，直接添加
            allMaterials.add(newMaterial);
          }
        }

        emit(
          currentState.copyWith(
            materialList: allMaterials,
            errorMessage: existedMaterials.isNotEmpty
                ? '存在重复材料${existedMaterials.length}个,已忽略'
                : null,
          ),
        );
      } else {
        emit(currentState.copyWith(errorMessage: result.msg));
        Logger.error(
          'Failed to query materials from codes: ${result.msg}',
          tag: 'ScrapBloc',
        );
      }
    } catch (e) {
      emit(
        (state as ScrapSubmissionReady).copyWith(errorMessage: '追加材料失败: $e'),
      );
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
      emit(const ScrapFatalError(message: '当前状态不支持删除材料'));
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

        // 判断是否有不属于原本材料的材料，若有，记录下来以便提示
        final notExistedMaterials = <MaterialVO>[];
        for (final material in result.data!.normals) {
          if (!currentState.materialList.any(
            (m) => m.materialId == material.baseInfo.materialId,
          )) {
            notExistedMaterials.add(_convertMaterialInfoToMaterialVO(material));
          }
        }

        // 从现有材料列表中移除匹配的材料
        final updatedMaterials = currentState.materialList
            .where(
              (material) => !materialIdsToRemove.contains(material.materialId),
            )
            .toList();

        emit(
          currentState.copyWith(
            materialList: updatedMaterials,
            errorMessage: notExistedMaterials.isNotEmpty
                ? '存在多扫材料${notExistedMaterials.length}个,已忽略'
                : null,
          ),
        );
        Logger.info(
          'Materials removed successfully, remaining: ${updatedMaterials.length}',
          tag: 'ScrapBloc',
        );
      } else {
        emit(
          (state as ScrapSubmissionReady).copyWith(errorMessage: result.msg),
        );
        Logger.error(
          'Failed to query materials from codes: ${result.msg}',
          tag: 'ScrapBloc',
        );
      }
    } catch (e) {
      emit(
        (state as ScrapSubmissionReady).copyWith(errorMessage: '删除材料失败: $e'),
      );
      Logger.error(
        'Exception while removing materials from codes: $e',
        tag: 'ScrapBloc',
      );
    }
  }

  /// 更新照片列表
  Future<void> _onUpdateScrapPhotos(
    UpdateScrapPhotos event,
    Emitter<ScrapState> emit,
  ) async {
    if (state is ScrapSubmissionReady) {
      final currentState = state as ScrapSubmissionReady;
      emit(currentState.copyWith(photoUrls: event.photoPaths));
      Logger.info(
        'Photo list updated, total photos: ${event.photoPaths.length}',
        tag: 'ScrapBloc',
      );
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
          emit(currentState.copyWith(errorMessage: '请至少添加一个物料'));
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
          emit(currentState.copyWith(errorMessage: result.msg));
          Logger.error(
            'Failed to submit scrap: ${result.msg}',
            tag: 'ScrapBloc',
          );
        }
      } catch (e) {
        emit(currentState.copyWith(errorMessage: '提交报废申请时发生错误: $e'));
        Logger.error('Exception while submitting scrap: $e', tag: 'ScrapBloc');
      }
    }
  }

  Future<void> _onClearScrapErrorMessage(
    ClearScrapErrorMessage event,
    Emitter<ScrapState> emit,
  ) async {
    if (state is ScrapSubmissionReady) {
      final currentState = state as ScrapSubmissionReady;
      emit(currentState.copyWith(clearErrorMessage: true));
      Logger.info('Scrap error message cleared', tag: 'ScrapBloc');
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
