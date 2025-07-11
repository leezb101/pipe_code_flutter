/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:05:00
 * @copyright: Copyright © 2025 高新供水.
 */
import '../../../models/project/project_initiation.dart';
import '../../../models/common/result.dart';

/// 项目API服务接口
abstract class ProjectApiService {
  /// 新增项目
  Future<Result<void>> addProject(ProjectInitiation project);

  /// 修改项目
  Future<Result<void>> updateProject(ProjectInitiation project);

  /// 提交项目
  Future<Result<void>> commitProject(ProjectInitiation project);

  /// 删除项目
  Future<Result<void>> deleteProject(int id);

  /// 获取项目列表
  Future<Result<List<ProjectListItem>>> getProjectList({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  });

  /// 获取项目详情
  Future<Result<ProjectDetail>> getProjectDetail(int id);

  /// 获取供应商列表
  Future<Result<List<ProjectSupplier>>> getSupplierList();

  /// 获取物料类型列表
  Future<Result<List<MaterialType>>> getMaterialTypes();

  /// 获取用户列表（用于选择负责人）
  Future<Result<List<ProjectUser>>> getUserList({
    String? roleType,
    String? orgCode,
  });
}