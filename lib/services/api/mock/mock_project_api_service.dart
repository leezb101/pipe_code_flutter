/*
 * @Author: LeeZB
 * @Date: 2025-07-22 08:53:08
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-24 19:37:48
 * @copyright: Copyright © 2025 高新供水.
 */
/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:05:00
 * @copyright: Copyright © 2025 高新供水.
 */
import '../interfaces/project_api_service.dart';
import '../../../models/project/project_initiation.dart';
import '../../../models/common/result.dart';
import '../../../utils/mock_data_generator.dart';

/// Mock项目API服务
/// 完全匹配API文档结构的模拟实现
class MockProjectApiService implements ProjectApiService {
  static const Duration _defaultDelay = Duration(milliseconds: 800);
  static final List<ProjectListItem> _mockProjects = [];
  static final List<ProjectDetail> _mockProjectDetails = [];
  static int _nextId = 1;

  static void _initializeMockData() {
    if (_mockProjects.isEmpty) {
      // 生成模拟项目列表
      for (int i = 1; i <= 20; i++) {
        _mockProjects.add(
          ProjectListItem(
            id: i,
            projectName: '智慧水务项目_${i.toString().padLeft(2, '0')}',
            projectCode: 'WM${i.toString().padLeft(3, '0')}',
            projectStart: DateTime.now()
                .subtract(Duration(days: i * 30))
                .toIso8601String(),
            projectEnd: DateTime.now()
                .add(Duration(days: i * 60))
                .toIso8601String(),
            createdName: '创建者_$i',
            createdId: i,
            status: i % 3,
          ),
        );
      }
      _nextId = _mockProjects.length + 1;
    }
  }

