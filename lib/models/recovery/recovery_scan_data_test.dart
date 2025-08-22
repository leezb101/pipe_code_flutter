/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:convert';
import 'package:pipe_code_flutter/models/recovery/recovery_scan_data.dart';

/// RecoveryScanData模型测试示例
void testRecoveryScanDataModel() {
  // 测试JSON数据
  const testJson = '''
  {
    "type": 0,
    "group": 0,
    "produceDate": "2023-06-21",
    "materialId": null,
    "isDestroy": null,
    "isBack": null,
    "materialCode": "XH09K3312301016007",
    "transCardNo": null,
    "batchCode": "2023-1016-7",
    "deliveryNumber": null,
    "mfgNm": null,
    "mfgCode": null,
    "purNm": "郑州水务集团（山西卓安物资贸易有限公司）",
    "prodStdNo": "P30WL056960",
    "standard": "Q/XPB 028-2023",
    "prodNm": null,
    "spec": "DN1000",
    "pressLvl": "K9",
    "weight": "2.01500",
    "deliveryCode": "20241022A1001",
    "otherMaterialByDelivery": null,
    "delivery": {
      "deliveryCode": "20241022A1001",
      "tranPlanNo": "FH202308250064",
      "salesmanName": "何策",
      "salesmanPhone": "",
      "consignee": "",
      "consigneePhone": "",
      "consigneeAddr": "",
      "carryCorpName": "",
      "vehicleNo": "冀EU7911",
      "driverName": "张三",
      "driverPhone": "",
      "signUrl": "",
      "currentSignUrl": "",
      "totalQty": "4",
      "totalWt": "6.756000",
      "leaveFactoryTime": "20241022104220",
      "signTime": ""
    },
    "warrantyUrl": "/group1/vendor_material/20250801/15/41/6/material_P30WL056960.pdf",
    "currentWarrantyUrl": "http://10.3.6.235/group1/vendor_material/20250801/15/41/6/material_P30WL056960.pdf",
    "certificateUrl": "/group1/vendor_material/20250818/18/52/6/certificate_P30WL056960.pdf",
    "currentCertificateUrl": "http://10.3.6.235/group1/vendor_material/20250818/18/52/6/certificate_P30WL056960.pdf",
    "signUrl": "",
    "currentSignUrl": null
  }
  ''';

  try {
    // 解析JSON
    final Map<String, dynamic> jsonMap = json.decode(testJson);

    // 创建模型实例
    final scanData = RecoveryScanData.fromJson(jsonMap);

    print('✅ 模型解析成功!');
    print('材料编码: ${scanData.materialCode}');
    print('规格: ${scanData.spec}');
    print('压力等级: ${scanData.pressLvl}');
    print('采购方: ${scanData.purNm}');
    print('发货信息: ${scanData.delivery?.vehicleNo}');

    // 测试序列化
    final backToJson = scanData.toJson();
    print('✅ 序列化成功!');
    print('序列化后字段数: ${backToJson.length}');
  } catch (e, stackTrace) {
    print('❌ 模型测试失败: $e');
    print('堆栈跟踪: $stackTrace');
  }
}

/// 测试最小数据集（只有必需字段）
void testMinimalData() {
  const minimalJson = '''
  {
    "type": 1,
    "group": 2,
    "materialCode": "TEST123"
  }
  ''';

  try {
    final Map<String, dynamic> jsonMap = json.decode(minimalJson);
    final scanData = RecoveryScanData.fromJson(jsonMap);

    print('✅ 最小数据集解析成功!');
    print('材料编码: ${scanData.materialCode}');
    print('类型: ${scanData.type}');
    print('分组: ${scanData.group}');
  } catch (e) {
    print('❌ 最小数据集测试失败: $e');
  }
}

/// 使用示例说明
/// 
/// ## 数据字段映射说明
/// - type/group: 必需字段，用于材料分类
/// - materialCode: 必需字段，材料唯一标识
/// - 其他字段均为可选，根据实际数据情况填充
/// 
/// ## 在Recovery模块中的使用
/// ```dart
/// // Step3 API返回数据解析
/// final scanData = RecoveryScanData.fromJson(apiResponse['data']);
/// 
/// // 在确认弹窗中显示
/// _buildInfoRow('材料编码', scanData.materialCode);
/// _buildInfoRow('规格', scanData.spec ?? '未指定');
/// ```
/// 
/// ## 发货信息的处理
/// delivery字段包含完整的发货信息，在确认弹窗中单独显示
