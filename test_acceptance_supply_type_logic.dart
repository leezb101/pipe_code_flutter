/*
 * 测试施工方验收中供材类型的判断逻辑
 */

import 'package:pipe_code_flutter/models/user/current_user_on_project_role_info.dart';

void main() {
  print('=== 测试施工方验收供材类型逻辑 ===\n');

  // 测试场景
  final testCases = [
    {
      'supplyType': ProjectSupplyType.jiaGongCai,
      'description': '甲供材 - 菜单阶段已拦截，但为安全起见也跳过purNm判断',
      'shouldCheckPurNm': false,
    },
    {
      'supplyType': ProjectSupplyType.yiGongCai,
      'description': '乙供材 - 不需要进行purNm判断',
      'shouldCheckPurNm': false,
    },
    {
      'supplyType': ProjectSupplyType.jiaYiHunGong,
      'description': '甲乙混供 - 需要进行purNm判断，只有完全一致才能继续',
      'shouldCheckPurNm': true,
    },
  ];

  for (var testCase in testCases) {
    final supplyType = testCase['supplyType'] as ProjectSupplyType;
    final description = testCase['description'] as String;
    final shouldCheckPurNm = testCase['shouldCheckPurNm'] as bool;

    print('测试场景: $description');
    print('供材类型: ${supplyType.name} (值: ${supplyType.value})');
    print('应该检查purNm: $shouldCheckPurNm');

    // 模拟我们在AcceptanceBloc中的逻辑
    bool needCheckPurNm = _simulateAcceptanceSupplyTypeLogic(supplyType);

    print('实际逻辑结果: 需要检查purNm = $needCheckPurNm');
    print('测试结果: ${needCheckPurNm == shouldCheckPurNm ? "✅ 通过" : "❌ 失败"}');
    print('---');
  }

  print('\n=== 业务规则总结 ===');
  print('甲供材(0): 菜单阶段已拦截，页面内跳过purNm检查');
  print('乙供材(1): 跳过purNm检查，直接正常进行');
  print('甲乙混供(2): 需要通过材料的purNm与项目的currentPurNm进行比对');
  print('只有完全一致才能继续，不一致则弹出警告让用户选择');
}

/// 模拟AcceptanceBloc中的供材类型判断逻辑（施工方验收）
bool _simulateAcceptanceSupplyTypeLogic(ProjectSupplyType supplyType) {
  // 如果是"乙供材"，则不需要进行purNm判断
  if (supplyType == ProjectSupplyType.yiGongCai) {
    return false;
  }

  // 如果是"甲供材"，菜单阶段应该已经拦截，但为安全起见也跳过purNm判断
  if (supplyType == ProjectSupplyType.jiaGongCai) {
    return false;
  }

  // 只有"甲乙混供"时，才需要进行purNm判断
  if (supplyType == ProjectSupplyType.jiaYiHunGong) {
    return true;
  }

  return false;
}
