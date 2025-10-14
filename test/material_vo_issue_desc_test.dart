/*
 * @Author: GitHub Copilot
 * @Date: 2025-10-14
 * @Description: 测试 MaterialVO 的数据问题描述功能
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';

void main() {
  group('MaterialVO issueDesc 测试', () {
    test('所有必填字段都存在 - 不应有问题描述', () {
      final json = {
        'materialId': 123,
        'materialName': '球墨铸铁管',
        'num': 10,
        'materialCode': 'XT08K3312501272006',
      };

      final vo = MaterialVO.fromJson(json);

      expect(vo.materialId, 123);
      expect(vo.materialName, '球墨铸铁管');
      expect(vo.num, 10);
      expect(vo.issueDesc, isNull);
      expect(vo.hasIssue, false);

      print('✅ 完整数据测试通过');
      print('   materialId: ${vo.materialId}');
      print('   materialName: ${vo.materialName}');
      print('   num: ${vo.num}');
      print('   issueDesc: ${vo.issueDesc}');
    });

    test('缺少 materialId - 应生成问题描述', () {
      final json = {
        'materialName': '球墨铸铁管',
        'num': 10,
        'materialCode': 'XT08K3312501272006',
      };

      final vo = MaterialVO.fromJson(json);

      expect(vo.materialId, isNull);
      expect(vo.materialName, '球墨铸铁管');
      expect(vo.num, 10);
      expect(vo.issueDesc, '数据异常：缺少材料ID');
      expect(vo.hasIssue, true);

      print('✅ 缺少materialId测试通过');
      print('   materialId: ${vo.materialId}');
      print('   issueDesc: ${vo.issueDesc}');
    });

    test('缺少 materialName - 应生成问题描述', () {
      final json = {
        'materialId': 123,
        'num': 10,
        'materialCode': 'XT08K3312501272006',
      };

      final vo = MaterialVO.fromJson(json);

      expect(vo.materialId, 123);
      expect(vo.materialName, isNull);
      expect(vo.num, 10);
      expect(vo.issueDesc, '数据异常：缺少材料名称');
      expect(vo.hasIssue, true);

      print('✅ 缺少materialName测试通过');
      print('   materialName: ${vo.materialName}');
      print('   issueDesc: ${vo.issueDesc}');
    });

    test('materialName 为空字符串 - 应生成问题描述', () {
      final json = {'materialId': 123, 'materialName': '', 'num': 10};

      final vo = MaterialVO.fromJson(json);

      expect(vo.materialId, 123);
      expect(vo.materialName, '');
      expect(vo.num, 10);
      expect(vo.issueDesc, '数据异常：缺少材料名称');
      expect(vo.hasIssue, true);

      print('✅ materialName为空字符串测试通过');
      print('   materialName: "${vo.materialName}"');
      print('   issueDesc: ${vo.issueDesc}');
    });

    test('缺少 num - 应生成问题描述', () {
      final json = {
        'materialId': 123,
        'materialName': '球墨铸铁管',
        'materialCode': 'XT08K3312501272006',
      };

      final vo = MaterialVO.fromJson(json);

      expect(vo.materialId, 123);
      expect(vo.materialName, '球墨铸铁管');
      expect(vo.num, isNull);
      expect(vo.issueDesc, '数据异常：缺少数量');
      expect(vo.hasIssue, true);

      print('✅ 缺少num测试通过');
      print('   num: ${vo.num}');
      print('   issueDesc: ${vo.issueDesc}');
    });

    test('缺少多个字段 - 应生成组合问题描述', () {
      final json = {'materialCode': 'XT08K3312501272006'};

      final vo = MaterialVO.fromJson(json);

      expect(vo.materialId, isNull);
      expect(vo.materialName, isNull);
      expect(vo.num, isNull);
      expect(vo.issueDesc, '数据异常：缺少材料ID、材料名称、数量');
      expect(vo.hasIssue, true);

      print('✅ 缺少多个字段测试通过');
      print('   materialId: ${vo.materialId}');
      print('   materialName: ${vo.materialName}');
      print('   num: ${vo.num}');
      print('   issueDesc: ${vo.issueDesc}');
    });

    test('display 辅助方法测试', () {
      final json = {'materialCode': 'XT08K3312501272006'};

      final vo = MaterialVO.fromJson(json);

      expect(vo.displayMaterialName, '未知材料');
      expect(vo.displayMaterialId, '无');
      expect(vo.displayNum, 0);

      print('✅ display辅助方法测试通过');
      print('   displayMaterialName: ${vo.displayMaterialName}');
      print('   displayMaterialId: ${vo.displayMaterialId}');
      print('   displayNum: ${vo.displayNum}');
    });

    test('copyWith 应保留 issueDesc', () {
      final json = {'materialName': '球墨铸铁管', 'num': 10};

      final vo = MaterialVO.fromJson(json);
      expect(vo.issueDesc, '数据异常：缺少材料ID');

      final copied = vo.copyWith(materialCode: 'NEW_CODE');

      expect(copied.issueDesc, '数据异常：缺少材料ID');
      expect(copied.materialCode, 'NEW_CODE');

      print('✅ copyWith保留issueDesc测试通过');
      print('   原始issueDesc: ${vo.issueDesc}');
      print('   复制后issueDesc: ${copied.issueDesc}');
    });

    test('实际服务器数据测试 - type=4 缺少materialId', () {
      // 模拟服务器返回的 type=4 数据（未绑定材料）
      final json = {
        "len": "6000",
        "spec": "DN800",
        "type": "4",
        "group": 0,
        "mfgNm": "新兴铸管股份有限公司",
        "purNm": "郑州水务集团",
        "prodNm": "给水-GB/T 13295-2019-T-DN800-K9-6-水泥-Zn130-HCPE(黑色)",
        "weight": "1.394000",
        "mfgCode": "91130400104365768G",
        "materialCode": "XT08K3312501272006",
        "batchCode": "2025-1272-6",
        // 没有 materialId
        // 没有 materialName
        // 没有 num
      };

      final vo = MaterialVO.fromJson(json);

      expect(vo.materialId, isNull);
      expect(vo.materialName, isNull);
      expect(vo.num, isNull);
      expect(vo.issueDesc, '数据异常：缺少材料ID、材料名称、数量');
      expect(vo.hasIssue, true);

      // 其他字段应该正常解析
      expect(vo.materialCode, 'XT08K3312501272006');
      expect(vo.batchCode, '2025-1272-6');

      print('✅ 实际服务器数据测试通过');
      print('   materialCode: ${vo.materialCode}');
      print('   batchCode: ${vo.batchCode}');
      print('   issueDesc: ${vo.issueDesc}');
      print('   hasIssue: ${vo.hasIssue}');
    });
  });
}
