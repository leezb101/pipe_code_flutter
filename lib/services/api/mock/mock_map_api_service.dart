import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_base.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_material_statistic_item.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_statistic.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_user.dart';
import 'package:pipe_code_flutter/models/common/org_models.dart';
import 'package:pipe_code_flutter/services/api/interfaces/map_api_service.dart';

class MockMapApiService implements MapApiService {
  @override
  Future<Result<List>> fetchMapWarehouses(
    double lat,
    double lng,
    double radius,
  ) {
    // TODO: implement fetchMapWarehouses
    throw UnimplementedError();
  }

  @override
  Future<Result<List>> fetchMapProjects(double lat, double lng, double radius) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, dynamic>>> fetchMapWarehouseDetail(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Result<MapProjectBase>> fetchMapProjectBase(int id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    final mockData = MapProjectBase(
      projectId: id,
      projectName: '智慧水务管网改造项目',
      projectCode: 'ZHSW-$id',
      startTime: 0,
      auditTime: 1704796800,
      address: '高新区科技路123号',
      construct: [
        const SimpleOrg(
          code: 'CONST-001',
          name: '中建水务建设有限公司',
          type: OrgType(1, '施工单位'),
          typeName: '施工单位',
        ),
      ],
      builder: [
        const SimpleOrg(
          code: 'BUILD-001',
          name: '高新供水集团有限公司',
          type: OrgType(2, '建设单位'),
          typeName: '建设单位',
        ),
      ],
      supervisor: [
        const SimpleOrg(
          code: 'SUPER-001',
          name: '西安工程监理有限公司',
          type: OrgType(3, '监理单位'),
          typeName: '监理单位',
        ),
      ],
    );

    return Result(code: 0, msg: 'success', data: mockData);
  }

  @override
  Future<Result<List<MapProjectMaterialStatisticItem>>>
  fetchMapProjectMaterialStatistics(int id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final mockData = [
      const MapProjectMaterialStatisticItem(
        materialType: 1,
        materialName: '管材-球墨铸铁',
        num: 566,
      ),
      const MapProjectMaterialStatisticItem(
        materialType: 1,
        materialName: '管材-钢塑复合管',
        num: 280,
      ),
      const MapProjectMaterialStatisticItem(
        materialType: 2,
        materialName: '管件-管道管件(球墨管件)',
        num: 386,
      ),
      const MapProjectMaterialStatisticItem(
        materialType: 2,
        materialName: '管件-阀门类',
        num: 125,
      ),
      const MapProjectMaterialStatisticItem(
        materialType: 1,
        materialName: '管材-PE管',
        num: 89,
      ),
    ];

    return Result(code: 0, msg: 'success', data: mockData);
  }

  @override
  Future<Result<MapProjectStatistic>> fetchMapProjectStatistic(int id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    final mockData = MapProjectStatistic(
      projectId: id,
      num: 1250,
      num2: 98,
      acceptTimes: 15,
      acceptNum: 856,
      installNum: 743,
      backNum: 23,
      cutNum: 45,
      destroyNum: 12,
    );

    return Result(code: 0, msg: 'success', data: mockData);
  }

  @override
  Future<Result<List<MapProjectUser>>> fetchMapProjectUsers(
    int id,
    String code,
  ) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 600));

    // 根据不同的code返回不同的用户列表
    List<MapProjectUser> mockUsers;

    switch (code) {
      case 'BUILD-001':
        mockUsers = [
          const MapProjectUser(
            userId: 1001,
            name: '张工程师',
            phone: '13800138001',
            messageTo: true,
            realHandler: true,
          ),
          const MapProjectUser(
            userId: 1002,
            name: '李项目经理',
            phone: '13800138002',
            messageTo: true,
            realHandler: false,
          ),
        ];
        break;
      case 'CONST-001':
        mockUsers = [
          const MapProjectUser(
            userId: 2001,
            name: '王施工队长',
            phone: '13800138003',
            messageTo: false,
            realHandler: true,
          ),
          const MapProjectUser(
            userId: 2002,
            name: '赵技术员',
            phone: '13800138004',
            messageTo: true,
            realHandler: false,
          ),
          const MapProjectUser(
            userId: 2003,
            name: '刘安全员',
            phone: '13800138005',
            messageTo: true,
            realHandler: false,
          ),
        ];
        break;
      case 'SUPER-001':
        mockUsers = [
          const MapProjectUser(
            userId: 3001,
            name: '陈监理工程师',
            phone: '13800138006',
            messageTo: true,
            realHandler: true,
          ),
          const MapProjectUser(
            userId: 3002,
            name: '孙质量检查员',
            phone: '13800138007',
            messageTo: false,
            realHandler: false,
          ),
        ];
        break;
      default:
        mockUsers = [];
    }

    return Result(code: 0, msg: 'success', data: mockUsers);
  }
}
