import '../../../models/common/accept_user_info_vo.dart';
import '../../../models/common/warehouse_user_info_vo.dart';
import '../../../models/common/warehouse_vo.dart';
import '../../../models/common/common_user_vo.dart';
import '../../../models/common/result.dart';
import '../interfaces/common_query_api_service.dart';

class MockCommonQueryApiService implements ICommonQueryApiService {
  @override
  Future<Result<AcceptUserInfoVO>> getAcceptUsers(int projectId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final acceptUserInfo = AcceptUserInfoVO(
      supervisorUsers: [
        const CommonUserVO(
          userId: 1,
          name: '张监理',
          phone: '13800138001',
          messageTo: true,
          realHandler: true,
        ),
        const CommonUserVO(
          userId: 2,
          name: '李监理',
          phone: '13800138002',
          messageTo: false,
          realHandler: false,
        ),
      ],
      constructionUsers: [
        const CommonUserVO(
          userId: 3,
          name: '王建设',
          phone: '13800138003',
          messageTo: true,
          realHandler: false,
        ),
        const CommonUserVO(
          userId: 4,
          name: '刘建设',
          phone: '13800138004',
          messageTo: false,
          realHandler: true,
        ),
      ],
    );

    return Result<AcceptUserInfoVO>(
      code: 0,
      msg: '',
      data: acceptUserInfo,
    );
  }

  @override
  Future<Result<WarehouseUserInfoVO>> getWarehouseUsers(int warehouseId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final warehouseUserInfo = WarehouseUserInfoVO(
      warehouseUsers: [
        const CommonUserVO(
          userId: 5,
          name: '赵仓管',
          phone: '13800138005',
          messageTo: true,
          realHandler: true,
        ),
        const CommonUserVO(
          userId: 6,
          name: '孙仓管',
          phone: '13800138006',
          messageTo: false,
          realHandler: false,
        ),
      ],
    );

    return Result<WarehouseUserInfoVO>(
      code: 0,
      msg: '',
      data: warehouseUserInfo,
    );
  }

  @override
  Future<Result<WarehouseVO>> getWarehouseByMaterial(int materialId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final warehouse = WarehouseVO(
      id: materialId % 10 + 1, // 基于materialId生成仓库ID
      name: '中心仓库${materialId % 5 + 1}号',
      address: '智慧水务产业园区A${materialId % 3 + 1}栋',
      isRealWarehouse: materialId % 2 == 0,
    );

    return Result<WarehouseVO>(
      code: 0,
      msg: '',
      data: warehouse,
    );
  }
}