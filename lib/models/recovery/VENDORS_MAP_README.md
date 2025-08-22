# VendorsMap 使用说明

## 概述

`VendorsMap` 是专门处理供应商映射数据的模型类，用于接收API返回的动态key-value映射并转换为下拉组件的选项列表。

## API 数据结构

```json
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
```

## 使用方法

### 1. 解析完整API响应

```dart
import '../common/result.dart';
import 'vendors_map.dart';

// 完整的API响应
final Map<String, dynamic> apiResponse = {
  "code": 0,
  "data": {
    "91130400104365768G": "新兴铸管",
    "XXXXXXXXXXXXXXXXXX": "熊猫铸管"
  },
  "msg": "成功",
  "success": true,
  "tc": null
};

// 使用 Result<VendorsMap> 解析
final Result<VendorsMap> result = Result.safeFromJson<VendorsMap>(
  apiResponse,
  (json) => VendorsMap.fromJson(json as Map<String, dynamic>),
  'VendorsMap',
);

if (result.isSuccess && result.data != null) {
  final vendorsMap = result.data!;
  // 使用 vendorsMap...
}
```

### 2. 转换为下拉组件选项

```dart
// 获取下拉选项列表
final List<VendorOption> options = vendorsMap.toOptions();

// 在DropdownButton中使用
DropdownButton<String>(
  items: options.map((option) => DropdownMenuItem<String>(
    value: option.code,
    child: Text(option.name),
  )).toList(),
  onChanged: (String? selectedCode) {
    // 处理选择事件
  },
)
```

### 3. 其他实用方法

```dart
// 根据代码获取供应商名称
String? name = vendorsMap.getVendorName("91130400104365768G");

// 获取所有供应商代码
List<String> codes = vendorsMap.codes;

// 获取所有供应商名称
List<String> names = vendorsMap.names;

// 检查是否包含指定代码
bool hasVendor = vendorsMap.containsCode("91130400104365768G");
```

## 核心类说明

### VendorsMap
- `vendors`: 供应商代码到名称的映射
- `toOptions()`: 转换为下拉选项列表
- `getVendorName(String code)`: 根据代码获取名称
- `codes`: 获取所有代码
- `names`: 获取所有名称
- `containsCode(String code)`: 检查是否包含代码

### VendorOption
- `code`: 供应商代码
- `name`: 供应商名称
- `toString()`: 返回供应商名称，便于在UI中显示

## 注意事项

1. `VendorsMap.fromJson()` 方法接收的是API响应中的 `data` 字段内容，不是完整的API响应
2. 使用 `Result<VendorsMap>` 可以安全地处理API响应和类型转换错误
3. `VendorOption` 的 `toString()` 方法返回供应商名称，便于在下拉组件中显示
