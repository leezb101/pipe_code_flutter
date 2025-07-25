/*
 * @Author: LeeZB
 * @Date: 2025-07-22 08:53:08
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-24 19:44:10
 * @copyright: Copyright © 2025 高新供水.
 */
import '../models/acceptance/acceptance_info_vo.dart';
import '../models/acceptance/do_accept_vo.dart';
import '../models/acceptance/do_accept_sign_in_vo.dart';
import '../models/acceptance/common_do_business_audit_vo.dart';
import '../models/common/accept_user_info_vo.dart';
import '../models/common/warehouse_user_info_vo.dart';
import '../models/records/record_list_response.dart';
import '../models/common/result.dart';
import '../models/common/warehouse_vo.dart';
import '../services/api/interfaces/acceptance_api_service.dart';
import '../services/api/interfaces/common_query_api_service.dart';
import '../utils/logger.dart';

class AcceptanceRepository {
  final AcceptanceApiService _apiService;
  final CommonQueryApiService _commonQueryApiService;

  AcceptanceRepository(this._apiService, this._commonQueryApiService);

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
  Future<Result<AcceptanceInfoVO>> getAcceptanceDetail(int id) async {
    try {
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

  /// 获取验收用户
  Future<Result<AcceptUserInfoVO>> getAcceptanceUsers({
    required int projectId,
  }) async {
    try {
      Logger.info(
        'Fetching acceptance users for project: $projectId',
        tag: 'AcceptanceRepository',
      );
      final result = await _commonQueryApiService.getAcceptUsers(projectId);

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
      final result = await _commonQueryApiService.getWarehouseUsers(
        warehouseId,
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

  /// 获取仓库列表
  Future<Result<List<WarehouseVO>>> getWarehouseList() async {
    try {
      Logger.info('Fetching warehouse list', tag: 'AcceptanceRepository');
      final result = await _commonQueryApiService.getWarehouseList();

      if (result.isSuccess) {
        Logger.info(
          'Warehouse list fetched successfully',
          tag: 'AcceptanceRepository',
        );
      } else {
        Logger.error(
          'Failed to fetch warehouse list: ${result.msg}',
          tag: 'AcceptanceRepository',
        );
      }

      return result;
    } catch (e) {
      Logger.error(
        'Error fetching warehouse list: $e',
        tag: 'AcceptanceRepository',
      );
      return Result(code: -1, msg: '获取仓库列表失败，请重试', data: null);
    }
  }
}
