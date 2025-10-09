# RecordsListPage Tab Badges 实现总结

## 概述
为 `RecordsListPage` 的顶部分类 tab 添加了 badge 数量显示功能，只在 `todo`、`siteTodo`、`builderInventory`、`warehouseTodo` 这四个标签上显示数量徽章。

## 实现的功能

### 1. 修改 `ScrollableTabBar` Widget

**文件**: `lib/widgets/scrollable_tab_bar.dart`

#### 添加 `badgeCounts` 参数

```dart
class ScrollableTabBar extends StatefulWidget {
  final RecordType selectedTab;
  final Function(RecordType) onTabSelected;
  final List<RecordType> allTabs;
  final Map<RecordType, int>? badgeCounts; // 🎯 新增：可选的 badge 数量映射

  const ScrollableTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.allTabs,
    this.badgeCounts, // 可选参数
  });
```

#### 修改 `_buildTabChip` 方法

在每个 tab chip 上显示 badge：

```dart
Widget _buildTabChip(BuildContext context, RecordType recordType) {
  final isSelected = widget.selectedTab == recordType;
  final badgeCount = widget.badgeCounts?[recordType];
  final hasBadge = badgeCount != null && badgeCount > 0;

  return GestureDetector(
    onTap: () => widget.onTabSelected(recordType),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            recordType.displayName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (hasBadge) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                // 🎨 选中时badge为白底主色字，未选中时为红底白字
                color: isSelected ? Colors.white : Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 18),
              child: Center(
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
```

**视觉效果**：
- 未选中的 tab：红色 badge，白色文字
- 选中的 tab：白色 badge，主题色文字
- 超过 99 显示为 "99+"

### 2. 修改 `RecordsListPage`

**文件**: `lib/pages/records/records_list_page.dart`

#### 添加必要的导入

```dart
import 'package:pipe_code_flutter/config/service_locator.dart';
import '../../repositories/interfaces/records_repository.dart';
```

#### 修改 TabBar 的 BlocBuilder

使用嵌套的 `BlocBuilder` 同时监听 `InventoryBloc` 和 `RecordsBloc`：

```dart
BlocBuilder<InventoryBloc, InventoryState>(
  builder: (context, inventoryState) {
    return BlocBuilder<RecordsBloc, RecordsState>(
      builder: (context, recordsState) {
        // 获取当前选中的 tab
        RecordType currentTab = _initialTab;
        if (recordsState is RecordsInitial) {
          currentTab = recordsState.currentTab;
        } else if (recordsState is RecordsLoading) {
          currentTab = recordsState.currentTab;
        } else if (recordsState is RecordsLoaded) {
          currentTab = recordsState.currentTab;
        } else if (recordsState is RecordsError) {
          currentTab = recordsState.currentTab;
        } else if (recordsState is RecordsEmpty) {
          currentTab = recordsState.currentTab;
        }
        
        // 🎯 计算每个 tab 的 badge 数量
        final badgeCounts = _computeTabBadgeCounts(
          sessionState,
          inventoryState,
        );
        
        return ScrollableTabBar(
          selectedTab: currentTab,
          onTabSelected: _onTabSelected,
          allTabs: _allTabs,
          badgeCounts: badgeCounts, // 传递 badge 数量
        );
      },
    );
  },
),
```

#### 添加 `_computeTabBadgeCounts` 方法

```dart
/// 计算需要显示 badge 的 tab 的数量
/// 只计算 todo、siteTodo、builderInventory、warehouseTodo
Map<RecordType, int> _computeTabBadgeCounts(
  SessionState sessionState,
  InventoryState inventoryState,
) {
  final badgeCounts = <RecordType, int>{};
  final ids = _resolveIds(sessionState);
  final int? uid = ids.$1;
  final int? pid = ids.$2;

  try {
    final repo = getIt<RecordsRepository>();

    // 1. todo（所有角色都有）
    final todoMeta = repo.getCachedMeta(
      RecordType.todo,
      userId: uid,
      projectId: pid,
    );
    final todoCount = todoMeta?.total ?? 0;
    if (todoCount > 0) {
      badgeCounts[RecordType.todo] = todoCount;
    }

    // 2. warehouseTodo（仓管员）
    if (sessionState is SessionStorekeeperEstablished) {
      final whMeta = repo.getCachedMeta(
        RecordType.warehouseTodo,
        userId: uid,
        projectId: pid,
      );
      final whCount = whMeta?.total ?? 0;
      if (whCount > 0) {
        badgeCounts[RecordType.warehouseTodo] = whCount;
      }
    }

    // 3. siteTodo（builder、builderSub、laborer）
    if (sessionState is SessionProjectEstablished) {
      final role = sessionState.currentUserRoleInfo.projectRoleType;
      if (role == UserRole.builder ||
          role == UserRole.builderSub ||
          role == UserRole.laborer) {
        final siteTodoMeta = repo.getCachedMeta(
          RecordType.siteTodo,
          userId: uid,
          projectId: pid,
        );
        final siteTodoCount = siteTodoMeta?.total ?? 0;
        if (siteTodoCount > 0) {
          badgeCounts[RecordType.siteTodo] = siteTodoCount;
        }
      }

      // 4. builderInventory（builder、builderSub）
      if (role == UserRole.builder || role == UserRole.builderSub) {
        final inventoryCount = inventoryState.totalTasks;
        if (inventoryCount > 0) {
          badgeCounts[RecordType.builderInventory] = inventoryCount;
        }
      }
    }
  } catch (_) {
    // ignore cache failures
  }

  return badgeCounts;
}
```

