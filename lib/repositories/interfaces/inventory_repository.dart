import 'package:pipe_code_flutter/models/inventory/inventory_models.dart';

abstract class InventoryRepository {
  /// 获取盘点任务列表
  Future<InventoryListResponse> getInventoryList({required int pageNum, required int pageSize});

  /// 获取盘点任务详情
  Future<InventoryDetailInfoVO> getInventoryDetail(int id);

  /// 提交盘点
  Future<void> submitInventory(DoInventoryRequestVO request);
}
