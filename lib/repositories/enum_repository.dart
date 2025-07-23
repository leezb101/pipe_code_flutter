/*
 * @Author: LeeZB
 * @Date: 2025-07-22 16:18:56
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-23 16:34:53
 * @copyright: Copyright © 2025 高新供水.
 */
/*
 * @Author: LeeZB
 * @Date: 2025-07-22 16:18:56
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-22 17:07:39
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/services/api/interfaces/enum_api_service.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/common/common_enum_vo.dart';
import 'package:pipe_code_flutter/models/common/org_models.dart';

/// 枚举仓库，负责统一拉取和管理所有枚举数据
class EnumRepository {
  final EnumApiService _enumApiService;

  List<TodoType>? _todoTypes;
  List<MaterialGroup>? _materialGroups;
  List<MaterialType>? _materialTypes;
  List<OrgType>? _orgTypes;
  List<SimpleOrg>? _orgs;
  List<AcceptStatus>? _acceptStatuses;
  List<BusinessType>? _businessTypes;
  List<ProjectStatus>? _projectStatuses;
  List<ProjectSupplyType>? _projectSupplyTypes;
  List<ProjectType>? _projectTypes;
  List<ReturnType>? _returnTypes;

  EnumRepository(this._enumApiService);

  /// 初始化所有枚举数据，建议在应用启动时调用
  Future<void> initializeEnums() async {
    final results = await Future.wait([
      _enumApiService.getTodoTypes(),
      _enumApiService.getMaterialGroups(),
      _enumApiService.getMaterialTypes(),
      _enumApiService.getOrgTypes(),
      _enumApiService.getOrgs(),
      _enumApiService.getAcceptStatuses(),
      _enumApiService.getBusinessTypes(),
      _enumApiService.getProjectStatuses(),
      _enumApiService.getProjectSupplyTypes(),
      _enumApiService.getProjectTypes(),
      _enumApiService.getReturnTypes(),
    ]);

    _todoTypes = (results[0] as Result<List<TodoType>>).data;
    _materialGroups = (results[1] as Result<List<MaterialGroup>>).data;
    _materialTypes = (results[2] as Result<List<MaterialType>>).data;
    _orgTypes = (results[3] as Result<List<OrgType>>).data;
    _orgs = (results[4] as Result<List<SimpleOrg>>).data;
    _acceptStatuses = (results[5] as Result<List<AcceptStatus>>).data;
    _businessTypes = (results[6] as Result<List<BusinessType>>).data;
    _projectStatuses = (results[7] as Result<List<ProjectStatus>>).data;
    _projectSupplyTypes = (results[8] as Result<List<ProjectSupplyType>>).data;
    _projectTypes = (results[9] as Result<List<ProjectType>>).data;
    _returnTypes = (results[10] as Result<List<ReturnType>>).data;

    // 初始化各枚举类的静态值列表
    if (_todoTypes != null) {
      TodoType.initFromList(_todoTypes!.map((e) => {'code': e.value, 'msg': e.name}).toList());
    }
    if (_materialGroups != null) {
      MaterialGroup.initFromList(_materialGroups!.map((e) => {'code': e.value, 'msg': e.name}).toList());
    }
    if (_materialTypes != null) {
      MaterialType.initFromList(_materialTypes!.map((e) => {'code': e.value, 'msg': e.name}).toList());
    }
    if (_acceptStatuses != null) {
      AcceptStatus.initFromList(_acceptStatuses!.map((e) => {'code': e.value, 'msg': e.name}).toList());
    }
    if (_businessTypes != null) {
      BusinessType.initFromList(_businessTypes!.map((e) => {'code': e.value, 'msg': e.name}).toList());
    }
    if (_projectStatuses != null) {
      ProjectStatus.initFromList(_projectStatuses!.map((e) => {'code': e.value, 'msg': e.name}).toList());
    }
    if (_projectSupplyTypes != null) {
      ProjectSupplyType.initFromList(_projectSupplyTypes!.map((e) => {'code': e.value, 'msg': e.name}).toList());
    }
    if (_projectTypes != null) {
      ProjectType.initFromList(_projectTypes!.map((e) => {'code': e.value, 'msg': e.name}).toList());
    }
    if (_returnTypes != null) {
      ReturnType.initFromList(_returnTypes!.map((e) => {'code': e.value, 'msg': e.name}).toList());
    }
  }

  List<TodoType>? get todoTypes => _todoTypes;
  List<MaterialGroup>? get materialGroups => _materialGroups;
  List<MaterialType>? get materialTypes => _materialTypes;
  List<OrgType>? get orgTypes => _orgTypes;
  List<SimpleOrg>? get orgs => _orgs;
  List<AcceptStatus>? get acceptStatuses => _acceptStatuses;
  List<BusinessType>? get businessTypes => _businessTypes;
  List<ProjectStatus>? get projectStatuses => _projectStatuses;
  List<ProjectSupplyType>? get projectSupplyTypes => _projectSupplyTypes;
  List<ProjectType>? get projectTypes => _projectTypes;
  List<ReturnType>? get returnTypes => _returnTypes;

  /// 判断是否已初始化
  bool get isInitialized =>
      _todoTypes != null &&
      _materialGroups != null &&
      _materialTypes != null &&
      _orgTypes != null &&
      _orgs != null &&
      _acceptStatuses != null &&
      _businessTypes != null &&
      _projectStatuses != null &&
      _projectSupplyTypes != null &&
      _projectTypes != null &&
      _returnTypes != null;
}
