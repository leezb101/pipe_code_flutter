/*
 * @Author: LeeZB
 * @Date: 2025-08-01 17:15:09
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-01 17:19:21
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/inventory/inventory_models.dart';

abstract class InventoryApiService {
  /// 获取盘点任务列表
  /// @param pageNum 页码
  /// @param pageSize 每页数量
  Future<Result<InventoryListResponse>> getInventoryList({
    required int pageNum,
    required int pageSize,
  });

  /// 获取盘点任务详情
  /// @param id 任务ID
  Future<Result<InventoryDetailInfoVO>> getInventoryDetail(int id);

  /// 提交盘点任务
  /// @param request 盘点任务请求对象
  Future<Result<void>> submitInventory(DoInventoryRequestVO request);
}
