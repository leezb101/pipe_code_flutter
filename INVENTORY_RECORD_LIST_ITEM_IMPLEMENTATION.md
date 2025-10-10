# 盘点任务列表项组件实现说明

## 问题背景

在 `records_list_page.dart` 中，盘点任务（`builderInventory` 类型）使用通用的 `RecordListItem` 组件展示时出现了不合理的空值显示。这是因为：

1. `InventoryRecordItem` 的数据模型中 `projectName` 和 `projectCode` 都是 `null`（盘点任务不关联具体项目）
2. 盘点任务有特有的 `materialNum`（耗材数量）字段需要突出展示
3. 通用组件的布局不适合盘点任务的特殊数据结构

## 解决方案

### 1. 创建专用组件 `InventoryRecordListItem`

**文件位置**: `lib/widgets/inventory_record_list_item.dart`

**核心特性**:
- 专门为 `InventoryRecordItem` 设计的列表项组件
- 不显示项目名称和项目编号（因为盘点任务不关联项目）
- 突出显示耗材数量（`materialNum`）
- 使用紫色主题标识盘点任务类型
- 使用橙色背景突出显示耗材信息

**布局结构**:
```
┌─────────────────────────────────────────┐
│ 任务名称                    [盘点任务]   │
│                                         │
│ ┌────────────────────────────────────┐  │
│ │ 🏷️ 耗材数量：10 种                 │  │
│ └────────────────────────────────────┘  │
│                                         │
│ 🕐 创建时间：2025-10-10 10:30  👤 张三   │
└─────────────────────────────────────────┘
```

**主要组成部分**:

#### a) Header 部分
- 左侧：任务名称（大字加粗）
- 右侧：紫色圆角标签显示"盘点任务"，带图标

#### b) 耗材信息部分
- 橙色背景的独立区块
- 显示耗材数量，数字加粗突出显示
- 使用分类图标标识

#### c) Footer 部分
- 左侧：创建时间
- 右侧：
  - 如果已分配用户，显示用户名
  - 如果未分配，显示灰色"未分配"标签

### 2. 修改 `records_list_page.dart`

**改动内容**:

1. **导入新组件**:
```dart
import '../../widgets/inventory_record_list_item.dart';
```

2. **根据类型选择组件**:
```dart
itemBuilder: (context, index) {
  // ... 
  final record = records[index];
  
  // 盘点任务使用专用的列表项组件
  if (record is InventoryRecordItem) {
    return InventoryRecordListItem(
      record: record,
      onTap: () => _onRecordTap(context, record),
    );
  }
  
  // 其他类型使用通用的列表项组件
  return RecordListItem(
    record: record,
    onTap: () => _onRecordTap(context, record),
  );
}
```

## 设计亮点

### 1. 视觉区分
- **紫色主题**: 盘点任务标签使用紫色，与其他业务类型（蓝色、橙色）区分
- **图标辅助**: 使用库存盒子图标（`inventory_2_outlined`）增强识别度

### 2. 信息层次
- **一级信息**: 任务名称 + 类型标签
- **二级信息**: 耗材数量（重要信息，独立区块突出）
- **三级信息**: 时间和人员信息

### 3. 用户体验
- 耗材数量使用大号粗体，方便快速扫描
- 未分配状态使用灰色标签明确标识
- 保持与其他列表项一致的交互体验（点击跳转）

## 数据模型对应

| UI 元素  | 数据来源                         | 说明                                      |
|----------|----------------------------------|-------------------------------------------|
| 任务名称 | `record.businessTypeDescription` | 来自 `inventory.name ?? '盘点任务'`       |
| 耗材数量 | `record.materialNum`             | 来自 `inventory.materialNum`              |
| 创建时间 | `record.doTime`                  | 来自 `inventory.createdTime`              |
| 用户名   | `record.userName`                | 来自 `inventory.bindUserName ?? '未分配'` |

## 后续优化建议

1. **状态标识**: 可以考虑添加盘点状态（待盘点、已盘点等）的视觉标识
2. **完成度指示**: 可以显示盘点进度（如已盘点/总数）
3. **仓库信息**: 如果需要，可以添加仓库名称显示
4. **主题定制**: 可以根据盘点状态使用不同的颜色主题

## 测试要点

- [ ] 盘点任务列表正确使用新组件
- [ ] 已分配和未分配状态正确显示
- [ ] 耗材数量显示正确
- [ ] 点击跳转到详情页功能正常
- [ ] 与其他类型列表项混合显示时布局正常