## 核心设计理念

### 1. 响应式更新

通过嵌套 `BlocBuilder` 监听两个 BLoC 的状态变化：
- `InventoryBloc`: 提供 `builderInventory` 的 `totalTasks`
- `RecordsBloc`: 触发 UI 重建（虽然不直接使用其状态）

当任何一个 BLoC 的状态更新时，badge 数量会自动刷新。

### 2. 数据来源一致性

- **RecordsBloc 相关的 tab**: 使用 `RecordsRepository.getCachedMeta().total`
- **InventoryBloc 相关的 tab**: 使用 `InventoryState.totalTasks`

**重要**：必须使用 `getIt<RecordsRepository>()` 而不是 `context.read<RecordsBloc>()`，因为 repository 是 BLoC 的私有成员。

### 3. 角色过滤

根据用户角色只显示相关的 badge：

| 角色 | 显示的 badge |
|------|-------------|
| **仓管员** (SessionStorekeeperEstablished) | `todo`, `warehouseTodo` |
| **builder/builderSub** | `todo`, `siteTodo`, `builderInventory` |
| **laborer** | `todo`, `siteTodo` |
| **其他** | `todo` |

### 4. 性能优化

- 只在数量大于 0 时添加到 `badgeCounts` Map
- 使用 try-catch 避免缓存失败导致的错误
- badge 计算在 BlocBuilder 内部，只在状态变化时重新计算

## 与 MainPage Badge 的对比

| 特性 | MainPage Badge | RecordsListPage Tab Badges |
|------|----------------|---------------------------|
| **位置** | 底部导航栏"记录"项 | 顶部分类 tab |
| **显示数量** | 总和（所有待办类型） | 每个 tab 独立显示 |
| **数据来源** | 统一使用缓存的 meta.total | 同样使用缓存的 meta.total |
| **响应式** | 嵌套 BlocBuilder | 嵌套 BlocBuilder |
| **预加载** | MainPage 预加载 | 复用 MainPage 的预加载结果 |

## 测试建议

### 1. 角色测试

- **builder 账号**：
  - 应显示 `todo`、`siteTodo`、`builderInventory` 三个 badge
  - 切换 tab 时 badge 保持显示
  - 完成任务后刷新，badge 数字减少

- **laborer 账号**：
  - 应显示 `todo`、`siteTodo` 两个 badge
  - 不应显示 `builderInventory` badge

- **storekeeper 账号**：
  - 应显示 `todo`、`warehouseTodo` 两个 badge
  - 不应显示 `siteTodo` 或 `builderInventory` badge

### 2. 视觉测试

- 未选中的 tab：红色圆角 badge，白色数字
- 选中的 tab：白色圆角 badge，主题色数字
- Badge 应该紧贴 tab 名称右侧，间距 6px
- 超过 99 的数量显示为 "99+"

### 3. 数据一致性测试

- MainPage 底部导航栏的总数 = RecordsListPage 各个 tab 的 badge 之和
- 刷新任意 tab 后，badge 数字立即更新
- 切换用户或项目后，badge 根据新角色显示

## 相关文档

- [MainPage Badge 优化](./MAIN_PAGE_BADGE_OPTIMIZATION.md)
- [Builder Inventory 集成](./BUILDER_INVENTORY_INTEGRATION_SUMMARY.md)

## 注意事项

1. **不要直接访问 BLoC 的私有成员**：使用 `getIt<RecordsRepository>()` 而不是尝试访问 `RecordsBloc._repository`
2. **确保预加载已执行**：RecordsListPage 的 badge 依赖 MainPage 的预加载逻辑，确保用户先经过 MainPage
3. **异常处理**：所有缓存读取都包裹在 try-catch 中，避免崩溃
4. **可选参数**：`ScrollableTabBar.badgeCounts` 是可选的，向后兼容

## 总结

此实现成功地为 RecordsListPage 的顶部 tab 添加了响应式的 badge 显示功能，与 MainPage 的 badge 使用相同的数据源，确保了数据一致性。用户现在可以在两个位置看到待办任务的数量：
1. **MainPage 底部导航栏**：总数
2. **RecordsListPage 顶部 tab**：各类型的独立数量

两处 badge 都会随着数据变化自动更新，提供了良好的用户体验。
