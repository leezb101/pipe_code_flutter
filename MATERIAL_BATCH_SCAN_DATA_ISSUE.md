# 批量扫码数据解析异常问题分析

## 问题描述
在 `scanBatchToQueryAll` 方法中，服务器返回的数据无法正常解析，提示"数据异常"。

## 根本原因
服务器返回的 `normals` 数组中包含两种类型的数据：

### 1. **type=4 的数据（未绑定材料）**
```json
{
  "len": "6000",
  "spec": "DN800",
  "type": "4",  // 未绑定
  "materialCode": "XT08K3312501272006",
  // ❌ 没有 materialId 字段
  // ❌ 没有 status 字段
  // ❌ 没有 statusName 字段
}
```

### 2. **type=0 的数据（已绑定材料）**
```json
{
  "len": "6000",
  "spec": "DN800",
  "type": "0",  // 已绑定
  "materialCode": "XT08K3312501271002",
  "materialId": 694,  // ✅ 有 materialId
  "status": 0,
  "statusName": "对应二维码已绑定材料"
}
```

## 错误堆栈
```
type 'Null' is not a subtype of type 'num' in type cast
at _$MaterialInfoBaseFromJson (material_info_base.g.dart:11:39)
```

错误发生在 `material_info_base.g.dart` 第11行：
```dart
MaterialInfoBase(
  materialId: (json['materialId'] as num).toInt(),  // ❌ 这里失败了！
  // materialId 是必填字段，但 type=4 的数据没有这个字段
  // null as num 导致类型转换失败
)
```

## 数据模型问题

### 当前模型定义
```dart
class MaterialInfoBase extends Equatable {
  const MaterialInfoBase({
    required this.materialId,  // ❌ 必填字段
    this.materialCode,
    this.status,               // 可选字段
    this.statusName,           // 可选字段
    // ...
  });

  final int materialId;        // ❌ 不可为null
  final int? status;
  final String? statusName;
}
```

### 服务器数据特点
- **type=4**: 表示扫描到的材料尚未在系统中绑定，所以**没有** `materialId`
- **type=0**: 表示材料已在系统中绑定，**有** `materialId`、`status`、`statusName`

## 解决方案

### 方案1: 修改 materialId 为可选字段（推荐）
这是最直接的方案，符合服务器数据的实际情况。

```dart
class MaterialInfoBase extends Equatable {
  const MaterialInfoBase({
    this.materialId,  // ✅ 改为可选
    this.materialCode,
    this.status,
    this.statusName,
    // ...
  });

  final int? materialId;  // ✅ 可以为null
  final int? status;
  final String? statusName;
}
```

**优点**：
- 符合服务器数据结构
- 改动最小
- 逻辑清晰：有 materialId = 已绑定，无 materialId = 未绑定

**缺点**：
- 需要在使用时判空

### 方案2: 使用默认值
为 type=4 的数据提供默认的 materialId。

```dart
class MaterialInfo extends Equatable {
  factory MaterialInfo.fromJson(Map<String, dynamic> json) {
    // 如果没有 materialId，使用 -1 或 0 作为默认值
    if (json['materialId'] == null) {
      json['materialId'] = -1;  // 或使用 0
    }
    
    final baseInfo = MaterialInfoBase.fromJson(json);
    // ...
  }
}
```

**优点**：
- 不需要修改 MaterialInfoBase
- 保持 materialId 为必填字段

**缺点**：
- 使用魔数（-1 或 0）表示未绑定状态
- 不够清晰
- 需要在使用时判断 materialId 的值

### 方案3: 创建两个不同的类
根据 type 创建不同的数据类。

```dart
abstract class MaterialInfo {}

class BoundMaterial extends MaterialInfo {
  final int materialId;  // 必填
  final int status;
  final String statusName;
  // ...
}

class UnboundMaterial extends MaterialInfo {
  // 没有 materialId
  final String materialCode;
  // ...
}
```

**优点**：
- 类型安全
- 语义清晰

**缺点**：
- 改动较大
- 增加复杂度

## 测试结果

运行测试 `test/material_data_test.dart`：

```bash
❌ 测试服务器返回的批量扫码数据: FAILED
   错误: type 'Null' is not a subtype of type 'num' in type cast
   原因: normals 数组中 type=4 的数据没有 materialId

❌ 测试单个 type=4 的数据: FAILED
   错误: type 'Null' is not a subtype of type 'num' in type cast
   原因: materialId 是必填字段

✅ 测试单个 type=0 的数据: PASSED
   成功: 有 materialId 的数据可以正常解析
```

## 推荐方案

**采用方案1**，将 `materialId` 改为可选字段：

1. 修改 `MaterialInfoBase`:
```dart
class MaterialInfoBase extends Equatable {
  const MaterialInfoBase({
    this.materialId,  // 改为可选
    // ...
  });

  final int? materialId;  // 可以为null
  // ...
}
```

2. 重新生成代码:
```bash
dart run build_runner build --delete-conflicting-outputs
```

3. 在使用时根据 materialId 判断材料状态:
```dart
if (materialInfo.baseInfo.materialId != null) {
  // 已绑定材料
  print('材料ID: ${materialInfo.baseInfo.materialId}');
} else {
  // 未绑定材料
  print('材料编码: ${materialInfo.baseInfo.materialCode}');
}
```

## 相关文件
- 数据模型: `lib/models/material/material_info_base.dart`
- API 实现: `lib/services/api/implementations/material_handle_api_service_impl.dart`
- 测试文件: `test/material_data_test.dart`

## 日期
2025-10-14
