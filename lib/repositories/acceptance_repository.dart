import '../models/acceptance/acceptance_info_vo.dart';
import '../models/acceptance/do_accept_vo.dart';
import '../models/acceptance/do_accept_sign_in_vo.dart';
import '../models/acceptance/common_do_business_audit_vo.dart';
import '../models/acceptance/accept_user_info_vo.dart';
import '../models/acceptance/warehouse_user_info_vo.dart';
import '../models/records/record_list_response.dart';
import '../models/common/result.dart';
import '../services/api/interfaces/acceptance_api_service.dart';
import '../utils/logger.dart';

class AcceptanceRepository {
  final AcceptanceApiService _apiService;
  final Map<int, AcceptanceInfoVO> _detailCache = {};
  final Map<int, DateTime> _detailCacheTimestamps = {};
  final Duration _cacheTimeout = const Duration(minutes: 5);

  AcceptanceRepository(this._apiService);

  /// 提交验收单
  Future<Result<void>> submitAcceptance(DoAcceptVO request) async {
    try {
      Logger.info('Submitting acceptance request', tag: 'AcceptanceRepository');
      final result = await _apiService.submitAcceptance(request);

      if (result.isSuccess) {
        Logger.info(
          'Acceptance submitted successfully',
          tag: 'AcceptanceRepository',
        );
        // Clear cache after successful submission
        _detailCache.clear();
        _detailCacheTimestamps.clear();
      } else {
        Logger.error(
          'Failed to submit acceptance: ${result.msg}',
          tag: 'AcceptanceRepository',
        );
      }

      return result;
    } catch (e) {
      Logger.error(
        'Error submitting acceptance: $e',
        tag: 'AcceptanceRepository',
      );
      return Result(code: -1, msg: '提交验收失败，请重试', data: null);
    }
  }

  /// 审核验收单
  Future<Result<void>> auditAcceptance(CommonDoBusinessAuditVO request) async {
    try {
      Logger.info(
        'Auditing acceptance with id: ${request.id}',
        tag: 'AcceptanceRepository',
      );
      final result = await _apiService.auditAcceptance(request);

      if (result.isSuccess) {
        Logger.info(
          'Acceptance audited successfully',
          tag: 'AcceptanceRepository',
        );
        // Clear cache after successful audit
        _clearDetailCache(request.id);
      } else {
        Logger.error(
          'Failed to audit acceptance: ${result.msg}',
          tag: 'AcceptanceRepository',
        );
      }

      return result;
    } catch (e) {
      Logger.error(
        'Error auditing acceptance: $e',
        tag: 'AcceptanceRepository',
      );
      return Result(code: -1, msg: '审核验收失败，请重试', data: null);
    }
  }

