# Dispatch记录类型优化实现说明

## 需求概述

为`dispatch`（调拨）类型的记录添加"目的项目"字段的展示，并优化所有记录项的项目信息展示样式。

## 实现内容

### 1. 数据模型层修改

#### a) `BusinessRecord` 模型 (`business_record.dart`)

**新增字段**:
```dart
final String? toProjectName;  // 目的项目名称（可选）
```

**修改内容**:
- 构造函数添加 `toProjectName` 参数
- `props` 列表添加 `toProjectName`
- `copyWith` 方法添加 `toProjectName` 参数

#### b) `BusinessRecordItem` 包装类 (`record_item.dart`)

**新增getter**:
```dart
String? get toProjectName => _record.toProjectName;
```

### 2. UI层优化

#### `RecordListItem` 组件 (`record_list_item.dart`)

**主要改动**:

##### a) 重构 `_buildHeader` 方法

原先的实现方式：
- 所有类型统一使用简单的字符串拼接
- "工程名称"标签和值混在一起，无法区分

新的实现方式：
- **TodoRecordItem**: 保持原样，显示"任务名称"
- **BusinessRecordItem**: 使用新的项目信息展示方式
  - 显示"所在项目"（而不是"工程名称"）
  - 如果有`toProjectName`，额外显示"目的项目"

##### b) 新增 `_buildProjectInfo` 方法

创建统一的项目信息展示组件，特点：

**样式层次**:
```
[小字灰色]所在项目：[大字黑色粗体]某某项目  [更小灰色](项目编号)
```

**实现细节**:
- 使用 `RichText` 实现多样式文本
- **标签部分**（如"所在项目："）：
  - 字号: 13
  - 颜色: `Colors.grey[600]`
  - 字重: `FontWeight.w400`（正常）
  
- **项目名称部分**：
  - 字号: 16
  - 颜色: `Colors.black87`
  - 字重: `FontWeight.w600`（加粗）
  
- **项目编号部分**（可选，带括号）：
  - 字号: 12
  - 颜色: `Colors.grey[500]`
  - 字重: `FontWeight.w400`（正常）

**参数设计**:
```dart
Widget _buildProjectInfo(
  String label,          // 标签文本，如"所在项目"、"目的项目"
  String? projectName,   // 项目名称
  String? projectCode    // 项目编号（可选）
)
```

### 3. 展示逻辑

#### 普通业务记录（非dispatch）
```
┌─────────────────────────────────────┐
│ 所在项目：金水区郑州水务项目 (PJ001) │
│                                     │
│ [验收记录]              [已完成]    │
│                                     │
│ 🕐 发起时间：2025-10-10 09:30  👤   │
└─────────────────────────────────────┘
```

#### Dispatch（调拨）类型记录
```
┌─────────────────────────────────────┐
│ 所在项目：金水区郑州水务项目 (PJ001) │
│ 目的项目：中原区智慧水务项目         │
│                                     │
│ [调拨记录]              [已完成]    │
│                                     │
│ 🕐 发起时间：2025-10-10 09:30  👤   │
└─────────────────────────────────────┘
```

## 设计亮点

### 1. 视觉层次清晰
- **标签**: 小字、灰色，不抢眼
- **内容**: 大字、黑色、加粗，信息主体
- **辅助信息**: 最小字、浅灰色，括号包裹

### 2. 信息密度适中
- 标签和内容在同一行，节省空间
- 项目编号用括号包裹，紧凑但易读
- 目的项目另起一行，保持清晰

### 3. 灵活性强
- `_buildProjectInfo` 方法可复用于不同类型的项目信息
- 项目编号为可选参数，适应不同数据结构
- 目的项目仅在有数据时显示，不影响其他类型

### 4. 一致性好
- 所有项目信息使用相同的展示风格
- 与其他UI元素（时间、人员等）的样式保持协调

## 数据流

```
API Response
  ↓
BusinessRecord {
  projectName: "金水区郑州水务项目",
  projectCode: "PJ001",
  toProjectName: "中原区智慧水务项目"  // dispatch类型才有
}
  ↓
BusinessRecordItem (包装)
  ↓
RecordListItem (UI渲染)
  ↓
展示结果：
- 所在项目：金水区郑州水务项目 (PJ001)
- 目的项目：中原区智慧水务项目  // 仅dispatch显示
```

## 兼容性

### 向后兼容
- `toProjectName` 是可选字段，旧数据不受影响
- 只在有值时才显示目的项目，不会出现空白或null
- 其他业务类型完全不受影响

### 空值处理
- `projectName` 为 null 时显示 `-`
- `projectCode` 为 null 或空字符串时不显示括号部分
- `toProjectName` 为 null 或空字符串时完全不显示该行

## 测试要点

- [ ] Dispatch类型记录正确显示目的项目
- [ ] 非dispatch类型不显示目的项目
- [ ] 项目名称和编号的样式层次清晰可辨
- [ ] 长项目名称正确换行和截断
- [ ] 空值情况下的显示正确
- [ ] TodoRecordItem不受影响
- [ ] InventoryRecordItem（使用专用组件）不受影响

## 后续优化建议

1. **图标辅助**: 可以为"所在项目"和"目的项目"添加不同的图标，如 `location_on` 和 `arrow_forward`
2. **交互增强**: 点击项目名称可以跳转到项目详情页
3. **状态标识**: 调拨状态可以用颜色或图标标识（如待确认、已接收等）
4. **路径可视化**: 可以用箭头或流程图标连接所在项目和目的项目

## 代码质量

- ✅ 类型安全：使用 `is` 检查和类型转换
- ✅ 空安全：所有可选字段都有空值检查
- ✅ 可维护性：抽取 `_buildProjectInfo` 方法提高复用性
- ✅ 可读性：使用 `RichText` 而不是嵌套 `Row`/`Text`，代码更简洁
- ✅ 性能：`RichText` 在文本样式混合场景下比嵌套widget更高效
