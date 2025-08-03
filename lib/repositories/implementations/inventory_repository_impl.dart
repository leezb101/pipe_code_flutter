/*
 * @Author: LeeZB
 * @Date: 2025-08-01 17:44:18
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 09:41:48
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/inventory/inventory_models.dart';
import 'package:pipe_code_flutter/repositories/interfaces/inventory_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/inventory_api_service.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryApiService _apiService;

  InventoryRepositoryImpl({InventoryApiService? apiService})
    : _apiService = apiService ?? getIt<InventoryApiService>();

  @override
  Future<InventoryListResponse> getInventoryList({
    required int pageNum,
    required int pageSize,
  }) async {
    final result = await _apiService.getInventoryList(
      pageNum: pageNum,
      pageSize: pageSize,
    );
    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.msg);
    }
  }

  @override
  Future<InventoryDetailInfoVO> getInventoryDetail(int id) async {
    final result = await _apiService.getInventoryDetail(id);
    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.msg);
    }
  }

  @override
  Future<void> submitInventory(DoInventoryRequestVO request) async {
    // 直接调用API, 不处理文件上传, URL将在Bloc层置为null
    final result = await _apiService.submitInventory(request);
    if (!result.isSuccess) {
      throw Exception(result.msg);
    }
  }
}