  /// 获取验收详情
  Future<Result<AcceptanceInfoVO>> getAcceptanceDetail(
    int id, {
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _isDetailCacheValid(id)) {
        Logger.info(
          'Returning cached acceptance detail for id: $id',
          tag: 'AcceptanceRepository',
        );
        return Result(code: 0, msg: 'success', data: _detailCache[id]!);
      }

      Logger.info(
        'Fetching acceptance detail for id: $id',
        tag: 'AcceptanceRepository',
      );
      final result = await _apiService.getAcceptanceDetail(id);

      if (result.isSuccess && result.data != null) {
        Logger.info(
          'Acceptance detail fetched successfully',
          tag: 'AcceptanceRepository',
        );
        _detailCache[id] = result.data!;
        _detailCacheTimestamps[id] = DateTime.now();
      } else {
        Logger.error(
          'Failed to fetch acceptance detail: ${result.msg}',
          tag: 'AcceptanceRepository',
        );
      }

      return result;
    } catch (e) {
      Logger.error(
        'Error fetching acceptance detail: $e',
        tag: 'AcceptanceRepository',
      );
      return Result(code: -1, msg: '获取验收详情失败，请重试', data: null);
    }
  }

  /// 获取验收列表
  Future<Result<RecordListResponse>> getAcceptanceList({
    int? projectId,
    int? userId,
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    try {
      Logger.info(
        'Fetching acceptance list - page: $pageNum, size: $pageSize',
        tag: 'AcceptanceRepository',
      );
      final result = await _apiService.getAcceptanceList(
        projectId: projectId,
        userId: userId,
        pageNum: pageNum,
        pageSize: pageSize,
      );

      if (result.isSuccess) {
        Logger.info(
          'Acceptance list fetched successfully',
          tag: 'AcceptanceRepository',
        );
      } else {
        Logger.error(
          'Failed to fetch acceptance list: ${result.msg}',
          tag: 'AcceptanceRepository',
        );
      }

      return result;
    } catch (e) {
      Logger.error(
        'Error fetching acceptance list: $e',
        tag: 'AcceptanceRepository',
      );
      return Result(code: -1, msg: '获取验收列表失败，请重试', data: null);
    }
  }

  /// 验收后入库
  Future<Result<void>> doAcceptanceSignIn(DoAcceptSignInVO request) async {
    try {
      Logger.info(
        'Processing acceptance sign-in for id: ${request.acceptId}',
        tag: 'AcceptanceRepository',
      );
      final result = await _apiService.doAcceptanceSignIn(request);

      if (result.isSuccess) {
        Logger.info(
          'Acceptance sign-in processed successfully',
          tag: 'AcceptanceRepository',
        );
        // Clear cache after successful sign-in
        _clearDetailCache(request.acceptId);
      } else {
        Logger.error(
          'Failed to process acceptance sign-in: ${result.msg}',
          tag: 'AcceptanceRepository',
        );
      }

      return result;
    } catch (e) {
      Logger.error(
        'Error processing acceptance sign-in: $e',
        tag: 'AcceptanceRepository',
      );
      return Result(code: -1, msg: '验收入库失败，请重试', data: null);
    }
  }

  /// 检查详情缓存是否有效
  bool _isDetailCacheValid(int id) {
    if (!_detailCache.containsKey(id) ||
        !_detailCacheTimestamps.containsKey(id)) {
      return false;
    }

    final cacheTime = _detailCacheTimestamps[id]!;
    final now = DateTime.now();
    return now.difference(cacheTime) < _cacheTimeout;
  }

  /// 清除特定ID的详情缓存
  void _clearDetailCache(int id) {
    _detailCache.remove(id);
    _detailCacheTimestamps.remove(id);
  }

  /// 获取验收用户
  Future<Result<AcceptUserInfoVO>> getAcceptanceUsers({
    required int projectId,
    required int roleType,
  }) async {
    try {
      Logger.info(
        'Fetching acceptance users for project: $projectId, role: $roleType',
        tag: 'AcceptanceRepository',
      );
      final result = await _apiService.getAcceptanceUsers(
        projectId: projectId,
        roleType: roleType,
      );

      if (result.isSuccess) {
        Logger.info(
          'Acceptance users fetched successfully',
          tag: 'AcceptanceRepository',
        );
      } else {
        Logger.error(
          'Failed to fetch acceptance users: ${result.msg}',
          tag: 'AcceptanceRepository',
        );
      }

      return result;
    } catch (e) {
      Logger.error(
        'Error fetching acceptance users: $e',
        tag: 'AcceptanceRepository',
      );
      return Result(code: -1, msg: '获取验收用户失败，请重试', data: null);
    }
  }

  /// 获取仓库用户
  Future<Result<WarehouseUserInfoVO>> getWarehouseUsers({
    required int warehouseId,
  }) async {
    try {
      Logger.info(
        'Fetching warehouse users for warehouse: $warehouseId',
        tag: 'AcceptanceRepository',
      );
      final result = await _apiService.getWarehouseUsers(
        warehouseId: warehouseId,
      );

      if (result.isSuccess) {
        Logger.info(
          'Warehouse users fetched successfully',
          tag: 'AcceptanceRepository',
        );
      } else {
        Logger.error(
          'Failed to fetch warehouse users: ${result.msg}',
          tag: 'AcceptanceRepository',
        );
      }

      return result;
    } catch (e) {
      Logger.error(
        'Error fetching warehouse users: $e',
        tag: 'AcceptanceRepository',
      );
      return Result(code: -1, msg: '获取仓库用户失败，请重试', data: null);
    }
  }

  /// 清除所有缓存
  void clearAllCache() {
    _detailCache.clear();
    _detailCacheTimestamps.clear();
    Logger.info('All acceptance cache cleared', tag: 'AcceptanceRepository');
  }
}
