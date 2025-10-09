# Badge 加载优化：解决数字跳闪问题

## 问题描述

### 现象
在首次进入应用时，MainPage 底部导航栏的"记录"badge 数字会出现跳闪：
```
初始: 无 badge
↓
接口1返回: badge 显示 2
↓
接口2返回: badge 显示 3
↓
接口3返回: badge 显示 4
```

### 根本原因

`_preloadBadgeCounts` 方法中同时触发了多个异步加载事件：

```dart
void _preloadBadgeCounts(SessionState sessionState) {
  // 这些事件是并发执行的，返回时间不同
  context.read<RecordsBloc>().add(LoadRecords(RecordType.todo));        // 500ms
  context.read<RecordsBloc>().add(LoadRecords(RecordType.siteTodo));    // 800ms
  context.read<InventoryBloc>().add(InventoryTasksFetched());           // 1200ms
}
```

每次接口返回时，`BlocBuilder` 都会重建，导致 `_computeTodoBadgeCount` 被调用，badge 数字逐步累加显示。

## 解决方案对比

### ❌ 方案1：使用 Future.wait 等待所有接口

```dart
Future<void> _preloadBadgeCounts() async {
  await Future.wait([
    // 等待所有接口完成
  ]);
}
```

**缺点**：
- 阻塞 UI 初始化，首屏加载时间变长
- 如果某个接口慢，会拖累整体速度
- 违背了 BLoC 的事件驱动设计理念

### ❌ 方案2：防抖/节流

```dart
Timer? _badgeUpdateTimer;
void _scheduleBadgeUpdate() {
  _badgeUpdateTimer?.cancel();
  _badgeUpdateTimer = Timer(Duration(milliseconds: 500), () {
    // 更新 badge
  });
}
```

**缺点**：
- 延迟显示，用户可能觉得响应慢
- 如果接口很慢，仍然会有跳闪
- 增加了不必要的复杂度

### ✅ 方案3：检查数据完整性（推荐）

**核心思想**：只有当**所有必需的数据**都加载完成时，才显示 badge。

**优点**：
- ✅ 完全消除跳闪
- ✅ 不阻塞 UI 渲染
- ✅ 符合响应式编程理念
- ✅ 实现简单，代码清晰

## 实现细节

### 1. 添加状态标志

```dart
class _MainPageState extends State<MainPage> {
  bool _isBadgeDataReady = false; // 追踪 badge 数据是否准备好
  // ...
}
```

### 2. 修改 `_computeTodoBadgeCount` 方法

```dart
int _computeTodoBadgeCount(
  RecordsState recordsState,
  SessionState sessionState,
  InventoryState inventoryState,
) {
  bool allDataReady = true; // 🎯 关键：追踪所有数据是否准备好
  int totalCount = 0;
  
  try {
    final repo = getIt<RecordsRepository>();
    
    // 1. 检查 todo 数据
    final todoMeta = repo.getCachedMeta(RecordType.todo, ...);
    if (todoMeta == null) {
      allDataReady = false; // ❌ 数据还未加载
    } else {
      totalCount += todoMeta.total; // ✅ 数据已加载
    }
    
    // 2. 检查其他数据源（根据角色）
    if (isStorekeeper) {
      final whMeta = repo.getCachedMeta(RecordType.warehouseTodo, ...);
      if (whMeta == null) {
        allDataReady = false;
      } else {
        totalCount += whMeta.total;
      }
    }
    
    // 3. 检查 InventoryBloc 状态
    if (isBuilder) {
      if (inventoryState.listStatus == DataStatus.initial ||
          inventoryState.listStatus == DataStatus.loading) {
        allDataReady = false; // ❌ 还在加载中
      } else {
        totalCount += inventoryState.totalTasks; // ✅ 加载完成
      }
    }
  } catch (_) {
    allDataReady = false;
  }
  
  // 🎯 核心逻辑：只有当所有数据都准备好时才返回总数
  if (!allDataReady) {
    return 0; // 返回 0，不显示 badge
  }
  
  return totalCount; // 返回总数，显示 badge
}
```

### 3. 在 UI 中的效果

```dart
List<BottomNavigationBarItem> _buildNavItemsWithBadge(int todoCount, bool isAdmin) {
  return [
    // ...
    BottomNavigationBarItem(
      icon: Stack(
        children: [
          Icon(Icons.list_alt_outlined),
          // 🎯 只有当 todoCount > 0 时才显示 badge
          // 当数据未完全加载时，todoCount = 0，不显示
          if (todoCount > 0)
            Positioned(..., child: _Badge(count: todoCount)),
        ],
      ),
      label: '记录',
    ),
  ];
}
```

## 执行流程图

