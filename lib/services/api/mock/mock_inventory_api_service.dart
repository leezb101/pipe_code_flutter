/*
 * @Author: LeeZB
 * @Date: 2025-08-01 17:23:36
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-01 17:25:30
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/inventory/inventory_models.dart';
import 'package:pipe_code_flutter/services/api/interfaces/inventory_api_service.dart';

class MockInventoryApiService implements InventoryApiService {
  @override
  Future<Result<InventoryListResponse>> getInventoryList({
    required int pageNum,
    required int pageSize,
  }) async {
    // Mock implementation for inventory list
    return Result(
      code: 0,
      msg: 'success',
      data: InventoryListResponse(
        total: 0,
        records: [],
        current: pageNum,
        size: pageSize,
      ),
    );
  }

  @override
  Future<Result<InventoryDetailInfoVO>> getInventoryDetail(int id) async {
    // Mock implementation for inventory detail
    return Result(
      code: 0,
      msg: 'success',
      data: InventoryDetailInfoVO(
        id: id,
        name: 'Mock Inventory',
        materials: [],
        materialExtras: [],
        status: 0,
      ),
    );
  }

  @override
  Future<Result<void>> submitInventory(DoInventoryRequestVO request) {
    throw UnimplementedError();
  }
}
