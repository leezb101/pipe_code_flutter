# 盘点详情页面实现

## 功能概述

`inventory_detail_page.dart` 是一个只用于查看盘点详情的页面，基于现有的 `inventory_page.dart` 样式设计，但移除了所有编辑和提交功能。

## 🔧 最新优化（基于真实数据结构）

根据提供的真实数据结构，已对页面进行了以下优化：

### 1. 简化渲染逻辑
- **移除复杂计算属性**：不再依赖 `state.matchedMaterialIds` 等计算属性
- **直接使用详情数据**：直接从 `inventoryDetail` 读取 `materialRealNum`、`inWarehouse` 等字段
- **简化方法签名**：移除不必要的参数传递

### 2. 修正状态显示
- **状态映射更新**：
  - `0` = 待执行
  - `1` = 已执行 （修正：之前错误显示为"执行中"）
  - `2` = 已完成

### 3. 数据展示优化
- **盘点物料**：根据 `materialRealNum` 直接判断是否已盘点
- **盘盈物料**：只显示 `materialExtras` 中的数据
- **状态指示**：更准确的视觉反馈

## 主要功能

### 1. 任务信息展示
- 任务名称、负责人、执行人
- 物料数量 (`materialNum`) 和实际数量 (`realMaterialNum`)
- 盘点状态 (`status`) 和结果 (`passFlag`)
- 创建时间和执行时间
- 所属仓库

### 2. 盘点物料展示
- 显示所有待盘点物料 (`materials` 数组)
- 根据 `materialRealNum` 区分已盘点和未盘点
- 显示应盘数量和实盘数量的对比
- 显示物料是否在库 (`inWarehouse`)

### 3. 盘盈物料展示
- 显示已确认的盘盈物料 (`materialExtras` 数组)
- 清晰的盘盈标识和数量显示

### 4. 照片展示
- 显示已上传的盘点照片 (`attachmentUrl1`, `attachmentUrl2`)
- 支持网络图片加载和错误处理

## 数据结构示例

基于提供的真实数据：

```json
{
  "id": 3,
  "name": "英协路第二仓库定时盘点任务",
  "status": 1,  // 已执行
  "passFlag": false,  // 盘点异常
  "materials": [
    {
      "materialId": 42,
      "materialCode": "XT03C3312530022043",
      "materialName": "给水-GB/T 13295-2019...",
      "materialNum": 1,  // 应盘数量
      "materialRealNum": 0,  // 实盘数量
      "inWarehouse": false  // 不在库
    }
  ],
  "materialExtras": [
    {
      "materialId": 43,
      "materialCode": "XT03C3312530022044", 
      "materialName": "给水-GB/T 13295-2019...",
      "materialNum": 1,  // 盘盈数量
      "inWarehouse": true
    }
  ]
}
```

## 路由配置

```dart
GoRoute(
  path: '/inventory-detail',
  name: 'inventory-detail',
  builder: (context, state) {
    final taskId = int.tryParse(state.uri.queryParameters['id'] ?? '');
    return BlocProvider<InventoryBloc>(
      create: (context) => getIt<InventoryBloc>(),
      child: InventoryDetailPage(taskId: taskId),
    );
  },
),
```

## 导航方式

从记录列表页面导航：

```dart
context.goNamed(
  'inventory-detail',
  queryParameters: {'id': record.id.toString()},
);
```

## 核心改进

### 之前（复杂逻辑）
```dart
// 需要计算状态
final displayMatched = isMatched || isInventoried;
final isMatched = state.matchedMaterialIds.contains(material.materialId);
```

### 现在（直接读取）
```dart
// 直接使用数据
final isInventoried = (material.materialRealNum ?? 0) > 0;
```

## 状态管理

- **只读模式**：使用现有的 `InventoryBloc`，仅触发 `InventoryDetailFetched` 事件
- **数据驱动**：完全基于后端返回的 `inventoryDetail` 数据进行渲染
- **无副作用**：不修改任何状态，纯展示功能

## 视觉设计

1. **状态区分**：
   - 已盘点物料：绿色背景和勾选图标
   - 未盘点物料：灰色背景
   - 盘盈物料：蓝色背景和"盘盈"标签

2. **信息层次**：
   - 任务信息卡片
   - 盘点物料列表
   - 盘盈物料列表（如有）
   - 相关照片（如有）

3. **数据对比**：
   - 应盘 vs 实盘数量的颜色区分
   - 在库状态的明确标识
