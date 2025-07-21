import 'package:dio/dio.dart';
import '../../../models/common/accept_user_info_vo.dart';
import '../../../models/common/warehouse_user_info_vo.dart';
import '../../../models/common/warehouse_vo.dart';
import '../../../models/common/result.dart';
import '../interfaces/common_query_api_service.dart';
import '../../../config/app_config.dart';

class CommonQueryApiServiceImpl implements ICommonQueryApiService {
  final Dio _dio;

  CommonQueryApiServiceImpl(this._dio);

  @override
  Future<Result<AcceptUserInfoVO>> getAcceptUsers(int projectId) async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/mobile/common/accept/users',
        queryParameters: {'projectId': projectId},
      );

      return Result.safeFromJson<AcceptUserInfoVO>(
        response.data,
        (data) => AcceptUserInfoVO.fromJson(data as Map<String, dynamic>),
        'AcceptUserInfoVO',
      );
    } on DioException catch (e) {
      throw Exception('获取验收用户失败: ${e.message}');
    } catch (e) {
      throw Exception('获取验收用户失败: $e');
    }
  }

  @override
  Future<Result<WarehouseUserInfoVO>> getWarehouseUsers(int warehouseId) async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/mobile/common/warehouse/users',
        queryParameters: {'warehouseId': warehouseId},
      );

      return Result.safeFromJson<WarehouseUserInfoVO>(
        response.data,
        (data) => WarehouseUserInfoVO.fromJson(data as Map<String, dynamic>),
        'WarehouseUserInfoVO',
      );
    } on DioException catch (e) {
      throw Exception('获取仓库用户失败: ${e.message}');
    } catch (e) {
      throw Exception('获取仓库用户失败: $e');
    }
  }

  @override
  Future<Result<WarehouseVO>> getWarehouseByMaterial(int materialId) async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/mobile/common/Warehouse/material',
        queryParameters: {'materialId': materialId},
      );

      return Result.safeFromJson<WarehouseVO>(
        response.data,
        (data) => WarehouseVO.fromJson(data as Map<String, dynamic>),
        'WarehouseVO',
      );
    } on DioException catch (e) {
      throw Exception('获取仓库信息失败: ${e.message}');
    } catch (e) {
      throw Exception('获取仓库信息失败: $e');
    }
  }
}