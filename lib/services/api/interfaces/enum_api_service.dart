import 'package:pipe_code_flutter/models/common/common_enum_vo.dart';
import 'package:pipe_code_flutter/models/common/org_models.dart';
import 'package:pipe_code_flutter/models/common/result.dart';

/// 枚举及组织相关接口服务，声明所有枚举相关 GET 请求方法。
/// 所有方法均返回 Future，直接对接后端接口，返回已定义模型数据类型。
abstract class EnumApiService {
  /// 获取待办类型列表
  /// 直接对接待办类型枚举 GET 接口
  Future<Result<List<TodoType>>> getTodoTypes();

  /// 获取耗材类型列表
  /// 直接对接耗材类型枚举 GET 接口
  Future<Result<List<MaterialType>>> getMaterialTypes();

  /// 获取材料大类group列表
  /// 直接对接耗材大类枚举 GET 接口
  Future<Result<List<MaterialGroup>>> getMaterialGroups();

  /// 获取组织类型列表
  /// 直接对接组织类型枚举 GET 接口
  Future<Result<List<OrgType>>> getOrgTypes();

  /// 获取组织列表
  /// [name] 组织名称模糊查询（可选），[type] 组织类型（可选）
  /// 直接对接组织列表 GET 接口
  Future<Result<List<SimpleOrg>>> getOrgs({String? name, int? type});

  /// 获取验收状态列表
  /// 直接对接验收状态枚举 GET 接口
  Future<Result<List<AcceptStatus>>> getAcceptStatuses();

  /// 获取业务类型列表
  /// 直接对接业务类型枚举 GET 接口
  Future<Result<List<BusinessType>>> getBusinessTypes();

  /// 获取项目状态列表
  /// 直接对接项目状态枚举 GET 接口
  Future<Result<List<ProjectStatus>>> getProjectStatuses();

  /// 获取项目供货类型列表
  /// 直接对接项目供货类型枚举 GET 接口
  Future<Result<List<ProjectSupplyType>>> getProjectSupplyTypes();

  /// 获取项目类型列表
  /// 直接对接项目类型枚举 GET 接口
  Future<Result<List<ProjectType>>> getProjectTypes();

  /// 获取退货类型列表
  /// 直接对接退货类型枚举 GET 接口
  Future<Result<List<ReturnType>>> getReturnTypes();
}
