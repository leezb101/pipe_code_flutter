/*
 * @Author: LeeZB
 * @Date: 2025-08-01 17:17:14
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-01 17:22:22
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/inventory/inventory_models.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/inventory_api_service.dart';

class InventoryApiServiceImpl extends BaseApiService
    implements InventoryApiService {
  InventoryApiServiceImpl(super.dio);

  @override
  Future<Result<InventoryListResponse>> getInventoryList({
    required int pageNum,
    required int pageSize,
  }) async {
    final response = await dio.get(
      '/stocktaking/todo/list',
      queryParameters: {'pageNum': pageNum, 'pageSize': pageSize},
    );
    if (response.statusCode == 200) {
      final result = Result.safeFromJson(
        response.data,
        (json) => json,
        'InventoryListResponse',
      );

      if (result.isSuccess && result.data != null) {
        return Result(
          code: 0,
          msg: 'success',
          data: InventoryListResponse.fromJson(
            result.data as Map<String, dynamic>,
          ),
        );
      } else {
        return Result(code: result.code, msg: result.msg, data: null);
      }
    } else {
      return Result(code: -1, msg: '获取库存列表失败，请重试', data: null);
    }
  }

  @override
  Future<Result<InventoryDetailInfoVO>> getInventoryDetail(int id) async {
    final response = await dio.get('/inventory/detail/$id');
    if (response.statusCode == 200) {
      final result = Result.safeFromJson(
        response.data,
        (json) => json,
        'InventoryDetailInfoVO',
      );

      if (result.isSuccess && result.data != null) {
        return Result(
          code: 0,
          msg: 'success',
          data: InventoryDetailInfoVO.fromJson(
            result.data as Map<String, dynamic>,
          ),
        );
      } else {
        return Result(code: result.code, msg: result.msg, data: null);
      }
    } else {
      return Result(code: -1, msg: '获取库存详情失败，请重试', data: null);
    }
  }

  @override
  Future<Result<void>> submitInventory(DoInventoryRequestVO request) async {
    final response = await dio.post(
      '/inventory/submit',
      data: request.toJson(),
    );
    if (response.statusCode == 200) {
      final result = Result.safeFromJson(
        response.data,
        (json) => json,
        'DoInventoryRequestVO',
      );

      if (result.isSuccess) {
        return Result(code: 0, msg: 'success');
      } else {
        return Result(code: result.code, msg: result.msg);
      }
    } else {
      return Result(code: -1, msg: '提交库存失败，请重试', data: null);
    }
  }
}
