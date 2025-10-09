# Builder Inventory Tab 集成总结

## 概述
为 `RecordsListPage` 中的 `builder` 和 `builderSub` 角色增加了"盘点任务"tab，该功能完全复用已有的 `InventoryBloc` 系列接口和逻辑，不在 `RecordsBloc` 和 `RecordsRepository` 中重复实现。

## 实现的变更

### 1. 创建 InventoryRecordItem 适配器 (`lib/models/records/record_item.dart`)

```dart
class InventoryRecordItem implements RecordItem {
  final InventoryListItemVO _inventory;

  InventoryRecordItem(this._inventory);

  @override
  int get id => _inventory.id;

  @override
  String? get projectName => null; // 盘点任务不关联具体项目

  @override
  String? get projectCode => null; // 盘点任务不关联具体项目

  @override
  String get userName => _inventory.bindUserName ?? '未分配';

  @override
  DateTime? get doTime => _inventory.createdTime;

  @override
  String get businessTypeDescription => _inventory.name ?? '盘点任务';

  InventoryListItemVO get inventory => _inventory;
  
  int get materialNum => _inventory.materialNum;
}
```

**作用**: 将 `InventoryListItemVO` 适配为 `RecordItem` 接口，使其可以在 `RecordsListPage` 的列表中统一显示。

### 2. 在 RecordsListPage 中添加 builderInventory Tab

**位置**: `lib/pages/records/records_list_page.dart` 的 `_setupTabsBySession` 方法

**变更内容**:
- 为 `builder` 和 `builderSub` 角色添加 `RecordType.builderInventory` tab
- 排除列表中自动添加 `builderInventory`，避免重复

```dart
// 只有 builder 和 builderSub 才显示盘点任务
if (sessionState.currentUserRoleInfo.projectRoleType == UserRole.builder ||
    sessionState.currentUserRoleInfo.projectRoleType == UserRole.builderSub) {
  tabs.add(RecordType.builderInventory);
}
```

### 3. 集成 InventoryBloc 到 RecordsListPage

**位置**: `lib/pages/records/records_list_page.dart`

**关键变更**:

#### a) 导入 InventoryBloc 相关类
```dart
import '../../bloc/inventory/inventory_bloc.dart';
import '../../bloc/inventory/inventory_state.dart';
import '../../bloc/inventory/inventory_event.dart';
```

#### b) 修改 `_buildContent()` 方法
当当前 tab 为 `builderInventory` 时，使用 `BlocBuilder<InventoryBloc, InventoryState>` 来渲染数据，而不是 `RecordsBloc`。

```dart
// 如果是盘点任务tab，使用InventoryBloc的数据
if (currentTab == RecordType.builderInventory) {
  return BlocBuilder<InventoryBloc, InventoryState>(
    builder: (context, inventoryState) {
      // 将 InventoryListItemVO 转换为 InventoryRecordItem
      final records = inventoryState.inventoryList
          .map((item) => InventoryRecordItem(item))
          .toList();
      // 渲染列表...
    },
  );
}
```

#### c) 修改 `_onTabSelected()` 方法
切换到 `builderInventory` tab 时触发 `InventoryBloc` 加载数据：

```dart
if (recordType == RecordType.builderInventory) {
  context.read<InventoryBloc>().add(const InventoryTasksFetched());
}
```

#### d) 修改 `_onRefresh()` 方法
刷新时根据当前 tab 选择刷新 `InventoryBloc` 或 `RecordsBloc`：

```dart
if (currentTab == RecordType.builderInventory) {
  context.read<InventoryBloc>().add(const InventoryTasksFetched(isRefresh: true));
  return;
}
```

#### e) 修改 `_onScroll()` 方法
支持 `builderInventory` tab 的分页加载：

```dart
if (currentTab == RecordType.builderInventory) {
  final inventoryBloc = context.read<InventoryBloc>();
  if (!inventoryState.hasReachedMax && inventoryState.listStatus != DataStatus.loading) {
    inventoryBloc.add(const InventoryTasksFetched());
  }
  return;
}
```

#### f) 修改初始化逻辑
如果初始 tab 是 `builderInventory`，直接加载 `InventoryBloc` 数据：

```dart
if (_initialTab == RecordType.builderInventory) {
  context.read<InventoryBloc>().add(const InventoryTasksFetched(isRefresh: true));
} else {
  // 加载 RecordsBloc...
}
```

#### g) 修改 `_onRecordTap()` 方法
添加 `builderInventory` 的导航逻辑：

```dart
case RecordType.builderInventory:
  context.goNamed('inventory-apply', extra: record.id);
  break;
```

### 4. 更新 RecordsRepository

**位置**: `lib/repositories/implementations/records_repository_impl.dart`

**变更内容**: 在 `getRecordsWithMeta` 方法中，当 `recordType` 为 `builderInventory` 时直接返回空数据，因为实际数据由 `InventoryBloc` 管理：

```dart
// builderInventory 由 InventoryBloc 处理，这里返回空数据
if (recordType == RecordType.builderInventory) {
  return const PagedRecords(
    records: [],
    meta: PageMeta(total: 0, size: 10, current: 1),
  );
}
```

## 架构设计要点

1. **职责分离**: `RecordsBloc` 和 `RecordsRepository` 不处理盘点业务逻辑，所有盘点相关的数据和状态管理由 `InventoryBloc` 负责。

2. **适配器模式**: 通过 `InventoryRecordItem` 适配器，将 `InventoryListItemVO` 转换为 `RecordItem` 接口，实现统一的列表渲染。

3. **条件分支**: 在 `RecordsListPage` 的各个关键方法中，根据当前 tab 是否为 `builderInventory` 来决定使用 `InventoryBloc` 还是 `RecordsBloc`。

4. **依赖注入**: `InventoryBloc` 已在 `main.dart` 的根组件中通过 `BlocProvider` 提供，`RecordsListPage` 通过 `context.read<InventoryBloc>()` 访问。

## 用户体验

- **builder** 和 **builderSub** 角色在 `RecordsListPage` 中可以看到"盘点任务"tab
- 点击该 tab 时自动加载盘点任务列表
- 支持下拉刷新和上拉加载更多
- 点击盘点任务记录可导航到盘点详情页
- 所有操作与现有的待办、出库等 tab 的交互体验一致

## 测试要点

1. 以 `builder` 或 `builderSub` 角色登录，验证"盘点任务"tab 是否显示
2. 切换到"盘点任务"tab，验证列表是否正确加载
3. 测试下拉刷新功能
4. 测试上拉加载更多功能（如果有多页数据）
5. 点击盘点任务记录，验证是否正确导航到详情页
6. 切换到其他角色（如 `laborer`），验证"盘点任务"tab 不显示

## 相关文件

- `lib/models/records/record_item.dart` - 添加 `InventoryRecordItem` 适配器
- `lib/pages/records/records_list_page.dart` - 集成 `InventoryBloc`
- `lib/repositories/implementations/records_repository_impl.dart` - 处理 `builderInventory` 特殊情况
- `lib/models/records/record_type.dart` - 已有 `builderInventory` 枚举值

## 未来优化建议

1. 如果盘点任务需要项目维度的过滤，可以在调用 `InventoryTasksFetched` 时传入项目 ID
2. 可以考虑为 `InventoryRecordItem` 添加更多业务属性的映射
3. 如果需要角标提示盘点任务数量，可以订阅 `InventoryBloc.state.totalTasks`
