import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/acceptance/acceptance_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/do_accept_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/do_accept_sign_in_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/accept_user_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/warehouse_user_info_vo.dart';
import 'package:pipe_code_flutter/models/records/record_list_response.dart';
import 'package:pipe_code_flutter/services/api/interfaces/acceptance_api_service.dart';
import 'base_api_service.dart';

class AcceptanceApiServiceImpl extends BaseApiService
    implements AcceptanceApiService {
  AcceptanceApiServiceImpl(super.dio);

  @override
  Future<Result<void>> submitAcceptance(DoAcceptVO request) async {
    try {
      final response = await dio.post('/accept/do', data: request.toJson());

      if (response.statusCode == 200) {
        final result = Result.fromJson(response.data, (json) => json);
        if (result.success == true) {
          return Result(code: 0, msg: 'success', data: null);
        } else {
          return Result(code: -1, msg: result.msg ?? '提交失败', data: null);
        }
      } else {
        return Result(code: -1, msg: '提交失败，请重试', data: null);
      }
    } on DioException catch (e) {
      return Result(
        code: -1,
        msg: handleErrorForEndpoint(e, '/accept/do'),
        data: null,
      );
    } catch (e) {
      return Result(code: -1, msg: '提交失败，请检查网络连接', data: null);
    }
  }

  @override
  Future<Result<void>> auditAcceptance(CommonDoBusinessAuditVO request) async {
    try {
      final response = await dio.post(
        '/accept/do/audit',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final result = Result.fromJson(response.data, (json) => json);
        if (result.isSuccess) {
          return Result(code: 0, msg: 'success', data: null);
        } else {
          return Result(code: -1, msg: result.msg ?? '审核失败', data: null);
        }
      } else {
        return Result(code: -1, msg: '审核失败，请重试', data: null);
      }
    } on DioException catch (e) {
      return Result(
        code: -1,
        msg: handleErrorForEndpoint(e, '/accept/do/audit'),
        data: null,
      );
    } catch (e) {
      return Result(code: -1, msg: '审核失败，请检查网络连接', data: null);
    }
  }

  @override
  Future<Result<AcceptanceInfoVO>> getAcceptanceDetail(int id) async {
    try {
      final response = await dio.get(
        '/accept/detail',
        queryParameters: {'id': id},
      );

      if (response.statusCode == 200) {
        final result = Result.fromJson(response.data, (json) => json);
        if (result.isSuccess && result.data != null) {
          final acceptanceInfo = AcceptanceInfoVO.fromJson(
            result.data as Map<String, dynamic>,
          );
          return Result(code: 0, msg: 'success', data: acceptanceInfo);
        } else {
          return Result(code: -1, msg: result.msg ?? '获取详情失败', data: null);
        }
      } else {
        return Result(code: -1, msg: '获取详情失败，请重试', data: null);
      }
    } on DioException catch (e) {
      return Result(
        code: -1,
        msg: handleErrorForEndpoint(e, '/accept/detail'),
        data: null,
      );
    } catch (e) {
      return Result(code: -1, msg: '获取详情失败，请检查网络连接', data: null);
    }
  }

  @override
  Future<Result<RecordListResponse>> getAcceptanceList({
    int? projectId,
    int? userId,
    int? pageNum,
    int? pageSize,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (projectId != null) queryParameters['projectId'] = projectId;
      if (userId != null) queryParameters['userId'] = userId;
      if (pageNum != null) queryParameters['pageNum'] = pageNum;
      if (pageSize != null) queryParameters['pageSize'] = pageSize;

      final response = await dio.get(
        '/accept/list',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final result = Result.fromJson(response.data, (json) => json);
        if (result.isSuccess && result.data != null) {
          final recordList = RecordListResponse.fromJson(
            result.data as Map<String, dynamic>,
          );
          return Result(code: 0, msg: 'success', data: recordList);
        } else {
          return Result(code: -1, msg: result.msg ?? '获取列表失败', data: null);
        }
      } else {
        return Result(code: -1, msg: '获取列表失败，请重试', data: null);
      }
    } on DioException catch (e) {
      return Result(
        code: -1,
        msg: handleErrorForEndpoint(e, '/accept/list'),
        data: null,
      );
    } catch (e) {
      return Result(code: -1, msg: '获取列表失败，请检查网络连接', data: null);
    }
  }

  @override
  Future<Result<void>> doAcceptanceSignIn(DoAcceptSignInVO request) async {
    try {
      final response = await dio.post(
        '/accept/after/accept/do',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final result = Result.fromJson(response.data, (json) => json);
        if (result.isSuccess) {
          return Result(code: 0, msg: 'success', data: null);
        } else {
          return Result(code: -1, msg: result.msg ?? '入库失败', data: null);
        }
      } else {
        return Result(code: -1, msg: '入库失败，请重试', data: null);
      }
    } on DioException catch (e) {
      return Result(
        code: -1,
        msg: handleErrorForEndpoint(e, '/accept/after/accept/do'),
        data: null,
      );
    } catch (e) {
      return Result(code: -1, msg: '入库失败，请检查网络连接', data: null);
    }
  }

  @override
  Future<Result<AcceptUserInfoVO>> getAcceptanceUsers({
    required int projectId,
    required int roleType,
  }) async {
    try {
      final response = await dio.get(
        '/accept/accept/users',
        queryParameters: {
          'projectId': projectId,
          'roleType': roleType,
        },
      );

      if (response.statusCode == 200) {
        final result = Result.fromJson(response.data, (json) => json);
        if (result.isSuccess && result.data != null) {
          final acceptUserInfo = AcceptUserInfoVO.fromJson(
            result.data as Map<String, dynamic>,
          );
          return Result(code: 0, msg: 'success', data: acceptUserInfo);
        } else {
          return Result(code: -1, msg: result.msg ?? '获取验收用户失败', data: null);
        }
      } else {
        return Result(code: -1, msg: '获取验收用户失败，请重试', data: null);
      }
    } on DioException catch (e) {
      return Result(
        code: -1,
        msg: handleErrorForEndpoint(e, '/accept/accept/users'),
        data: null,
      );
    } catch (e) {
      return Result(code: -1, msg: '获取验收用户失败，请检查网络连接', data: null);
    }
  }

  @override
  Future<Result<WarehouseUserInfoVO>> getWarehouseUsers({
    required int warehouseId,
  }) async {
    try {
      final response = await dio.get(
        '/accept/warehouse/users',
        queryParameters: {
          'warehouseId': warehouseId,
        },
      );

      if (response.statusCode == 200) {
        final result = Result.fromJson(response.data, (json) => json);
        if (result.isSuccess && result.data != null) {
          final warehouseUserInfo = WarehouseUserInfoVO.fromJson(
            result.data as Map<String, dynamic>,
          );
          return Result(code: 0, msg: 'success', data: warehouseUserInfo);
        } else {
          return Result(code: -1, msg: result.msg ?? '获取仓库用户失败', data: null);
        }
      } else {
        return Result(code: -1, msg: '获取仓库用户失败，请重试', data: null);
      }
    } on DioException catch (e) {
      return Result(
        code: -1,
        msg: handleErrorForEndpoint(e, '/accept/warehouse/users'),
        data: null,
      );
    } catch (e) {
      return Result(code: -1, msg: '获取仓库用户失败，请检查网络连接', data: null);
    }
  }
}