```
┌─────────────────────────────────────────────────────────────┐
│ 1. 用户登录，进入 MainPage                                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. _preloadBadgeCounts 并发触发 3 个加载事件                │
│    - LoadRecords(todo)                                      │
│    - LoadRecords(siteTodo)                                  │
│    - InventoryTasksFetched()                                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. BlocBuilder 监听状态变化                                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. 接口1返回 (500ms)                                        │
│    → _computeTodoBadgeCount 被调用                          │
│    → 检查: todoMeta ✅, siteTodoMeta ❌, inventory ❌       │
│    → allDataReady = false                                   │
│    → 返回 0，不显示 badge                                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. 接口2返回 (800ms)                                        │
│    → _computeTodoBadgeCount 被调用                          │
│    → 检查: todoMeta ✅, siteTodoMeta ✅, inventory ❌       │
│    → allDataReady = false                                   │
│    → 返回 0，不显示 badge                                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. 接口3返回 (1200ms)                                       │
│    → _computeTodoBadgeCount 被调用                          │
│    → 检查: todoMeta ✅, siteTodoMeta ✅, inventory ✅       │
│    → allDataReady = true                                    │
│    → 返回 4，显示 badge                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 7. 用户看到的效果：badge 一次性显示为 4                     │
│    ✅ 无跳闪！                                              │
└─────────────────────────────────────────────────────────────┘
```

## 性能影响分析

### 对应用性能的影响

#### ✅ 正面影响
1. **减少不必要的 UI 重建**：
   - 虽然 `_computeTodoBadgeCount` 仍然会被多次调用，但返回的都是 0
   - UI 不会重新渲染 badge（因为一直是隐藏状态）
   - 只有最后一次才会触发 badge 的显示动画

2. **改善用户体验**：
   - 消除了数字跳跃带来的视觉干扰
   - 用户看到的是稳定、专业的界面

3. **不阻塞主线程**：
   - 接口调用仍然是并发的，充分利用了异步优势
   - 不会延长首屏加载时间

#### 📊 性能开销
1. **轻微的计算开销**：
   - 每次 BLoC 状态变化时都会执行 `_computeTodoBadgeCount`
   - 增加了数据完整性检查（null 判断、状态判断）
   - **评估**：可忽略，因为这些都是简单的条件判断

2. **内存开销**：
   - 增加了一个 `bool` 类型的状态变量 `_isBadgeDataReady`
   - **评估**：可忽略（< 1 字节）

### 对稳定性的影响

#### ✅ 提升稳定性
1. **更严格的数据验证**：
   - 通过检查 `meta == null`，避免了使用未加载的数据
   - 减少了因数据不完整导致的错误

2. **更清晰的状态管理**：
   - `_isBadgeDataReady` 标志让状态更加明确
   - 便于调试和追踪 badge 显示逻辑

3. **异常处理**：
   - try-catch 块捕获所有异常
   - 即使某个接口失败，也不会导致 badge 显示错误数据

#### ⚠️ 潜在风险
1. **如果某个接口一直失败**：
   - Badge 会一直不显示
   - **缓解措施**：RecordsBloc 有重试机制，用户可以下拉刷新

2. **如果网络很慢**：
   - Badge 显示会延迟
   - **缓解措施**：这比显示错误的跳闪数字要好

## 测试建议

### 1. 正常场景
- 正常网络环境下，badge 应该在所有接口返回后一次性显示
- 数字应该准确（不会出现中间状态）

### 2. 慢速网络
- 在 DevTools 中模拟慢速 3G 网络
- 验证 badge 在所有数据加载完成前不显示
- 加载完成后 badge 一次性显示正确数字

### 3. 接口失败场景
- 模拟某个接口返回错误
- 验证 badge 不会显示（因为数据不完整）
- 用户刷新后应该能正常显示

### 4. 不同角色
- **builder**: 需要等待 3 个接口（todo, siteTodo, inventory）
- **laborer**: 需要等待 2 个接口（todo, siteTodo）
- **storekeeper**: 需要等待 2 个接口（todo, warehouseTodo）

### 5. 快速切换场景
- 快速切换项目或角色
- 验证 badge 能正确响应新的数据状态

## 优化建议

### 可选的进一步优化

#### 1. 添加 Loading 指示器（可选）

如果希望给用户更明确的加载反馈：

```dart
// 在 badge 位置显示小的 loading 指示器
if (todoCount == 0 && !_isBadgeDataReady)
  Positioned(
    right: -6,
    top: -3,
    child: SizedBox(
      width: 12,
      height: 12,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  ),
```

#### 2. 添加超时机制（可选）

如果接口非常慢，可以添加超时显示：

```dart
// 在 _preloadBadgeCounts 中
Timer(Duration(seconds: 5), () {
  if (!_isBadgeDataReady && mounted) {
    // 超时后强制显示当前已加载的数据
    setState(() {
      _isBadgeDataReady = true;
    });
  }
});
```

#### 3. 使用骨架屏（可选）

在首次加载时显示骨架屏动画，让用户知道内容正在加载。

## 总结

### ✅ 优点
- 彻底解决了 badge 数字跳闪问题
- 不影响应用性能（计算开销可忽略）
- 提升了用户体验和界面稳定性
- 代码实现简洁，易于维护

### 📊 性能影响
- **CPU**: 可忽略（增加了简单的 null 检查）
- **内存**: 可忽略（一个 bool 变量）
- **网络**: 无影响（接口调用方式不变）
- **用户体验**: 显著提升（无跳闪）

### 🎯 推荐
**强烈推荐使用此方案**，它在性能和用户体验之间取得了最佳平衡。

## 相关文档
- [MainPage Badge 优化](./MAIN_PAGE_BADGE_OPTIMIZATION.md)
- [RecordsListPage Tab Badges](./RECORDS_LIST_PAGE_TAB_BADGES.md)
- [Builder Inventory 集成](./BUILDER_INVENTORY_INTEGRATION_SUMMARY.md)
