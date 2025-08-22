/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import '../common/result.dart';
import 'material_categories.dart';

/// MaterialCategories 使用示例
class MaterialCategoriesExample {
  /// 模拟API响应数据
  static const String mockApiResponse = '''
{
    "code": 0,
    "data": [
        {
            "group": 0,
            "name": "第一类:管材",
            "types": [
                {
                    "name": "球墨铸铁",
                    "retrieveBacks": [
                        {
                            "key": "batchNO",
                            "name": "管身批次号",
                            "value": null
                        },
                        {
                            "key": "itemSpec",
                            "name": "规格",
                            "value": null
                        },
                        {
                            "key": "industryArea",
                            "name": "承口铸字(生产基地,例如:XDI)",
                            "value": null
                        }
                    ],
                    "type": 0
                }
            ]
        }
    ],
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
      "data": [
        {
          "group": 0,
          "name": "第一类:管材",
          "types": [
            {
              "name": "球墨铸铁",
              "retrieveBacks": [
                {"key": "batchNO", "name": "管身批次号", "value": null},
                {"key": "itemSpec", "name": "规格", "value": null},
                {
                  "key": "industryArea",
                  "name": "承口铸字(生产基地,例如:XDI)",
                  "value": null,
                },
              ],
              "type": 0,
            },
          ],
        },
      ],
      "msg": "成功",
      "success": true,
      "tc": null,
    };

    // 2. 使用 Result<MaterialCategoriesList> 解析
    final Result<MaterialCategoriesList> result =
        Result.safeFromJson<MaterialCategoriesList>(
          apiJson,
          (json) => MaterialCategoriesList.fromJson(json as List<dynamic>),
          'MaterialCategoriesList',
        );

    // 3. 检查是否成功
    if (result.isSuccess && result.data != null) {
      final categoriesList = result.data!;

      print('物料分类列表:');
      for (final category in categoriesList.categories) {
        print('分组 ${category.group}: ${category.name}');

        for (final type in category.types) {
          print('  物料类型 ${type.type}: ${type.name}');

          for (final retrieveBack in type.retrieveBacks) {
            print('    检索字段: ${retrieveBack.name} (${retrieveBack.key})');
          }
        }
      }

      // 4. 使用实用方法
      print('\n=== 实用方法示例 ===');

      // 获取所有物料类型
      final allTypes = categoriesList.getAllMaterialTypes();
      print('所有物料类型: ${allTypes.map((t) => t.name).join(', ')}');

      // 根据组别获取分类
      final category = categoriesList.getCategoryByGroup(0);
      print('组别0的分类: ${category?.name}');

      // 根据类型编号获取物料类型
      final materialType = categoriesList.getMaterialTypeByType(0);
      print('类型0的物料: ${materialType?.name}');

      // 获取所有检索字段
      final allRetrieveBacks = categoriesList.getAllRetrieveBacks();
      print('所有检索字段: ${allRetrieveBacks.map((rb) => rb.name).join(', ')}');
    } else {
      print('解析失败: ${result.msg}');
    }
  }

  /// 在下拉组件中使用的示例
  static List<MaterialCategoryOption> getCategoryOptionsFromApi(
    Map<String, dynamic> apiResponse,
  ) {
    final result = Result.safeFromJson<MaterialCategoriesList>(
      apiResponse,
      (json) => MaterialCategoriesList.fromJson(json as List<dynamic>),
      'MaterialCategoriesList',
    );

    if (result.isSuccess && result.data != null) {
      return result.data!.categories
          .map(
            (category) => MaterialCategoryOption.fromMaterialCategory(category),
          )
          .toList();
    } else {
      return [];
    }
  }

  /// 获取指定分类下的物料类型选项
  static List<MaterialTypeOption> getMaterialTypeOptions(
    MaterialCategoriesList categoriesList,
    int groupId,
  ) {
    final category = categoriesList.getCategoryByGroup(groupId);
    if (category != null) {
      return category.types
          .map((type) => MaterialTypeOption.fromMaterialType(type))
          .toList();
    }
    return [];
  }

  /// 创建表单字段的示例
  static Map<String, String?> createFormFieldsFromMaterialType(
    MaterialType materialType,
  ) {
    final Map<String, String?> formFields = {};

    for (final retrieveBack in materialType.retrieveBacks) {
      formFields[retrieveBack.key] = retrieveBack.value;
    }

    return formFields;
  }

  /// 验证表单数据的示例
  static bool validateFormData(
    MaterialType materialType,
    Map<String, String?> formData,
  ) {
    for (final retrieveBack in materialType.retrieveBacks) {
      final value = formData[retrieveBack.key];
      if (value == null || value.isEmpty) {
        print('字段 ${retrieveBack.name} 不能为空');
        return false;
      }
    }
    return true;
  }

  /// 格式化检索字段显示的示例
  static String formatRetrieveBackDisplay(RetrieveBack retrieveBack) {
    if (retrieveBack.hasValue) {
      return '${retrieveBack.name}: ${retrieveBack.value}';
    } else {
      return '${retrieveBack.name}: 未填写';
    }
  }
}
