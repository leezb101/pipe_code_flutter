/*
 * @Author: LeeZB
 * @Date: 2025-07-21 14:54:15
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-21 15:39:45
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:dio/dio.dart';
import '../../../models/common/accept_user_info_vo.dart';
import '../../../models/common/warehouse_user_info_vo.dart';
import '../../../models/common/warehouse_vo.dart';
import '../../../models/common/result.dart';
import '../interfaces/common_query_api_service.dart';
import '../../../config/app_config.dart';

class CommonQueryApiServiceImpl implements CommonQueryApiService {
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

  @override
  Future<Result<List<WarehouseVO>>> getWarehouseList() async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/mobile/common/warehouse/list',
      );

      return Result.safeFromJson<List<WarehouseVO>>(
        response.data,
        (data) {
          if (data is List) {
            return data
                .map((item) => WarehouseVO.fromJson(item as Map<String, dynamic>))
                .toList();
          } else {
            throw FormatException('Expected List but got ${data.runtimeType}');
          }
        },
        'List<WarehouseVO>',
      );
    } catch (e) {
      throw Exception('获取仓库列表失败: $e');
    }
  }
}
