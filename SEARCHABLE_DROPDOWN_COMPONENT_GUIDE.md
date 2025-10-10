# SearchableDropdown 公共组件使用指南

## 概述

`SearchableDropdown` 是一个可搜索下拉组件，类似 Element UI 的 `el-select`。支持输入过滤、防抖搜索、点击外部关闭等功能。

## 功能特性

- ✅ 单一输入框，点击展开下拉列表
- ✅ 600ms 防抖搜索（rxDart）
- ✅ 实时过滤搜索文本
- ✅ 点击外部区域自动关闭
- ✅ 页面导航时自动清理
- ✅ 支持自定义项显示和选中项显示
- ✅ 支持错误消息显示

## 文件位置

```
lib/widgets/searchable_dropdown.dart
```

## 基本用法

### 1. 简单文本下拉

```dart
SearchableDropdown<ProjectSimpleVo>(
  label: '目标项目',
  value: _selectedProject,
  items: state.availableProjects,
  onChanged: (value) {
    setState(() {
      _selectedProject = value;
    });
  },
  itemBuilder: (item) => Text(item.name),
  businessType: 'dispatch',
  getSearchText: (item) => item.name,
)
```

### 2. 仓库下拉（带标识）

```dart
SearchableDropdown<WarehouseVO>(
  label: '接收仓库',
  value: _selectedWarehouse,
  items: state.availableWarehouses,
  onChanged: (value) {
    setState(() {
      _selectedWarehouse = value;
    });
  },
  itemBuilder: (item) => buildWarehouseItemWidget(item),
  selectedLabelBuilder: (item) => '${item.name} - ${item.address}',
  businessType: 'dispatch',
  getSearchText: (item) => '${item.name} ${item.address}',
)
```

## API 参数

### 必需参数

| 参数            | 类型                 | 说明                 |
|-----------------|----------------------|----------------------|
| `label`         | `String`             | 下拉框标签文字       |
| `value`         | `T?`                 | 当前选中的值         |
| `items`         | `List<T>`            | 下拉选项列表         |
| `onChanged`     | `ValueChanged<T?>`   | 选中项变化回调       |
| `itemBuilder`   | `Widget Function(T)` | 下拉项显示构建器     |
| `businessType`  | `String`             | 业务类型（用于主题色） |
| `getSearchText` | `String Function(T)` | 获取搜索文本函数     |

### 可选参数

| 参数                   | 类型                  | 说明                                       |
|------------------------|-----------------------|--------------------------------------------|
| `selectedLabelBuilder` | `String Function(T)?` | 选中项显示文本（不设置则使用 getSearchText） |
| `errorMessage`         | `String?`             | 错误消息（显示时替换整个组件）               |

## 仓库项显示组件

使用 `buildWarehouseItemWidget()` 函数显示仓库信息和类型标识：

```dart
Widget buildWarehouseItemWidget(WarehouseVO warehouse)
```

显示内容：
- 仓库名称和地址
- **独立仓库**：蓝色背景标签
- **项目现场**：灰色背景标签

## 搜索行为

### 防抖机制

- 使用 rxDart 的 `BehaviorSubject` + `debounceTime`
- 600ms 防抖延迟
- 避免频繁过滤导致性能问题

### 搜索逻辑

```dart
getSearchText: (item) => '${item.name} ${item.address}'
```

可同时搜索多个字段，返回包含搜索关键词的项。

## 生命周期管理

### 自动清理

组件会在以下情况自动清理资源：

1. **页面导航时**：`deactivate()` 关闭浮层
2. **组件销毁时**：`dispose()` 清理监听器和资源

### 外部点击检测

使用 `GestureDetector` + `HitTestBehavior.translucent` 实现：
- 点击外部区域：关闭下拉框
- 点击下拉列表内部：不关闭

## 应用示例

### dispatch_application_page.dart

```dart
// 项目下拉
_buildDropdownRow<ProjectSimpleVo>(
  label: '目标项目:',
  value: _selectedTargetProject,
  items: state.availableProjects,
  onChanged: (value) {
    setState(() {
      _selectedTargetProject = value;
    });
  },
  itemBuilder: (item) => Text(item.name),
  getSearchText: (item) => item.name,
)

// 仓库下拉（带标识）
_buildDropdownRow<WarehouseVO>(
  label: '接收仓库:',
  value: _selectedTargetWarehouse,
  items: state.availableWarehouses,
  onChanged: (value) {
    if (value != null) {
      context.read<DispatchBloc>().add(
        UpdateWarehouseUsersList(warehouseId: value.id),
      );
    }
    setState(() {
      _selectedTargetWarehouse = value;
    });
  },
  itemBuilder: (item) => buildWarehouseItemWidget(item),
  selectedLabelBuilder: (item) => '${item.name} - ${item.address}',
  getSearchText: (item) => '${item.name} ${item.address}',
)
```

### acceptance_page.dart

```dart
SearchableDropdown<WarehouseVO>(
  label: '选择已有仓库',
  value: selectedWarehouse,
  items: _warehouseList,
  onChanged: (WarehouseVO? warehouse) {
    if (warehouse != null) {
      setState(() {
        _selectedWarehouseId = warehouse.id;
      });
      
      context.read<AcceptanceBloc>().add(
        LoadWarehouseUsers(
          warehouseId: warehouse.id,
          tracingContext: context.createActionContext('切换仓库并加载用户'),
        ),
      );
    }
  },
  itemBuilder: (warehouse) => buildWarehouseItemWidget(warehouse),
  selectedLabelBuilder: (warehouse) => '${warehouse.name} - ${warehouse.address}',
  businessType: 'acceptance',
  getSearchText: (warehouse) => '${warehouse.name} ${warehouse.address}',
)
```

## 主题适配

组件会根据 `businessType` 参数自动应用对应的业务主题色：

```dart
AppTheme.getBusinessColor(widget.businessType)
```

支持的业务类型：
- `dispatch`：调拨（紫色系）
- `acceptance`：验收（绿色系）
- 其他自定义类型

## 注意事项

1. **泛型类型**：必须指定具体类型 `SearchableDropdown<T>`
2. **搜索字段**：`getSearchText` 返回的文本会进行小写匹配
3. **选中显示**：`selectedLabelBuilder` 可以自定义选中后的显示文本
4. **错误状态**：设置 `errorMessage` 时，整个组件会替换为错误提示
5. **仓库显示**：使用 `buildWarehouseItemWidget()` 时会自动显示仓库类型标识

## 依赖

```yaml
dependencies:
  rxdart: ^0.x.x  # 用于防抖搜索
```

## 相关文档

- [DISPATCH_SEARCHABLE_DROPDOWN_IMPLEMENTATION.md](../DISPATCH_SEARCHABLE_DROPDOWN_IMPLEMENTATION.md) - 调拨页实现文档
- [unified_ui.dart](./unified/unified_ui.dart) - 统一主题配置
- [warehouse_vo.dart](../models/common/warehouse_vo.dart) - 仓库数据模型
