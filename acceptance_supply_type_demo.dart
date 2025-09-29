/*
 * 施工方验收供材类型控制演示
 * 展示如何根据currentProjectSupplyType控制采购方判断逻辑
 */

import 'package:pipe_code_flutter/models/user/current_user_on_project_role_info.dart';

void main() {
  print('🔨 施工方验收 - 供材类型控制逻辑演示\n');

  // 模拟不同的项目场景
  final scenarios = [
    {
      'projectName': '工业园区管道安装项目',
      'supplyType': ProjectSupplyType.jiaGongCai,
      'projectPurNm': '高新供水',
      'materials': [
        {'name': 'PE管道DN150', 'purNm': '高新供水'},
        {'name': 'PE管道DN200', 'purNm': '外部供应商'}, // 这个不匹配，但不会检查
      ],
      'note': '甲供材项目，菜单阶段应该已拦截，页面内也跳过检查',
    },
    {
      'projectName': '住宅小区供水改造项目',
      'supplyType': ProjectSupplyType.yiGongCai,
      'projectPurNm': '高新供水',
      'materials': [
        {'name': 'PPR管道DN100', 'purNm': '施工方采购'},
        {'name': 'PPR管道DN150', 'purNm': '材料供应商'}, // 这个不匹配，但不会检查
      ],
      'note': '乙供材项目，施工方负责材料，跳过采购方检查',
    },
    {
      'projectName': '城市主干管网建设项目',
      'supplyType': ProjectSupplyType.jiaYiHunGong,
      'projectPurNm': '高新供水',
      'materials': [
        {'name': 'HDPE管道DN300', 'purNm': '高新供水'}, // 匹配
        {'name': 'HDPE管道DN400', 'purNm': '建设集团'}, // 不匹配，会被检测出来
      ],
      'note': '甲乙混供项目，需要严格检查材料采购方与项目采购方的匹配性',
    },
  ];

  for (var i = 0; i < scenarios.length; i++) {
    final scenario = scenarios[i];
    print('📋 场景 ${i + 1}: ${scenario['projectName']}');
    print(
      '   供材类型: ${_getSupplyTypeDescription(scenario['supplyType'] as ProjectSupplyType)}',
    );
    print('   项目采购方: ${scenario['projectPurNm']}');
    print('   说明: ${scenario['note']}');
    print('   材料清单:');

    final materials = scenario['materials'] as List<Map<String, String>>;
    for (var material in materials) {
      print('   - ${material['name']} (采购方: ${material['purNm']})');
    }

    // 执行采购方匹配检查（施工方验收逻辑）
    final mismatchResults = _checkAcceptancePurchaserMismatchDemo(
      materials,
      scenario['projectPurNm'] as String,
      scenario['supplyType'] as ProjectSupplyType,
    );

    if (mismatchResults.isEmpty) {
      print('   ✅ 验收结果: 无需采购方验证或材料采购方全部匹配，可正常进行验收');
    } else {
      print('   ⚠️  验收结果: 发现采购方不匹配的材料:');
      for (var mismatch in mismatchResults) {
        print('      - $mismatch');
      }
      print('   需要用户确认："仍然继续" 或 "取消操作"');
    }
    print('');
  }

  print('📚 总结:');
  print('1. 甲供材项目: 菜单阶段已拦截，页面内也跳过采购方检查');
  print('2. 乙供材项目: 跳过采购方检查，直接允许验收');
  print('3. 甲乙混供项目: 严格检查材料采购方与项目采购方是否匹配');
  print('4. 只有甲乙混供且存在不匹配时，才会弹出确认对话框');
  print('5. 与建设方验收的差异：施工方关注的是材料来源的合规性');
}

String _getSupplyTypeDescription(ProjectSupplyType supplyType) {
  switch (supplyType) {
    case ProjectSupplyType.jiaGongCai:
      return '甲供材 (${supplyType.value}) - 建设方提供材料';
    case ProjectSupplyType.yiGongCai:
      return '乙供材 (${supplyType.value}) - 施工方提供材料';
    case ProjectSupplyType.jiaYiHunGong:
      return '甲乙混供 (${supplyType.value}) - 双方都提供材料';
  }
}

List<String> _checkAcceptancePurchaserMismatchDemo(
  List<Map<String, String>> materials,
  String projectPurNm,
  ProjectSupplyType supplyType,
) {
  // 前置判断：根据供材类型决定是否需要进行purNm检查（施工方验收逻辑）
  if (supplyType == ProjectSupplyType.yiGongCai) {
    return []; // 乙供材，跳过检查
  }

  if (supplyType == ProjectSupplyType.jiaGongCai) {
    return []; // 甲供材，菜单阶段已拦截，页面内也跳过检查
  }

  // 只有甲乙混供时才进行检查
  if (supplyType != ProjectSupplyType.jiaYiHunGong) {
    return [];
  }

  final mismatchMaterials = <String>[];
  for (final material in materials) {
    final materialPurNm = material['purNm']!;
    if (materialPurNm != projectPurNm) {
      final materialName = material['name']!;
      mismatchMaterials.add('$materialName (采购方: $materialPurNm)');
    }
  }

  return mismatchMaterials;
}
