/*
 * @Author: GitHub Copilot
 * @Date: 2025-10-14
 * @Description: 测试批量扫码返回数据的解析
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/common/result.dart';

void main() {
  group('MaterialInfoForBusiness 数据解析测试', () {
    test('测试服务器返回的批量扫码数据', () {
      // 模拟服务器返回的数据
      final responseData = {
        "msg": "成功",
        "code": 0,
        "data": {
          "errors": [
            {
              "msg": "内部方法异常: 厂家服务器或数据处理异常",
              "code": "91130400104365768G",
              "name": "新兴铸管",
              "qrCode": "XT08K3312501273033",
            },
          ],
          "normals": [
            // 第一个：type=4，没有 materialId
            {
              "len": "6000",
              "spec": "DN800",
              "type": "4",
              "group": 0,
              "mfgNm": "新兴铸管股份有限公司",
              "purNm": "郑州水务集团（郑州楷顺建设工程有限公司）",
              "prodNm": "给水-GB/T 13295-2019-T-DN800-K9-6-水泥-Zn130-HCPE(黑色)",
              "weight": "1.394000",
              "mfgCode": "91130400104365768G",
              "materialCode": "XT08K3312501272006",
              "batchCode": "2025-1272-6",
            },
            // 第二个：type=0，有 materialId
            {
              "len": "6000",
              "spec": "DN800",
              "type": "0",
              "group": 0,
              "mfgNm": "新兴铸管股份有限公司",
              "materialId": 694,
              "statusName": "对应二维码已绑定材料",
              "materialCode": "XT08K3312501271002",
              "status": 0,
            },
          ],
        },
        "success": true,
      };

      // 尝试解析数据
      try {
        final result = Result.safeFromJson(responseData, (json) {
          return MaterialInfoForBusiness.fromJson(json as Map<String, dynamic>);
        }, 'MaterialInfoForBusiness');

        print('解析结果: code=${result.code}, msg=${result.msg}');
        if (result.data != null) {
          print('normals数量: ${result.data!.normals.length}');
          print('errors数量: ${result.data!.errors.length}');
        }

        // 验证是否成功
        expect(result.code, 0);
        expect(result.data, isNotNull);
      } catch (e, stackTrace) {
        print('❌ 解析失败: $e');
        print('堆栈: $stackTrace');
        fail('数据解析异常: $e');
      }
    });

    test('测试单个 type=4 的数据（没有materialId）', () {
      final itemData = {
        "len": "6000",
        "spec": "DN800",
        "type": "4",
        "group": 0,
        "mfgNm": "新兴铸管股份有限公司",
        "materialCode": "XT08K3312501272006",
        "batchCode": "2025-1272-6",
      };

      try {
        // MaterialInfoBase.fromJson 会失败，因为缺少 materialId
        // 但 MaterialInfo.fromJson 也会调用 MaterialInfoBase.fromJson
        final materialInfo = MaterialInfo.fromJson(itemData);
        print('✅ 成功解析 MaterialInfo');
        print('materialId: ${materialInfo.baseInfo.materialId}');
      } catch (e) {
        print('❌ 解析失败: $e');
        print('原因: MaterialInfoBase 要求 materialId 是必填字段');
        expect(e.toString(), contains('materialId'));
      }
    });

    test('测试单个 type=0 的数据（有materialId）', () {
      final itemData = {
        "len": "6000",
        "spec": "DN800",
        "type": "0",
        "group": 0,
        "mfgNm": "新兴铸管股份有限公司",
        "materialId": 694,
        "materialCode": "XT08K3312501271002",
      };

      try {
        final materialInfo = MaterialInfo.fromJson(itemData);
        print('✅ 成功解析 MaterialInfo');
        print('materialId: ${materialInfo.baseInfo.materialId}');
        expect(materialInfo.baseInfo.materialId, 694);
      } catch (e) {
        print('❌ 解析失败: $e');
        fail('有materialId的数据应该可以正常解析');
      }
    });
  });
}
