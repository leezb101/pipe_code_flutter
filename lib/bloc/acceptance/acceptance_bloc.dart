import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/acceptance/acceptance_info_vo.dart';
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
    on<ScanMaterialForSignin>(_onScanMaterialForSignin);
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

      final result = await _repository.getAcceptanceDetail(
        event.acceptanceId,
        forceRefresh: event.forceRefresh,
      );

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
    try {
      emit(const AcceptanceSigningIn());
      Logger.info(
        'Processing acceptance sign-in for id: ${event.request.acceptId}',
        tag: 'AcceptanceBloc',
      );

      final result = await _repository.doAcceptanceSignIn(event.request);

      if (result.isSuccess) {
        emit(const AcceptanceSignedIn());
        Logger.info(
          'Acceptance sign-in processed successfully',
          tag: 'AcceptanceBloc',
        );
      } else {
        emit(AcceptanceError(message: result.msg ?? '验收入库失败'));
        Logger.error(
          'Failed to process acceptance sign-in: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
      }
    } catch (e) {
      emit(AcceptanceError(message: '验收入库失败，请重试'));
      Logger.error(
        'Error processing acceptance sign-in: $e',
        tag: 'AcceptanceBloc',
      );
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
    add(
      LoadAcceptanceDetail(
        acceptanceId: event.acceptanceId,
        forceRefresh: true,
      ),
    );
  }

  Future<void> _onClearAcceptanceCache(
    ClearAcceptanceCache event,
    Emitter<AcceptanceState> emit,
  ) async {
    _repository.clearAllCache();
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

  Future<void> _onScanMaterialForSignin(
    ScanMaterialForSignin event,
    Emitter<AcceptanceState> emit,
  ) async {
    // Get current acceptance info BEFORE emitting MaterialScanInProgress
    final currentState = state;
    AcceptanceInfoVO? acceptanceInfo;
    if (currentState is AcceptanceDetailLoaded) {
      acceptanceInfo = currentState.acceptanceInfo;
    }

    try {
      emit(const MaterialScanInProgress());
      Logger.info(
        'Scanning material for signin with code: ${event.scannedCode}',
        tag: 'AcceptanceBloc',
      );

      // Use scanBatchToQueryAll with single-element array as requested
      final result = await _materialHandleRepository.scanBatchToQueryAll([
        event.scannedCode,
      ]);

      if (result.isSuccess &&
          result.data != null &&
          result.data!.normals.isNotEmpty) {
        final scannedMaterial = result.data!.normals.first;
        Logger.info(
          'Material scanned successfully: ${scannedMaterial.materialCode}',
          tag: 'AcceptanceBloc',
        );

        // Check if this material exists in current acceptance detail
        if (acceptanceInfo != null) {
          try {
            final matchingMaterial = acceptanceInfo.materialList.firstWhere(
              (material) =>
                  material.materialId.toString() ==
                  scannedMaterial.materialCode,
            );

            emit(
              MaterialScanned(
                materialId: matchingMaterial.materialId,
                message: '物料匹配成功: ${matchingMaterial.materialName}',
                acceptanceInfo: acceptanceInfo,
              ),
            );
          } catch (e) {
            emit(
              MaterialScanError(
                message: '该物料不在当前验收清单中',
                acceptanceInfo: acceptanceInfo,
              ),
            );
          }
        } else {
          emit(const MaterialScanError(message: '请先加载验收详情'));
        }
      } else {
        emit(
          MaterialScanError(
            message: result.msg ?? '扫码查询失败，请重试',
            acceptanceInfo: acceptanceInfo,
          ),
        );
        Logger.error(
          'Failed to scan material: ${result.msg}',
          tag: 'AcceptanceBloc',
        );
      }
    } catch (e) {
      // Use the acceptanceInfo captured at the beginning
      emit(
        MaterialScanError(
          message: '扫码识别失败: $e',
          acceptanceInfo: acceptanceInfo,
        ),
      );
      Logger.error('Error scanning material: $e', tag: 'AcceptanceBloc');
    }
  }
}
