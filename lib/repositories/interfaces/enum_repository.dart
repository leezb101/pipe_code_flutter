/*
 * @Author: LeeZB
 * @Date: 2025-07-22 16:18:56
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 18:29:06
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/common_enum_vo.dart';
import 'package:pipe_code_flutter/models/common/org_models.dart';

abstract class EnumRepository {
  Future<void> initializeEnums();

  List<TodoType>? get todoTypes;
  List<Interval>? get intervals;
  List<MaterialGroup>? get materialGroups;
  List<MaterialType>? get materialTypes;
  List<OrgType>? get orgTypes;
  List<SimpleOrg>? get orgs;
  List<AcceptStatus>? get acceptStatuses;
  List<BusinessType>? get businessTypes;
  List<ProjectStatus>? get projectStatuses;
  List<ProjectSupplyType>? get projectSupplyTypes;
  List<ProjectType>? get projectTypes;
  List<ReturnType>? get returnTypes;

  bool get isInitialized;
}
