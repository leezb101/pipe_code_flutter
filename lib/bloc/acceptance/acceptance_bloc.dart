/*
 * @Author: LeeZB
 * @Date: 2025-07-23 17:28:27
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 19:49:04
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import '../../repositories/acceptance_repository.dart';
import '../../repositories/material_handle_repository.dart';
import '../../utils/logger.dart';
import 'acceptance_event.dart';
import 'acceptance_state.dart';

class AcceptanceBloc extends Bloc<AcceptanceEvent, AcceptanceState> {
  final AcceptanceRepository _repository;
  final MaterialHandleRepository _materialHandleRepository;

  AcceptanceBloc(this._repository, this._materialHandleRepository)
    : super(const AcceptanceInitial()) {
    on<LoadAcceptanceDetail>(_onLoadAcceptanceDetail);
    on<SubmitAcceptance>(_onSubmitAcceptance);
    on<AuditAcceptance>(_onAuditAcceptance);
    on<DoAcceptanceSignIn>(_onDoAcceptanceSignIn);
    on<LoadAcceptanceList>(_onLoadAcceptanceList);
    on<RefreshAcceptanceDetail>(_onRefreshAcceptanceDetail);
    on<ClearAcceptanceCache>(_onClearAcceptanceCache);
    on<LoadAcceptanceUsers>(_onLoadAcceptanceUsers);
    on<LoadWarehouseUsers>(_onLoadWarehouseUsers);
    on<LoadWarehouseList>(_onLoadWarehouseList);
    // on<ScanMaterialForSignin>(_onScanMaterialForSignin);
    on<MatchScannedMaterial>(_onMatchScannedMaterial);
  }

  Future<void> _onLoadAcceptanceDetail(
    LoadAcceptanceDetail event,
    Emitter<AcceptanceState> emit,
  ) async {
    try {
      emit(const AcceptanceLoading());
      Logger.info(
        'Loading acceptance detail for id: ${event.acceptanceId}',
        tag: 'AcceptanceBloc',
      );

      final result = await _repository.getAcceptanceDetail(event.acceptanceId);

      if (result.isSuccess && result.data != null) {
        emit(AcceptanceDetailLoaded(acceptanceInfo: result.data!));
        Logger.info(
          'Acceptance detail loaded successfully',
          tag: 'AcceptanceBloc',
        );
      } else {
        emit(AcceptanceError(message: result.msg ?? '获取验收详情失败'));
        Logger.error(
          'Failed to load acceptance detail: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
      }
    } catch (e) {
      emit(AcceptanceError(message: '获取验收详情失败，请重试'));
      Logger.error(
        'Error loading acceptance detail: $e',
        tag: 'AcceptanceBloc',
      );
    }
  }

  Future<void> _onSubmitAcceptance(
    SubmitAcceptance event,
    Emitter<AcceptanceState> emit,
  ) async {
    try {
      emit(const AcceptanceSubmitting());
      Logger.info('Submitting acceptance', tag: 'AcceptanceBloc');

      final result = await _repository.submitAcceptance(event.request);

      if (result.isSuccess) {
        emit(const AcceptanceSubmitted());
        Logger.info('Acceptance submitted successfully', tag: 'AcceptanceBloc');
      } else {
        emit(AcceptanceError(message: result.msg ?? '提交验收失败'));
        Logger.error(
          'Failed to submit acceptance: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
      }
    } catch (e) {
      emit(AcceptanceError(message: '提交验收失败，请重试'));
      Logger.error('Error submitting acceptance: $e', tag: 'AcceptanceBloc');
    }
  }

  Future<void> _onAuditAcceptance(
    AuditAcceptance event,
    Emitter<AcceptanceState> emit,
  ) async {
    try {
      emit(const AcceptanceAuditing());
      Logger.info(
        'Auditing acceptance with id: ${event.request.id}',
        tag: 'AcceptanceBloc',
      );

      final result = await _repository.auditAcceptance(event.request);

      if (result.isSuccess) {
        emit(const AcceptanceAudited());
        Logger.info('Acceptance audited successfully', tag: 'AcceptanceBloc');
      } else {
        emit(AcceptanceError(message: result.msg ?? '审核验收失败'));
        Logger.error(
          'Failed to audit acceptance: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
      }
    } catch (e) {
      emit(AcceptanceError(message: '审核验收失败，请重试'));
      Logger.error('Error auditing acceptance: $e', tag: 'AcceptanceBloc');
    }
  }

  Future<void> _onDoAcceptanceSignIn(
    DoAcceptanceSignIn event,
    Emitter<AcceptanceState> emit,
  ) async {
    final currentState = state;
    // 开始提交之前，发出一个加载状态，同时保留当前数据
    if (currentState is AcceptanceDetailLoaded) {
      // UI层通过判断state is acceptanceLoading && state is! AcceptanceDetailLoaded 来判断是否显示加载中
      emit(AcceptanceLoading());
    }

    final result = await _repository.doAcceptanceSignIn(event.request);

    if (result.isSuccess) {
      emit(AcceptanceSignedIn());
    } else {
      if (currentState is AcceptanceDetailLoaded) {
        emit(currentState);
      }
      emit(AcceptanceError(message: result.msg ?? '验收入库失败'));
    }
    // try {
    //   emit(const AcceptanceSigningIn());
    //   Logger.info(
    //     'Processing acceptance sign-in for id: ${event.request.acceptId}',
    //     tag: 'AcceptanceBloc',
    //   );

    //   final result = await _repository.doAcceptanceSignIn(event.request);

    //   if (result.isSuccess) {
    //     emit(const AcceptanceSignedIn());
    //     Logger.info(
    //       'Acceptance sign-in processed successfully',
    //       tag: 'AcceptanceBloc',
    //     );
    //   } else {
    //     // 验收入库失败后，需要恢复之前的详情页状态态，不是简单的error状态
    //     final currentState = state;
    //     if (currentState is AcceptanceDetailLoaded) {
    //       emit(currentState);
    //       emit(AcceptanceError(message: result.msg ?? '验收入库失败'));
    //     } else {
    //       emit(AcceptanceError(message: result.msg ?? '验收入库失败'));
    //     }
    //     Logger.error(
    //       'Failed to process acceptance sign-in: ${result.msg}',
    //       tag: 'AcceptanceBloc',
    //     );
    //   }
    // } catch (e) {
    //   emit(AcceptanceError(message: '验收入库失败，请重试'));
    //   Logger.error(
    //     'Error processing acceptance sign-in: $e',
    //     tag: 'AcceptanceBloc',
    //   );
    // }
  }

  Future<void> _onLoadAcceptanceList(
    LoadAcceptanceList event,
    Emitter<AcceptanceState> emit,
  ) async {
    try {
      emit(const AcceptanceLoading());
      Logger.info(
        'Loading acceptance list - page: ${event.pageNum}',
        tag: 'AcceptanceBloc',
      );

      final result = await _repository.getAcceptanceList(
        projectId: event.projectId,
        userId: event.userId,
        pageNum: event.pageNum,
        pageSize: event.pageSize,
      );

      if (result.isSuccess && result.data != null) {
        emit(AcceptanceListLoaded(recordList: result.data!));
        Logger.info(
          'Acceptance list loaded successfully',
          tag: 'AcceptanceBloc',
        );
      } else {
        emit(AcceptanceError(message: result.msg ?? '获取验收列表失败'));
        Logger.error(
          'Failed to load acceptance list: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
      }
    } catch (e) {
      emit(AcceptanceError(message: '获取验收列表失败，请重试'));
      Logger.error('Error loading acceptance list: $e', tag: 'AcceptanceBloc');
    }
  }

  Future<void> _onRefreshAcceptanceDetail(
    RefreshAcceptanceDetail event,
    Emitter<AcceptanceState> emit,
  ) async {
    add(LoadAcceptanceDetail(acceptanceId: event.acceptanceId));
  }

  Future<void> _onClearAcceptanceCache(
    ClearAcceptanceCache event,
    Emitter<AcceptanceState> emit,
  ) async {
    Logger.info('Acceptance cache cleared', tag: 'AcceptanceBloc');
  }

  Future<void> _onLoadAcceptanceUsers(
    LoadAcceptanceUsers event,
    Emitter<AcceptanceState> emit,
  ) async {
    try {
      emit(const AcceptanceUsersLoading());
      Logger.info(
        'Loading acceptance users for project: ${event.projectId}, role: ${event.roleType}',
        tag: 'AcceptanceBloc',
      );

      final result = await _repository.getAcceptanceUsers(
        projectId: event.projectId,
      );

      if (result.isSuccess && result.data != null) {
        emit(AcceptanceUsersLoaded(acceptUserInfo: result.data!));
        Logger.info(
          'Acceptance users loaded successfully',
          tag: 'AcceptanceBloc',
        );
      } else {
        emit(AcceptanceError(message: result.msg ?? '获取验收用户失败'));
        Logger.error(
          'Failed to load acceptance users: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
      }
    } catch (e) {
      emit(AcceptanceError(message: '获取验收用户失败，请重试'));
      Logger.error('Error loading acceptance users: $e', tag: 'AcceptanceBloc');
    }
  }

  Future<void> _onLoadWarehouseUsers(
    LoadWarehouseUsers event,
    Emitter<AcceptanceState> emit,
  ) async {
    try {
      emit(const WarehouseUsersLoading());
      Logger.info(
        'Loading warehouse users for warehouse: ${event.warehouseId}',
        tag: 'AcceptanceBloc',
      );

      final result = await _repository.getWarehouseUsers(
        warehouseId: event.warehouseId,
      );

      if (result.isSuccess && result.data != null) {
        emit(WarehouseUsersLoaded(warehouseUserInfo: result.data!));
        Logger.info(
          'Warehouse users loaded successfully',
          tag: 'AcceptanceBloc',
        );
      } else {
        emit(AcceptanceError(message: result.msg ?? '获取仓库用户失败'));
        Logger.error(
          'Failed to load warehouse users: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
      }
    } catch (e) {
      emit(AcceptanceError(message: '获取仓库用户失败，请重试'));
      Logger.error('Error loading warehouse users: $e', tag: 'AcceptanceBloc');
    }
  }

  Future<void> _onLoadWarehouseList(
    LoadWarehouseList event,
    Emitter<AcceptanceState> emit,
  ) async {
    try {
      emit(const WarehouseListLoading());
      Logger.info('Loading warehouse list', tag: 'AcceptanceBloc');

      final result = await _repository.getWarehouseList();

      if (result.isSuccess && result.data != null) {
        emit(WarehouseListLoaded(warehouseList: result.data!));
        Logger.info(
          'Warehouse list loaded successfully',
          tag: 'AcceptanceBloc',
        );
      } else {
        emit(AcceptanceError(message: result.msg ?? '获取仓库列表失败'));
        Logger.error(
          'Failed to load warehouse list: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
      }
    } catch (e) {
      emit(AcceptanceError(message: '获取仓库列表失败，请重试'));
      Logger.error('Error loading warehouse list: $e', tag: 'AcceptanceBloc');
    }
  }

  void _onMatchScannedMaterial(
    MatchScannedMaterial event,
    Emitter<AcceptanceState> emit,
  ) {
    // 确保当前状态是AcceptanceDetailLoaded
    final currentState = state;
    if (currentState is AcceptanceDetailLoaded) {
      try {
        // 在当前验收单的无聊列表中查找匹配项
        final matchingMaterial = currentState.acceptanceInfo.materialList
            .firstWhere(
              (m) =>
                  m.materialId.toString() ==
                  event.scannedMaterial.normals.first.materialId.toString(),
            );

        // 如果找到匹配项，检查是否已经匹配过
        final isAlreadyMatched = currentState.matchedMaterials.any(
          (m) => m.materialId == matchingMaterial.materialId,
        );

        // 检查是否已经匹配
        if (isAlreadyMatched) {
          // 如果需要，可以发出一个特定的状态或事件来通知UI“重复扫描”
          // 为了简化，暂不处理，UI可通过比对前后状态的set长度判断
          // 或者，我们可以专门添加一个state
          // emit(
          //   AcceptanceError(message: "物料${matchingMaterial.materialName}已扫描"),
          // );
          emit(
            currentState.copyWith(
              matchMessage: '物料${matchingMaterial.materialName} 已被扫描，请勿重复扫码',
            ),
          );
        } else {
          // 使用copywith创建一个新的状态实例，只更新matchedMaterials
          final newMatchedMaterials = Set<MaterialVO>.from(
            currentState.matchedMaterials,
          )..add(matchingMaterial);
          emit(
            currentState.copyWith(
              matchedMaterials: newMatchedMaterials,
              matchMessage: '物料${matchingMaterial.materialName} 匹配成功',
            ),
          );
        }
      } catch (e) {
        // 如果在列表中找不到匹配项，（firstwhere抛出异常）
        emit(
          currentState.copyWith(
            matchMessage: '物料${event.scannedMaterial.normals.first.prodNm}不存在',
          ),
        );
      }
    } else {
      // 如果当前状态不是AcceptanceDetailLoaded，发出错误状态
      emit(AcceptanceError(message: "无法匹配材料，当前状态不正确"));
    }
  }
}
