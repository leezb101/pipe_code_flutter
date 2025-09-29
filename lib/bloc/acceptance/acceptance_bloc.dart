/*
 * @Author: LeeZB
 * @Date: 2025-07-23 17:28:27
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-31 17:19:40
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/user/current_user_on_project_role_info.dart';
import '../../repositories/interfaces/acceptance_repository.dart';
import '../../repositories/interfaces/material_handle_repository.dart';
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
    on<DoAcceptanceSignIn>(_onDoAcceptanceSignIn);
    on<LoadAcceptanceList>(_onLoadAcceptanceList);
    on<RefreshAcceptanceDetail>(_onRefreshAcceptanceDetail);
    on<ClearAcceptanceCache>(_onClearAcceptanceCache);
    on<LoadAcceptanceUsers>(_onLoadAcceptanceUsers);
    on<LoadWarehouseUsers>(_onLoadWarehouseUsers);
    on<LoadWarehouseList>(_onLoadWarehouseList);
    // on<ScanMaterialForSignin>(_onScanMaterialForSignin);
    on<MatchScannedMaterial>(_onMatchScannedMaterial);
    on<UnmatchScannedMaterial>(_onUnmatchScannedMaterial);
    on<BulkUnmatchMaterials>(_onBulkUnmatchMaterials);
    on<InitializeMaterialsFromCodes>(_onInitializeMaterialsFromCodes);
    on<AppendMaterialsByCodes>(_onAppendMaterialsByCodes);
    on<RemoveMaterialsByCodes>(_onRemoveMaterialsByCodes);
    // AcceptancePage centralized editing flow
    on<InitializeEditingMaterials>(_onInitializeEditingMaterials);
    on<AppendEditingMaterialsByCodes>(_onAppendEditingMaterialsByCodes);
    on<RemoveEditingMaterialsByCodes>(_onRemoveEditingMaterialsByCodes);
    on<ClearEditingMessage>(_onClearEditingMessage);
    on<ConfirmPurchaserValidationWarning>(_onConfirmPurchaserValidationWarning);
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
        emit(AcceptanceError(message: result.msg));
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
    final currentState = state;
    try {
      emit(const AcceptanceSubmitting());
      Logger.info('Submitting acceptance', tag: 'AcceptanceBloc');

      final result = await _repository.submitAcceptance(event.request);

      if (result.isSuccess) {
        emit(const AcceptanceSubmitted());
        Logger.info('Acceptance submitted successfully', tag: 'AcceptanceBloc');
      } else {
        emit(AcceptanceError(message: result.msg));
        Logger.error(
          'Failed to submit acceptance: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
        // 恢复提交前的状态，保留materialList等信息
        if (currentState is AcceptanceDetailLoaded) {
          emit(currentState);
        } else if (currentState is AcceptanceEditingState) {
          emit(currentState);
        }
      }
    } catch (e) {
      emit(AcceptanceError(message: '提交验收失败，请重试'));
      Logger.error('Error submitting acceptance: $e', tag: 'AcceptanceBloc');
      // 恢复提交前的状态，保留materialList等信息
      if (currentState is AcceptanceDetailLoaded) {
        emit(currentState);
      } else if (currentState is AcceptanceEditingState) {
        emit(currentState);
      }
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
      emit(AcceptanceError(message: result.msg));
    }
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
        emit(AcceptanceError(message: result.msg));
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
    // Preserve primary AcceptancePage state (editing or initialized materials)
    final AcceptanceState? resumePrimary = state is AcceptanceEditingState
        ? state as AcceptanceEditingState
        : state is AcceptanceMaterialsResolved
        ? state as AcceptanceMaterialsResolved
        : null;
    try {
      if (resumePrimary == null) {
        emit(const AcceptanceUsersLoading());
      }
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
        emit(AcceptanceError(message: result.msg));
        Logger.error(
          'Failed to load acceptance users: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
      }
      // After delivering side-effect state to listeners, restore primary view state if needed
      if (resumePrimary != null) {
        if (resumePrimary is AcceptanceEditingState) {
          emit(resumePrimary.copyWith());
        } else if (resumePrimary is AcceptanceMaterialsResolved) {
          // Re-emit to restore initialized materials on AcceptancePage
          emit(
            AcceptanceMaterialsResolved(
              materials: resumePrimary.materials,
              message: resumePrimary.message,
            ),
          );
        }
      }
    } catch (e) {
      emit(AcceptanceError(message: '获取验收用户失败，请重试'));
      Logger.error('Error loading acceptance users: $e', tag: 'AcceptanceBloc');
      // Restore primary view state even on error
      if (resumePrimary != null) {
        if (resumePrimary is AcceptanceEditingState) {
          emit(resumePrimary.copyWith());
        } else if (resumePrimary is AcceptanceMaterialsResolved) {
          emit(
            AcceptanceMaterialsResolved(
              materials: resumePrimary.materials,
              message: resumePrimary.message,
            ),
          );
        }
      }
    }
  }

  Future<void> _onLoadWarehouseUsers(
    LoadWarehouseUsers event,
    Emitter<AcceptanceState> emit,
  ) async {
    // Preserve primary AcceptancePage state (editing or initialized materials)
    final AcceptanceState? resumePrimary = state is AcceptanceEditingState
        ? state as AcceptanceEditingState
        : state is AcceptanceMaterialsResolved
        ? state as AcceptanceMaterialsResolved
        : null;
    try {
      if (resumePrimary == null) {
        emit(const WarehouseUsersLoading());
      }
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
        emit(AcceptanceError(message: result.msg));
        Logger.error(
          'Failed to load warehouse users: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
      }
      // After delivering side-effect state to listeners, restore primary view state if needed
      if (resumePrimary != null) {
        if (resumePrimary is AcceptanceEditingState) {
          emit(resumePrimary.copyWith());
        } else if (resumePrimary is AcceptanceMaterialsResolved) {
          emit(
            AcceptanceMaterialsResolved(
              materials: resumePrimary.materials,
              message: resumePrimary.message,
            ),
          );
        }
      }
    } catch (e) {
      emit(AcceptanceError(message: '获取仓库用户失败，请重试'));
      Logger.error('Error loading warehouse users: $e', tag: 'AcceptanceBloc');
      // Restore primary view state even on error
      if (resumePrimary != null) {
        if (resumePrimary is AcceptanceEditingState) {
          emit(resumePrimary.copyWith());
        } else if (resumePrimary is AcceptanceMaterialsResolved) {
          emit(
            AcceptanceMaterialsResolved(
              materials: resumePrimary.materials,
              message: resumePrimary.message,
            ),
          );
        }
      }
    }
  }

  Future<void> _onLoadWarehouseList(
    LoadWarehouseList event,
    Emitter<AcceptanceState> emit,
  ) async {
    // Preserve primary AcceptancePage state (editing or initialized materials)
    final AcceptanceState? resumePrimary = state is AcceptanceEditingState
        ? state as AcceptanceEditingState
        : state is AcceptanceMaterialsResolved
        ? state as AcceptanceMaterialsResolved
        : null;
    try {
      if (resumePrimary == null) {
        emit(const WarehouseListLoading());
      }
      Logger.info('Loading warehouse list', tag: 'AcceptanceBloc');

      final result = await _repository.getWarehouseList();

      if (result.isSuccess && result.data != null) {
        emit(WarehouseListLoaded(warehouseList: result.data!));
        Logger.info(
          'Warehouse list loaded successfully',
          tag: 'AcceptanceBloc',
        );
      } else {
        emit(AcceptanceError(message: result.msg));
        Logger.error(
          'Failed to load warehouse list: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
      }
      // After delivering side-effect state to listeners, restore primary view state if needed
      if (resumePrimary != null) {
        if (resumePrimary is AcceptanceEditingState) {
          emit(resumePrimary.copyWith());
        } else if (resumePrimary is AcceptanceMaterialsResolved) {
          emit(
            AcceptanceMaterialsResolved(
              materials: resumePrimary.materials,
              message: resumePrimary.message,
            ),
          );
        }
      }
    } catch (e) {
      emit(AcceptanceError(message: '获取仓库列表失败，请重试'));
      Logger.error('Error loading warehouse list: $e', tag: 'AcceptanceBloc');
      // Restore primary view state even on error
      if (resumePrimary != null) {
        if (resumePrimary is AcceptanceEditingState) {
          emit(resumePrimary.copyWith());
        } else if (resumePrimary is AcceptanceMaterialsResolved) {
          emit(
            AcceptanceMaterialsResolved(
              materials: resumePrimary.materials,
              message: resumePrimary.message,
            ),
          );
        }
      }
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
                  event.scannedMaterial.normals.first.baseInfo.materialId
                      .toString(),
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
            matchMessage:
                '物料${event.scannedMaterial.normals.first.baseInfo.prodNm}不存在',
          ),
        );
      }
    } else {
      // 如果当前状态不是AcceptanceDetailLoaded，发出错误状态
      emit(AcceptanceError(message: "无法匹配材料，当前状态不正确"));
    }
  }

  void _onUnmatchScannedMaterial(
    UnmatchScannedMaterial event,
    Emitter<AcceptanceState> emit,
  ) {
    final currentState = state;
    if (currentState is AcceptanceDetailLoaded) {
      try {
        final scannedId =
            event.scannedMaterial.normals.first.baseInfo.materialId;
        final existing = currentState.acceptanceInfo.materialList.firstWhere(
          (m) => m.materialId.toString() == scannedId.toString(),
        );
        final isMatched = currentState.matchedMaterials.any(
          (m) => m.materialId == existing.materialId,
        );
        if (!isMatched) {
          emit(
            currentState.copyWith(
              matchMessage: '物料${existing.materialName} 未在已扫描列表中',
            ),
          );
          return;
        }
        final newSet = Set<MaterialVO>.from(currentState.matchedMaterials)
          ..removeWhere((m) => m.materialId == existing.materialId);
        emit(
          currentState.copyWith(
            matchedMaterials: newSet,
            matchMessage: '已移除物料${existing.materialName}',
          ),
        );
      } catch (e) {
        emit(currentState.copyWith(matchMessage: '当前验收单不包含扫描到的物料'));
      }
    }
  }

  void _onBulkUnmatchMaterials(
    BulkUnmatchMaterials event,
    Emitter<AcceptanceState> emit,
  ) {
    final currentState = state;
    if (currentState is AcceptanceDetailLoaded) {
      final newSet = currentState.matchedMaterials
          .where((m) => !event.materialIds.contains(m.materialId))
          .toSet();
      emit(
        currentState.copyWith(
          matchedMaterials: newSet,
          matchMessage: '已剔除 ${event.materialIds.length} 个',
        ),
      );
    }
  }

  // ========== QR Scan integration ==========
  Future<void> _onInitializeMaterialsFromCodes(
    InitializeMaterialsFromCodes event,
    Emitter<AcceptanceState> emit,
  ) async {
    // Resolve codes and initialize current materials list for AcceptancePage
    try {
      if (event.codes.isEmpty) return;

      // 发出加载状态
      emit(const AcceptanceMaterialsLoading());

      final rsp = event.isBatch
          ? await _materialHandleRepository.scanBatchToQueryAll(event.codes)
          : await _materialHandleRepository.scanSingleToQueryAll(
              event.codes.first,
            );
      if (rsp.isSuccess && rsp.data != null) {
        final MaterialInfoForBusiness bundle = rsp.data!;

        // 检查采购方不匹配的材料
        final mismatchMaterials = _checkPurchaserMismatch(
          bundle.normals,
          event.projectPurNm,
          event.supplyType,
        );

        Logger.debug('扫码进入并完成获取信息，即将发出结果', tag: 'AcceptanceBloc');
        emit(
          AcceptanceMaterialsResolved(
            materials: bundle.normals,
            // unique token to ensure state changes are observed even with same materials
            message: 'init@${DateTime.now().microsecondsSinceEpoch}',
          ),
        );
        Logger.debug('扫码进入并完成获取信息，【完成】发出结果', tag: 'AcceptanceBloc');

        // 如果有采购方不匹配的材料，需要在材料初始化后触发警告状态
        if (mismatchMaterials.isNotEmpty) {
          Logger.warning(
            'Found ${mismatchMaterials.length} materials with purchaser mismatch in acceptance',
            tag: 'AcceptanceBloc',
          );

          // 注意：这里需要在后续的 InitializeEditingMaterials 处理中设置警告状态
        }
      } else {
        emit(AcceptanceError(message: rsp.msg));
      }
    } catch (e) {
      Logger.error(
        'Initialize materials from codes failed: $e',
        tag: 'AcceptanceBloc',
      );
      emit(const AcceptanceError(message: '解析扫码列表失败'));
    }
  }

  Future<void> _onAppendMaterialsByCodes(
    AppendMaterialsByCodes event,
    Emitter<AcceptanceState> emit,
  ) async {
    try {
      if (event.codes.isEmpty) return;
      final rsp = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );
      if (rsp.isSuccess && rsp.data != null) {
        final currentState = state;
        if (currentState is AcceptanceDetailLoaded) {
          // AcceptanceAfterSigninPage: 高亮匹配
          final scannedIds = rsp.data!.normals
              .map((m) => m.baseInfo.materialId)
              .toSet();
          final toAdd = currentState.acceptanceInfo.materialList
              .where((m) => scannedIds.contains(m.materialId))
              .toSet();

          final before = currentState.matchedMaterials.length;
          final newSet = {...currentState.matchedMaterials, ...toAdd};
          final added = newSet.length - before;
          final msg = added > 0 ? '新增匹配 $added 个物料' : '未匹配到新的物料';
          emit(
            currentState.copyWith(matchedMaterials: newSet, matchMessage: msg),
          );
          Logger.debug(
            'AppendMaterialsByCodes - matched $added new materials',
            tag: 'AcceptanceBloc',
          );
        } else {
          // AcceptancePage: 将解析结果抛给页面自行处理
          emit(
            AcceptanceMaterialsResolved(
              materials: rsp.data!.normals,
              message: 'append@${DateTime.now().microsecondsSinceEpoch}',
            ),
          );
          Logger.debug(
            'AppendMaterialsByCodes - emitted append event with ${rsp.data!.normals.length} materials',
            tag: 'AcceptanceBloc',
          );
        }
      } else {
        emit(const AcceptanceError(message: '新增码未查到物料信息'));
      }
    } catch (e) {
      Logger.error('Append by codes failed: $e', tag: 'AcceptanceBloc');
      emit(const AcceptanceError(message: '获取物料信息失败'));
    }
  }

  Future<void> _onRemoveMaterialsByCodes(
    RemoveMaterialsByCodes event,
    Emitter<AcceptanceState> emit,
  ) async {
    try {
      if (event.codes.isEmpty) return;
      final rsp = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );
      if (rsp.isSuccess && rsp.data != null) {
        final currentState = state;
        if (currentState is AcceptanceDetailLoaded) {
          // AcceptanceAfterSigninPage: 取消高亮
          final scannedIds = rsp.data!.normals
              .map((m) => m.baseInfo.materialId)
              .toSet();
          final before = currentState.matchedMaterials.length;
          final newSet = currentState.matchedMaterials
              .where((m) => !scannedIds.contains(m.materialId))
              .toSet();
          final removed = before - newSet.length;
          final msg = removed > 0 ? '已剔除 $removed 个物料' : '未找到可剔除的物料';
          emit(
            currentState.copyWith(matchedMaterials: newSet, matchMessage: msg),
          );
        } else {
          // AcceptancePage: 将解析结果抛给页面自行处理
          emit(
            AcceptanceMaterialsResolved(
              materials: rsp.data!.normals,
              message: 'remove@${DateTime.now().microsecondsSinceEpoch}',
            ),
          );
          Logger.debug(
            'RemoveMaterialsByCodes - emitted remove event with ${rsp.data!.normals.length} materials',
            tag: 'AcceptanceBloc',
          );
        }
      } else {
        emit(const AcceptanceError(message: '未匹配到可剔除的码'));
      }
    } catch (e) {
      Logger.error('Remove by codes failed: $e', tag: 'AcceptanceBloc');
      emit(const AcceptanceError(message: '剔除失败'));
    }
  }

  // ========= Centralized editing for AcceptancePage =========
  void _onInitializeEditingMaterials(
    InitializeEditingMaterials event,
    Emitter<AcceptanceState> emit,
  ) {
    final ids = event.initial.map((m) => m.baseInfo.materialId).toSet();

    // 检查采购方不匹配的材料
    final mismatchMaterials = _checkPurchaserMismatch(
      event.initial,
      event.projectPurNm,
      event.supplyType,
    );

    emit(
      AcceptanceEditingState(
        currentMaterials: List.of(event.initial),
        materialIds: ids,
        message: null,
        showPurchaserValidationWarning: mismatchMaterials.isNotEmpty,
        purchaserMismatchMaterials: mismatchMaterials,
      ),
    );

    Logger.debug(
      'Initialized editing materials with ${event.initial.length} items',
      tag: 'AcceptanceBloc',
    );

    if (mismatchMaterials.isNotEmpty) {
      Logger.warning(
        'Found ${mismatchMaterials.length} materials with purchaser mismatch in acceptance editing',
        tag: 'AcceptanceBloc',
      );
    }
  }

  Future<void> _onAppendEditingMaterialsByCodes(
    AppendEditingMaterialsByCodes event,
    Emitter<AcceptanceState> emit,
  ) async {
    try {
      if (event.codes.isEmpty) return;

      final currentState = state;
      // Ensure we have an editing state; if not, bootstrap empty
      final editing = currentState is AcceptanceEditingState
          ? currentState
          : const AcceptanceEditingState(
              currentMaterials: [],
              materialIds: {},
              isLoadingInitialMaterials: false,
              isLoadingAppendMaterials: false,
            );

      // 设置追加材料加载状态
      emit(editing.copyWith(isLoadingAppendMaterials: true));

      final rsp = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );
      if (!rsp.isSuccess || rsp.data == null) {
        emit(editing.copyWith(isLoadingAppendMaterials: false));
        emit(const AcceptanceError(message: '新增码未查到物料信息'));
        return;
      }

      final list = List.of(editing.currentMaterials);
      final ids = Set<int>.from(editing.materialIds);
      int added = 0;
      int dup = 0;
      for (final m in rsp.data!.normals) {
        final id = m.baseInfo.materialId;
        if (ids.contains(id)) {
          dup++;
          continue;
        }
        ids.add(id);
        list.add(m);
        added++;
      }

      // 检查新添加材料的采购方匹配情况
      final mismatchMaterials = _checkPurchaserMismatch(
        list,
        event.projectPurNm,
        event.supplyType,
      );

      emit(
        editing.copyWith(
          currentMaterials: list,
          materialIds: ids,
          message: added > 0
              ? '新增 $added 个${dup > 0 ? '，忽略重复 $dup 个' : ''}'
              : '暂无可新增物料',
          isLoadingAppendMaterials: false, // 清除加载状态
          showPurchaserValidationWarning: mismatchMaterials.isNotEmpty,
          purchaserMismatchMaterials: mismatchMaterials,
        ),
      );

      Logger.debug(
        'AppendEditingMaterialsByCodes - added $added new materials, ignored $dup duplicates',
        tag: 'AcceptanceBloc',
      );

      if (mismatchMaterials.isNotEmpty) {
        Logger.warning(
          'Found ${mismatchMaterials.length} materials with purchaser mismatch after append in acceptance',
          tag: 'AcceptanceBloc',
        );
      }
    } catch (e) {
      Logger.error(
        'Append editing materials failed: $e',
        tag: 'AcceptanceBloc',
      );

      // 在错误情况下也要清除加载状态
      final currentState = state;
      if (currentState is AcceptanceEditingState) {
        emit(currentState.copyWith(isLoadingAppendMaterials: false));
      }
      emit(const AcceptanceError(message: '获取物料信息失败'));
    }
  }

  Future<void> _onRemoveEditingMaterialsByCodes(
    RemoveEditingMaterialsByCodes event,
    Emitter<AcceptanceState> emit,
  ) async {
    try {
      if (event.codes.isEmpty) return;
      final rsp = await _materialHandleRepository.scanBatchToQueryAll(
        event.codes,
      );
      if (!rsp.isSuccess || rsp.data == null) {
        emit(const AcceptanceError(message: '未匹配到可剔除的码'));
        return;
      }
      final currentState = state;
      final editing = currentState is AcceptanceEditingState
          ? currentState
          : const AcceptanceEditingState(
              currentMaterials: [],
              materialIds: {},
              isLoadingInitialMaterials: false,
              isLoadingAppendMaterials: false,
            );
      final idsToRemove = rsp.data!.normals
          .map((m) => m.baseInfo.materialId)
          .toSet();
      final before = editing.currentMaterials.length;
      final newList = editing.currentMaterials
          .where((m) => !idsToRemove.contains(m.baseInfo.materialId))
          .toList();
      final removed = before - newList.length;
      final existingIds = editing.currentMaterials
          .map((m) => m.baseInfo.materialId)
          .toSet();
      final unmatched = idsToRemove.difference(existingIds).length;
      final newIds = Set<int>.from(editing.materialIds)..removeAll(idsToRemove);
      final msg = removed > 0
          ? '已剔除 $removed 个${unmatched > 0 ? '，忽略未在页面 $unmatched 个' : ''}'
          : '未找到可剔除的物料';
      emit(
        editing.copyWith(
          currentMaterials: newList,
          materialIds: newIds,
          message: msg,
        ),
      );
      Logger.debug(
        'RemoveEditingMaterialsByCodes - removed $removed materials, ignored $unmatched unmatched',
        tag: 'AcceptanceBloc',
      );
    } catch (e) {
      Logger.error(
        'Remove editing materials failed: $e',
        tag: 'AcceptanceBloc',
      );
      emit(const AcceptanceError(message: '剔除失败'));
    }
  }

  void _onClearEditingMessage(
    ClearEditingMessage event,
    Emitter<AcceptanceState> emit,
  ) {
    final currentState = state;
    if (currentState is AcceptanceEditingState) {
      emit(currentState.copyWith(clearMessage: true));
    }
  }

  void _onConfirmPurchaserValidationWarning(
    ConfirmPurchaserValidationWarning event,
    Emitter<AcceptanceState> emit,
  ) {
    final currentState = state;
    if (currentState is AcceptanceEditingState) {
      emit(
        currentState.copyWith(
          showPurchaserValidationWarning: false,
          purchaserMismatchMaterials: const [],
        ),
      );
      Logger.info(
        'User confirmed purchaser validation warning for acceptance',
        tag: 'AcceptanceBloc',
      );
    }
  }

  /// 检查材料采购方与项目采购方是否匹配（施工方验收逻辑）
  List<String> _checkPurchaserMismatch(
    List<MaterialInfo> materials,
    String? projectPurNm,
    ProjectSupplyType? supplyType,
  ) {
    // 前置判断：根据供材类型决定是否需要进行purNm检查
    if (supplyType == null) {
      return []; // 如果没有供材类型信息，跳过验证
    }

    // 如果是"乙供材"，则不需要进行purNm判断，直接返回空列表
    if (supplyType == ProjectSupplyType.yiGongCai) {
      return [];
    }

    // 如果是"甲供材"，菜单阶段应该已经拦截，但为安全起见也跳过purNm判断
    if (supplyType == ProjectSupplyType.jiaGongCai) {
      return [];
    }

    // 只有"甲乙混供"时，才需要进行purNm判断
    if (supplyType != ProjectSupplyType.jiaYiHunGong) {
      return [];
    }

    if (projectPurNm == null || projectPurNm.isEmpty) {
      return []; // 如果没有项目采购方信息，跳过验证
    }

    final mismatchMaterials = <String>[];
    for (final material in materials) {
      final materialPurNm = material.baseInfo.purNm;
      if (materialPurNm != null &&
          materialPurNm.isNotEmpty &&
          materialPurNm != projectPurNm) {
        final materialName = material.baseInfo.prodNm ?? '未知材料';
        mismatchMaterials.add('$materialName (采购方: $materialPurNm)');
      }
    }

    return mismatchMaterials;
  }
}
