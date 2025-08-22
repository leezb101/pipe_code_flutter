/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import '../common/result.dart';
import 'vendors_map.dart';

/// VendorsMap 使用示例
class VendorsMapExample {
  /// 模拟API响应数据
  static const String mockApiResponse = '''
{
    "code": 0,
    "data": {
        "91130400104365768G": "新兴铸管",
        "XXXXXXXXXXXXXXXXXX": "熊猫铸管"
    },
    "msg": "成功",
    "success": true,
    "tc": null
}
''';

  /// 解析API响应的示例
  static void parseExample() {
    // 1. 解析完整的API响应
    final Map<String, dynamic> apiJson = {
      "code": 0,
      "data": {"91130400104365768G": "新兴铸管", "XXXXXXXXXXXXXXXXXX": "熊猫铸管"},
      "msg": "成功",
      "success": true,
      "tc": null,
    };

    // 2. 使用 Result<VendorsMap> 解析
    final Result<VendorsMap> result = Result.safeFromJson<VendorsMap>(
      apiJson,
      (json) => VendorsMap.fromJson(json as Map<String, dynamic>),
      'VendorsMap',
    );

    // 3. 检查是否成功
    if (result.isSuccess && result.data != null) {
      final vendorsMap = result.data!;

      // 4. 转换为下拉组件选项
      final List<VendorOption> options = vendorsMap.toOptions();

      print('供应商选项列表:');
      for (final option in options) {
        print('代码: ${option.code}, 名称: ${option.name}');
      }

      // 5. 其他使用方法
      print('\n所有供应商代码: ${vendorsMap.codes}');
      print('所有供应商名称: ${vendorsMap.names}');
      print('根据代码查询名称: ${vendorsMap.getVendorName("91130400104365768G")}');
      print('是否包含代码: ${vendorsMap.containsCode("91130400104365768G")}');
    } else {
      print('解析失败: ${result.msg}');
    }
  }

  /// 在下拉组件中使用的示例
  static List<VendorOption> getVendorOptionsFromApi(
    Map<String, dynamic> apiResponse,
  ) {
    final result = Result.safeFromJson<VendorsMap>(
      apiResponse,
      (json) => VendorsMap.fromJson(json as Map<String, dynamic>),
      'VendorsMap',
    );

    if (result.isSuccess && result.data != null) {
      return result.data!.toOptions();
    } else {
      // 返回空列表或默认选项
      return [];
    }
  }
}
