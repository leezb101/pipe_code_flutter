import '../../../models/common/accept_user_info_vo.dart';
import '../../../models/common/warehouse_user_info_vo.dart';
import '../../../models/common/warehouse_vo.dart';
import '../../../models/common/result.dart';

abstract class ICommonQueryApiService {
  /// 获取验收用户
  /// 
  /// 根据项目ID获取验收过程中涉及的监理负责人和建设方负责人列表
  /// 
  /// [projectId] 项目ID
  /// 
  /// Returns [Result<AcceptUserInfoVO>] 包含监理负责人和建设方负责人的列表
  Future<Result<AcceptUserInfoVO>> getAcceptUsers(int projectId);

  /// 获取仓库用户
  /// 
  /// 根据仓库ID获取该仓库的负责人列表
  /// 
  /// [warehouseId] 仓库ID
  /// 
  /// Returns [Result<WarehouseUserInfoVO>] 包含仓库负责人的列表
  Future<Result<WarehouseUserInfoVO>> getWarehouseUsers(int warehouseId);

  /// 根据物料ID获取仓库信息
  /// 
  /// 根据物料ID查找该物料所在的仓库基本信息
  /// 
  /// [materialId] 物料ID
  /// 
  /// Returns [Result<WarehouseVO>] 包含仓库基本信息
  Future<Result<WarehouseVO>> getWarehouseByMaterial(int materialId);
}