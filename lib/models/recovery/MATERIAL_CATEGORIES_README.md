# MaterialCategories 使用说明

## 概述

`MaterialCategories` 是处理物料分类数据的模型集合，用于接收API返回的复杂嵌套结构并提供便捷的数据访问和转换方法。

## API 数据结构

```json
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
```

## 核心类说明

### 1. MaterialCategoriesList
顶层容器类，包含所有物料分类数据。

**主要方法：**
- `getCategoryByGroup(int group)`: 根据组别获取分类
- `getAllMaterialTypes()`: 获取所有物料类型（扁平化）
- `getMaterialTypeByType(int type)`: 根据类型编号获取物料类型
- `getAllRetrieveBacks()`: 获取所有检索字段（扁平化）

### 2. MaterialCategory
物料分类，包含组别、名称和类型列表。

**属性：**
- `group`: 组别编号
- `name`: 分类名称
- `types`: 物料类型列表

### 3. MaterialType
物料类型，包含名称、类型编号和检索字段列表。

**属性：**
- `name`: 物料类型名称
- `type`: 类型编号
- `retrieveBacks`: 检索字段列表

**主要方法：**
- `getRetrieveBackByKey(String key)`: 根据key获取检索字段
- `retrieveBackKeys`: 获取所有检索字段的键
- `retrieveBackNames`: 获取所有检索字段的名称

### 4. RetrieveBack
检索字段，包含键、名称和值。

**属性：**
- `key`: 字段键
- `name`: 字段名称
- `value`: 字段值（可为空）

**主要方法：**
- `copyWithValue(String? newValue)`: 创建带有新值的副本
- `hasValue`: 判断是否有值

### 5. 下拉组件选项类
- `MaterialCategoryOption`: 物料分类选项
- `MaterialTypeOption`: 物料类型选项

## 使用示例

### 1. 解析完整API响应

```dart
import '../common/result.dart';
import 'material_categories.dart';

// 完整的API响应
final Map<String, dynamic> apiResponse = {
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
};

// 使用 Result<MaterialCategoriesList> 解析
final Result<MaterialCategoriesList> result = Result.safeFromJson<MaterialCategoriesList>(
  apiResponse,
  (json) => MaterialCategoriesList.fromJson(json as List<dynamic>),
  'MaterialCategoriesList',
);

if (result.isSuccess && result.data != null) {
  final categoriesList = result.data!;
  // 使用 categoriesList...
}
```

### 2. 创建分类下拉组件

```dart
// 获取分类选项
List<MaterialCategoryOption> getCategoryOptions(MaterialCategoriesList categoriesList) {
  return categoriesList.categories
      .map((category) => MaterialCategoryOption.fromMaterialCategory(category))
      .toList();
}

// 在DropdownButton中使用
DropdownButton<int>(
  items: getCategoryOptions(categoriesList).map((option) => 
    DropdownMenuItem<int>(
      value: option.group,
      child: Text(option.name),
    )).toList(),
  onChanged: (int? selectedGroup) {
    // 处理分类选择
  },
)
```

### 3. 级联下拉组件

```dart
// 根据选择的分类获取物料类型
List<MaterialTypeOption> getMaterialTypeOptions(
  MaterialCategoriesList categoriesList,
  int selectedGroup,
) {
  final category = categoriesList.getCategoryByGroup(selectedGroup);
  if (category != null) {
    return category.types
        .map((type) => MaterialTypeOption.fromMaterialType(type))
        .toList();
  }
  return [];
}

// 第二级下拉组件
DropdownButton<int>(
  items: getMaterialTypeOptions(categoriesList, selectedGroup).map((option) => 
    DropdownMenuItem<int>(
      value: option.type,
      child: Text(option.name),
    )).toList(),
  onChanged: (int? selectedType) {
    // 处理物料类型选择
  },
)
```

### 4. 动态表单生成

```dart
// 根据选择的物料类型生成表单字段
Widget buildDynamicForm(MaterialType materialType) {
  return Column(
    children: materialType.retrieveBacks.map((retrieveBack) {
      return TextFormField(
        decoration: InputDecoration(
          labelText: retrieveBack.name,
          hintText: '请输入${retrieveBack.name}',
        ),
        initialValue: retrieveBack.value,
        onChanged: (value) {
          // 处理字段值变化
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '${retrieveBack.name}不能为空';
          }
          return null;
        },
      );
    }).toList(),
  );
}
```

### 5. 表单数据处理

```dart
// 创建表单数据Map
Map<String, String?> createFormData(MaterialType materialType) {
  final Map<String, String?> formData = {};
  for (final retrieveBack in materialType.retrieveBacks) {
    formData[retrieveBack.key] = retrieveBack.value;
  }
  return formData;
}

// 验证表单数据
bool validateFormData(MaterialType materialType, Map<String, String?> formData) {
  for (final retrieveBack in materialType.retrieveBacks) {
    final value = formData[retrieveBack.key];
    if (value == null || value.isEmpty) {
      return false;
    }
  }
  return true;
}

// 更新检索字段值
List<RetrieveBack> updateRetrieveBackValues(
  List<RetrieveBack> retrieveBacks,
  Map<String, String?> formData,
) {
  return retrieveBacks.map((retrieveBack) {
    final newValue = formData[retrieveBack.key];
    return retrieveBack.copyWithValue(newValue);
  }).toList();
}
```

## 实际应用场景

### 1. 物料选择流程
```dart
class MaterialSelectionFlow {
  MaterialCategoriesList? categoriesList;
  int? selectedGroup;
  int? selectedType;
  Map<String, String?> formData = {};

  // 第一步：选择物料分类
  void selectCategory(int group) {
    selectedGroup = group;
    selectedType = null;
    formData.clear();
  }

  // 第二步：选择物料类型
  void selectMaterialType(int type) {
    selectedType = type;
    final materialType = categoriesList?.getMaterialTypeByType(type);
    if (materialType != null) {
      formData = createFormData(materialType);
    }
  }

  // 第三步：填写检索字段
  void updateFormField(String key, String? value) {
    formData[key] = value;
  }

  // 验证并提交
  bool canSubmit() {
    if (selectedType == null) return false;
    final materialType = categoriesList?.getMaterialTypeByType(selectedType!);
    if (materialType == null) return false;
    return validateFormData(materialType, formData);
  }
}
```

### 2. 搜索和过滤
```dart
// 根据关键词搜索物料类型
List<MaterialType> searchMaterialTypes(
  MaterialCategoriesList categoriesList,
  String keyword,
) {
  return categoriesList.getAllMaterialTypes()
      .where((type) => type.name.contains(keyword))
      .toList();
}

// 根据检索字段过滤
List<MaterialType> filterByRetrieveBack(
  MaterialCategoriesList categoriesList,
  String retrieveBackKey,
) {
  return categoriesList.getAllMaterialTypes()
      .where((type) => type.retrieveBackKeys.contains(retrieveBackKey))
      .toList();
}
```

## 注意事项

1. `MaterialCategoriesList.fromJson()` 方法接收的是API响应中的 `data` 字段内容（List<dynamic>），不是完整的API响应
2. 使用 `Result<MaterialCategoriesList>` 可以安全地处理API响应和类型转换错误
3. 检索字段的 `value` 可能为 `null`，使用前需要检查
4. 提供了多个实用方法用于数据查询和转换，避免重复的遍历操作
5. 下拉组件选项类重写了 `toString()` 方法，便于在UI中显示
