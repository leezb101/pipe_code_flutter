/*
 * @Author: LeeZB
 * @Date: 2025-07-30 17:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 12:04:38
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/models/return/do_return_req_vo.dart';
import 'package:pipe_code_flutter/models/return/return_detail_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/return_repository.dart';

part 'return_event.dart';
part 'return_state.dart';

class ReturnBloc extends Bloc<ReturnEvent, ReturnState> {
  final ReturnRepository _returnRepository;
  final MaterialHandleRepository _materialHandleRepository;

  ReturnBloc({
    ReturnRepository? returnRepository,
    MaterialHandleRepository? materialHandleRepository,
  }) : _returnRepository = returnRepository ?? getIt<ReturnRepository>(),
       _materialHandleRepository =
           materialHandleRepository ?? getIt<MaterialHandleRepository>(),
       super(const ReturnState()) {
    on<LoadReturnMaterialCodes>(_onLoadReturnMaterialCodes);
    on<UpdateReturnType>(_onUpdateReturnType);
    on<UpdateReturnRemark>(_onUpdateReturnRemark);
    on<UpdateReturnRemarkVoice>(_onUpdateReturnRemarkVoice);
    on<UpdateImageList>(_onUpdateImageList);
    on<SubmitReturn>(_onSubmitReturn);
    on<ResetState>(_onResetState);
    on<LoadReturnDetail>(_onLoadReturnDetail);
    on<UpdateReturnMaterials>(_onUpdateReturnMaterials);
  }

  // 处理加载扫码二维码事件
  Future<void> _onLoadReturnMaterialCodes(
    LoadReturnMaterialCodes event,
    Emitter<ReturnState> emit,
  ) async {
    emit(state.copyWith(status: ReturnStatus.loading, codes: event.codes));

    try {
      final rsp = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );
      if (rsp.isSuccess && rsp.data != null) {
        // 从物料信息中提取有效的物料列表
        final validMaterials = <MaterialVO>[];

        // 添加正常物料
        if (rsp.data!.normals.isNotEmpty) {
          validMaterials.addAll(
            rsp.data!.normals.map(
              (e) => MaterialVO(
                materialId: e.baseInfo.materialId,
                materialName: e.baseInfo.prodNm ?? '',
                num: 1,
              ),
            ),
          );
        }

        // 如果没有有效物料，抛出异常
        if (validMaterials.isEmpty) {
          // throw Exception('未找到有效的退库物料');
          emit(
            state.copyWith(
              status: ReturnStatus.failure,
              codes: const [],
              errorMessage: '未找到有效的退库物料',
            ),
          );
        }

        // 创建退库详情对象
        final returnDetail = ReturnDetailVo(
          materialList: validMaterials,
          imageList: [],
          returnType: state.returnType,
          returnRemark: state.returnRemark,
        );

        emit(
          state.copyWith(
            status: ReturnStatus.success,
            codes: const <String>[],
            returnDetail: returnDetail,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ReturnStatus.failure,
          codes: const [],
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // 处理更新退库类型事件
  Future<void> _onUpdateReturnType(
    UpdateReturnType event,
    Emitter<ReturnState> emit,
  ) async {
    emit(state.copyWith(returnType: event.returnType));
  }

  // 处理更新退库备注事件
  Future<void> _onUpdateReturnRemark(
    UpdateReturnRemark event,
    Emitter<ReturnState> emit,
  ) async {
    emit(state.copyWith(returnRemark: event.returnRemark));
  }

  Future<void> _onUpdateReturnRemarkVoice(
    UpdateReturnRemarkVoice event,
    Emitter<ReturnState> emit,
  ) async {
    final currentState = state;
    // 先获取原本的语音列表，再将新进的语音列表的元素添加进去
    final updatedVoiceList = List<String>.from(
      (currentState.returnRemarkVoice ?? []).map((e) => e),
    )..addAll(event.returnRemarkVoice);
    emit(state.copyWith(returnRemarkVoice: updatedVoiceList));
  }

  // 处理更新图片附件事件
  Future<void> _onUpdateImageList(
    UpdateImageList event,
    Emitter<ReturnState> emit,
  ) async {
    emit(state.copyWith(imageList: event.imageList));
  }

  // 处理提交退库申请事件
  Future<void> _onSubmitReturn(
    SubmitReturn event,
    Emitter<ReturnState> emit,
  ) async {
    emit(state.copyWith(status: ReturnStatus.loading));

    try {
      // 验证必要参数
      if (state.returnDetail == null ||
          state.returnDetail!.materialList!.isEmpty) {
        throw Exception('退库物料信息不能为空');
      }

      // 创建退库请求对象
      final returnRequest = DoReturnReqVo(
        materialList: state.returnDetail!.materialList!,
        imageList: state.imageList,
        returnType: state.returnType,
        returnRemark: state.returnRemark,
        returnRemarkVoice: state.returnRemarkVoice,
      );

      // 调用退库API
      await _returnRepository.doReturn(returnRequest);

      emit(state.copyWith(status: ReturnStatus.returnSuccess));
    } catch (e) {
      emit(
        state.copyWith(
          status: ReturnStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // 处理重置状态事件
  Future<void> _onResetState(
    ResetState event,
    Emitter<ReturnState> emit,
  ) async {
    emit(const ReturnState());
  }

  // 处理加载退库详情事件
  Future<void> _onLoadReturnDetail(
    LoadReturnDetail event,
    Emitter<ReturnState> emit,
  ) async {
    emit(state.copyWith(status: ReturnStatus.loading));

    try {
      final returnDetail = await _returnRepository.getReturnDetail(event.id);
      emit(
        state.copyWith(
          status: ReturnStatus.success,
          returnDetail: returnDetail,
          returnType: returnDetail.returnType,
          returnRemark: returnDetail.returnRemark,
          imageList: returnDetail.imageList ?? [],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ReturnStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // 处理动态更新退库物料（追加 / 移除）
  Future<void> _onUpdateReturnMaterials(
    UpdateReturnMaterials event,
    Emitter<ReturnState> emit,
  ) async {
    final currentDetail = state.returnDetail;
    if (currentDetail == null) return; // 无详情不处理
    emit(
      state.copyWith(
        returnDetail: currentDetail.copyWith(materialList: event.materials),
      ),
    );
  }
}