  @override
  Future<Result<void>> addProject(ProjectInitiation project) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);
    _initializeMockData();

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      return const Result(code: 400, msg: '项目创建失败', data: null);
    }

    // 验证必填字段
    if (project.projectName.isEmpty) {
      return const Result(code: 400, msg: '项目名称不能为空', data: null);
    }

    if (project.projectCode.isEmpty) {
      return const Result(code: 400, msg: '项目编号不能为空', data: null);
    }

    // 检查项目编号是否重复
    if (_mockProjects.any((p) => p.projectCode == project.projectCode)) {
      return const Result(code: 400, msg: '项目编号已存在', data: null);
    }

    // 添加到列表
    final newProject = ProjectListItem(
      id: _nextId++,
      projectName: project.projectName,
      projectCode: project.projectCode,
      projectStart: project.projectStart,
      projectEnd: project.projectEnd,
      createdName: '当前用户',
      createdId: 1,
      status: 0, // 草稿状态
    );
    _mockProjects.insert(0, newProject);

    return const Result(code: 0, msg: '项目创建成功', data: null);
  }

  @override
  Future<Result<void>> updateProject(ProjectInitiation project) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);
    _initializeMockData();

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      return const Result(code: 400, msg: '项目更新失败', data: null);
    }

    if (project.id == null) {
      return const Result(code: 400, msg: '项目ID不能为空', data: null);
    }

    final index = _mockProjects.indexWhere((p) => p.id == project.id);
    if (index == -1) {
      return const Result(code: 404, msg: '项目不存在', data: null);
    }

    // 更新项目信息
    final updatedProject = _mockProjects[index].copyWith(
      projectName: project.projectName,
      projectCode: project.projectCode,
      projectStart: project.projectStart,
      projectEnd: project.projectEnd,
    );
    _mockProjects[index] = updatedProject;

    return const Result(code: 0, msg: '项目更新成功', data: null);
  }

  @override
  Future<Result<void>> commitProject(ProjectInitiation project) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);
    _initializeMockData();

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      return const Result(code: 400, msg: '项目提交失败', data: null);
    }

    if (project.id == null) {
      return const Result(code: 400, msg: '项目ID不能为空', data: null);
    }

    final index = _mockProjects.indexWhere((p) => p.id == project.id);
    if (index == -1) {
      return const Result(code: 404, msg: '项目不存在', data: null);
    }

    // 更新项目状态为已提交
    final updatedProject = _mockProjects[index].copyWith(
      status: 1, // 已提交状态
    );
    _mockProjects[index] = updatedProject;

    return const Result(code: 0, msg: '项目提交成功', data: null);
  }

  @override
  Future<Result<void>> deleteProject(int id) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);
    _initializeMockData();

    if (MockDataGenerator.shouldFail(failureRate: 0.05)) {
      return const Result(code: 400, msg: '项目删除失败', data: null);
    }

    final index = _mockProjects.indexWhere((p) => p.id == id);
    if (index == -1) {
      return const Result(code: 404, msg: '项目不存在', data: null);
    }

    _mockProjects.removeAt(index);

    return const Result(code: 0, msg: '项目删除成功', data: null);
  }

  @override
  Future<Result<List<ProjectListItem>>> getProjectList({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);
    _initializeMockData();

    if (MockDataGenerator.shouldFail(failureRate: 0.05)) {
      return const Result(code: 400, msg: '获取项目列表失败', data: null);
    }

    // 过滤项目
    var filteredProjects = _mockProjects.where((project) {
      bool nameMatch =
          projectName == null || project.projectName.contains(projectName);
      bool codeMatch =
          projectCode == null || project.projectCode.contains(projectCode);
      return nameMatch && codeMatch;
    }).toList();

    // 分页处理
    final startIndex = (pageNum - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    final pagedProjects = filteredProjects.sublist(
      startIndex,
      endIndex > filteredProjects.length ? filteredProjects.length : endIndex,
    );

    return Result(code: 0, msg: '成功', data: pagedProjects);
  }

  @override
  Future<Result<ProjectDetail>> getProjectDetail(int id) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);
    _initializeMockData();

    if (MockDataGenerator.shouldFail(failureRate: 0.05)) {
      return const Result(code: 400, msg: '获取项目详情失败', data: null);
    }

    final project = _mockProjects.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('项目不存在'),
    );

    // 生成模拟的项目详情
    final detail = ProjectDetail(
      id: project.id,
      projectName: project.projectName,
      projectCode: project.projectCode,
      projectStart: project.projectStart,
      projectEnd: project.projectEnd,
      projectReportUrl: 'https://example.com/report_${project.id}.pdf',
      publishBidUrl: 'https://example.com/bid_${project.id}.pdf',
      aimBidUrl: 'https://example.com/aim_${project.id}.pdf',
      otherDocUrl: 'https://example.com/other_${project.id}.pdf',
      status: project.status,
      supplyType: id % 3,
      type: 1,
      createdName: project.createdName,
      createdId: project.createdId.toString(),
      materialList: _generateMockMaterials(id),
      constructionUserList: _generateMockUsers(id, 'construction'),
      supervisorUserList: _generateMockUsers(id, 'supervisor'),
      builderUserList: _generateMockUsers(id, 'builder'),
    );

    return Result(code: 0, msg: '成功', data: detail);
  }

  @override
  Future<Result<List<ProjectSupplier>>> getSupplierList() async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 500),
    );

    if (MockDataGenerator.shouldFail(failureRate: 0.05)) {
      return const Result(code: 400, msg: '获取供应商列表失败', data: null);
    }

    final suppliers = [
      const ProjectSupplier(orgCode: 'SUP001', orgName: '华润水泥供应商'),
      const ProjectSupplier(orgCode: 'SUP002', orgName: '中建钢材供应商'),
      const ProjectSupplier(orgCode: 'SUP003', orgName: '三一重工设备供应商'),
      const ProjectSupplier(orgCode: 'SUP004', orgName: '联塑管材供应商'),
      const ProjectSupplier(orgCode: 'SUP005', orgName: '伟星管件供应商'),
    ];

    return Result(code: 0, msg: '成功', data: suppliers);
  }

  @override
  Future<Result<List<MaterialType>>> getMaterialTypes() async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 300),
    );

    if (MockDataGenerator.shouldFail(failureRate: 0.05)) {
      return const Result(code: 400, msg: '获取物料类型失败', data: null);
    }

    return const Result(code: 0, msg: '成功', data: MaterialType.values);
  }

  @override
  Future<Result<List<ProjectUser>>> getUserList({
    String? roleType,
    String? orgCode,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 600),
    );

    if (MockDataGenerator.shouldFail(failureRate: 0.05)) {
      return const Result(code: 400, msg: '获取用户列表失败', data: null);
    }

    final users = _generateMockUsers(1, roleType ?? 'construction');

    return Result(code: 0, msg: '成功', data: users);
  }

  // 生成模拟物料列表
  List<ProjectMaterial> _generateMockMaterials(int projectId) {
    final materials = [
      const ProjectMaterial(
        name: 'PE管DN100',
        type: 1,
        typeName: '管材',
        needNum: 1000,
      ),
      const ProjectMaterial(
        name: '三通DN100',
        type: 2,
        typeName: '管件',
        needNum: 50,
      ),
      const ProjectMaterial(
        name: '弯头DN100',
        type: 2,
        typeName: '管件',
        needNum: 100,
      ),
      const ProjectMaterial(
        name: '水表DN100',
        type: 3,
        typeName: '设备',
        needNum: 10,
      ),
    ];

    return materials.take(projectId % 4 + 1).toList();
  }

  // 生成模拟用户列表
  List<ProjectUser> _generateMockUsers(int projectId, String roleType) {
    final baseUsers = [
      const ProjectUser(
        userId: 1001,
        name: '张三',
        code: 'ORG001',
        orgName: '高新供水有限公司',
        phone: '13800138001',
      ),
      const ProjectUser(
        userId: 1002,
        name: '李四',
        code: 'ORG002',
        orgName: '市政建设监理公司',
        phone: '13800138002',
      ),
      const ProjectUser(
        userId: 1003,
        name: '王五',
        code: 'ORG003',
        orgName: '城建施工集团',
        phone: '13800138003',
      ),
    ];

    return baseUsers.take(projectId % 3 + 1).toList();
  }
}

// 扩展现有的ProjectListItem类以支持copyWith方法
extension ProjectListItemExtension on ProjectListItem {
  ProjectListItem copyWith({
    int? id,
    String? projectName,
    String? projectCode,
    String? projectStart,
    String? projectEnd,
    String? createdName,
    int? createdId,
    int? status,
  }) {
    return ProjectListItem(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      projectCode: projectCode ?? this.projectCode,
      projectStart: projectStart ?? this.projectStart,
      projectEnd: projectEnd ?? this.projectEnd,
      createdName: createdName ?? this.createdName,
      createdId: createdId ?? this.createdId,
      status: status ?? this.status,
    );
  }
}
