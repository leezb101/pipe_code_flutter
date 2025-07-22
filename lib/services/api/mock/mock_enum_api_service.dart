import '../interfaces/enum_api_service.dart';
import '../../../models/common/result.dart';
import '../../../models/common/common_enum_vo.dart';
import '../../../models/common/org_models.dart';
import 'dart:async';

class MockEnumApiService implements EnumApiService {
  @override
  Future<Result<List<TodoType>>> getTodoTypes() async {
    await Future.delayed(Duration(milliseconds: 300));
    return Result<List<TodoType>>(
      code: 0,
      msg: '',
      data: [TodoType(1, '待办类型A'), TodoType(2, '待办类型B'), TodoType(3, '待办类型C')],
    );
  }

  @override
  Future<Result<List<MaterialGroup>>> getMaterialGroups() async {
    await Future.delayed(Duration(milliseconds: 300));
    return Result<List<MaterialGroup>>(
      code: 0,
      msg: '',
      data: [
        MaterialGroup(1, '耗材大类A'),
        MaterialGroup(2, '耗材大类B'),
        MaterialGroup(3, '耗材大类C'),
      ],
    );
  }

  @override
  Future<Result<List<MaterialType>>> getMaterialTypes() async {
    await Future.delayed(Duration(milliseconds: 300));
    return Result<List<MaterialType>>(
      code: 0,
      msg: '',
      data: [
        MaterialType(1, '耗材类型A'),
        MaterialType(2, '耗材类型B'),
        MaterialType(3, '耗材类型C'),
      ],
    );
  }

  @override
  Future<Result<List<OrgType>>> getOrgTypes() async {
    await Future.delayed(Duration(milliseconds: 300));
    return Result<List<OrgType>>(
      code: 0,
      msg: '',
      data: [OrgType(1, '组织类型A'), OrgType(2, '组织类型B'), OrgType(3, '组织类型C')],
    );
  }

  @override
  Future<Result<List<SimpleOrg>>> getOrgs({String? name, int? type}) async {
    await Future.delayed(Duration(milliseconds: 300));
    return Result<List<SimpleOrg>>(
      code: 0,
      msg: '',
      data: [
        SimpleOrg(
          code: 'ORG001',
          name: '组织A',
          type: OrgType(1, '类型A'),
          typeName: '类型A',
        ),
        SimpleOrg(
          code: 'ORG002',
          name: '组织B',
          type: OrgType(2, '类型B'),
          typeName: '类型B',
        ),
        SimpleOrg(
          code: 'ORG003',
          name: '组织C',
          type: OrgType(3, '类型C'),
          typeName: '类型C',
        ),
      ],
    );
  }

  @override
  Future<Result<List<AcceptStatus>>> getAcceptStatuses() async {
    await Future.delayed(Duration(milliseconds: 300));
    return Result<List<AcceptStatus>>(
      code: 0,
      msg: '',
      data: [
        AcceptStatus(1, '未验收'),
        AcceptStatus(2, '已验收'),
        AcceptStatus(3, '验收中'),
      ],
    );
  }

  @override
  Future<Result<List<BusinessType>>> getBusinessTypes() async {
    await Future.delayed(Duration(milliseconds: 300));
    return Result<List<BusinessType>>(
      code: 0,
      msg: '',
      data: [
        BusinessType(1, '业务类型A'),
        BusinessType(2, '业务类型B'),
        BusinessType(3, '业务类型C'),
      ],
    );
  }

  @override
  Future<Result<List<ProjectStatus>>> getProjectStatuses() async {
    await Future.delayed(Duration(milliseconds: 300));
    return Result<List<ProjectStatus>>(
      code: 0,
      msg: '',
      data: [
        ProjectStatus(1, '项目进行中'),
        ProjectStatus(2, '项目已完成'),
        ProjectStatus(3, '项目暂停'),
      ],
    );
  }

  @override
  Future<Result<List<ProjectSupplyType>>> getProjectSupplyTypes() async {
    await Future.delayed(Duration(milliseconds: 300));
    return Result<List<ProjectSupplyType>>(
      code: 0,
      msg: '',
      data: [
        ProjectSupplyType(1, '供货类型A'),
        ProjectSupplyType(2, '供货类型B'),
        ProjectSupplyType(3, '供货类型C'),
      ],
    );
  }

  @override
  Future<Result<List<ProjectType>>> getProjectTypes() async {
    await Future.delayed(Duration(milliseconds: 300));
    return Result<List<ProjectType>>(
      code: 0,
      msg: '',
      data: [
        ProjectType(1, '项目类型A'),
        ProjectType(2, '项目类型B'),
        ProjectType(3, '项目类型C'),
      ],
    );
  }

  @override
  Future<Result<List<ReturnType>>> getReturnTypes() async {
    await Future.delayed(Duration(milliseconds: 300));
    return Result<List<ReturnType>>(
      code: 0,
      msg: '',
      data: [
        ReturnType(1, '退货类型A'),
        ReturnType(2, '退货类型B'),
        ReturnType(3, '退货类型C'),
      ],
    );
  }
}
