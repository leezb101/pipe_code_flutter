# MainPage Badge 数量优化总结

## 概述
优化了 `MainPage` 底部导航栏"记录"tab 的 badge 数字显示逻辑，现在会根据用户角色智能地累加不同类型任务的数量，**独立于当前激活的 tab 状态**。

## 优化前的问题

### 第一版问题
之前的实现只统计了：
- 普通待办 (`todo`)
- 仓管待办 (`warehouseTodo`) - 仅仓管员身份

但 `RecordsListPage` 已经新增了：
- 现场待办 (`siteTodo`) - builder/builderSub/laborer 角色
- 盘点任务 (`builderInventory`) - builder/builderSub 角色

这导致 badge 数字不能准确反映用户实际的待办任务总数。

### 第二版问题（已修复）
第一次优化后，虽然能统计所有类型的任务，但存在一个严重问题：
- **依赖当前激活的 tab**：如果某个 tab 是当前激活的，使用其 state 数据；否则回退到缓存
- 这导致 badge 数字会随着用户切换 tab 而变化，用户体验不一致
- 例如：切换到"验收记录"tab 后，badge 只显示缓存的待办数量，而不是实时的总数

## 优化后的逻辑（最终版本）

### 核心设计理念

**独立性**：badge 数字的计算完全独立于 `RecordsListPage` 的当前激活 tab，直接使用服务端返回的 `total` 字段。

**预加载策略**：在用户进入会话状态时，立即预加载所有需要统计的列表的 meta 数据（只请求第一页的 1 条数据，获取 `total`）。

### 1. 添加导入依赖

```dart
import 'package:pipe_code_flutter/models/user/user_role.dart';
import '../bloc/inventory/inventory_bloc.dart';
import '../bloc/inventory/inventory_state.dart';
import '../bloc/inventory/inventory_event.dart';
import '../bloc/records/records_event.dart';
```

### 2. 新增 `_preloadBadgeCounts` 方法

在用户进入 `SessionProjectEstablished` 或 `SessionStorekeeperEstablished` 状态时调用，预加载所有需要的数据 meta：

```dart
void _preloadBadgeCounts(SessionState sessionState) {
  final ids = _resolveIds(sessionState);
  final int? uid = ids.$1;
  final int? pid = ids.$2;

  // 仓管员需要预加载仓库待办
  if (sessionState is SessionStorekeeperEstablished) {
    context.read<RecordsBloc>().add(
      LoadRecords(
        recordType: RecordType.warehouseTodo,
        userId: uid,
        projectId: pid,
        pageNum: 1,
        pageSize: 1, // 只需要获取 total，所以只请求 1 条数据
        tracingContext: TracingContext(...),
      ),
    );
  }

  // 施工方需要预加载 todo、siteTodo、builderInventory
  if (sessionState is SessionProjectEstablished) {
    final role = sessionState.currentUserRoleInfo.projectRoleType;
    
    // 所有项目参与方都需要 todo
    context.read<RecordsBloc>().add(LoadRecords(RecordType.todo, ...));

    // builder、builderSub、laborer 需要 siteTodo
    if (role == UserRole.builder || role == UserRole.builderSub || role == UserRole.laborer) {
      context.read<RecordsBloc>().add(LoadRecords(RecordType.siteTodo, ...));
    }

    // builder、builderSub 需要预加载盘点任务
    if (role == UserRole.builder || role == UserRole.builderSub) {
      context.read<InventoryBloc>().add(const InventoryTasksFetched(isRefresh: true));
    }
  }
}
```

**关键点**：
- 使用 `pageSize: 1` 最小化网络流量，只为了获取 `total` 字段
- 预加载会将数据缓存到 `RecordsRepository` 和 `InventoryBloc`
- 这些数据会同时被 `RecordsListPage` 复用
- **重要**：在 `BlocConsumer<SessionBloc>` 的 `listener` 和 `builder` 的 `addPostFrameCallback` 中都调用此方法，因为 `builder` 可能先于 `listener` 执行，必须确保预加载不会被遗漏

### 3. 重写 `_computeTodoBadgeCount` 方法

新的实现完全基于缓存的 meta 数据的 `total` 字段：

```dart
int _computeTodoBadgeCount(
  RecordsState recordsState,
  SessionState sessionState,
  InventoryState inventoryState, // 直接使用 BlocBuilder 提供的 state
) {
```

**重要**：必须将 `InventoryState` 作为参数传入，而不是通过 `getIt<InventoryBloc>()` 获取。因为：
- `getIt` 可能获取到不同的实例（如果配置不当）
- `BlocBuilder` 已经提供了最新的 state，应该直接使用
- 这样可以确保 state 的一致性和响应式更新

#### 角色判断
```dart
final bool isStorekeeper = sessionState is SessionStorekeeperEstablished;
final bool isBuilder = sessionState is SessionProjectEstablished &&
    (sessionState.currentUserRoleInfo.projectRoleType == UserRole.builder ||
        sessionState.currentUserRoleInfo.projectRoleType == UserRole.builderSub);
final bool isLaborer = sessionState is SessionProjectEstablished &&
    sessionState.currentUserRoleInfo.projectRoleType == UserRole.laborer;
```

#### 数据源（唯一）
- **缓存的 meta.total** (`RecordsRepository.getCachedMeta()`)
- **InventoryBloc.state.totalTasks**（盘点任务）

**不再依赖**：
- ❌ 当前激活的 tab 状态
- ❌ 列表记录的 length

#### 统计的任务类型

| 用户角色                        | 统计的任务类型                     |
|---------------------------------|------------------------------------|
| **仓管员** (storekeeper)        | todo + warehouseTodo               |
| **施工方** (builder/builderSub) | todo + siteTodo + builderInventory |
| **劳务人员** (laborer)          | todo + siteTodo                    |
| **其他角色**                    | todo                               |

#### 新的实现逻辑

```dart
int _computeTodoBadgeCount(RecordsState recordsState, SessionState sessionState) {
  final ids = _resolveIds(sessionState);
  final int? uid = ids.$1;
  final int? pid = ids.$2;

  // 判断用户角色类型
  final bool isStorekeeper = sessionState is SessionStorekeeperEstablished;
  final bool isBuilder = sessionState is SessionProjectEstablished &&
      (sessionState.currentUserRoleInfo.projectRoleType == UserRole.builder ||
          sessionState.currentUserRoleInfo.projectRoleType == UserRole.builderSub);
  final bool isLaborer = sessionState is SessionProjectEstablished &&
      sessionState.currentUserRoleInfo.projectRoleType == UserRole.laborer;

  int totalCount = 0;

  try {
    final repo = getIt<RecordsRepository>();

    // 1. 获取普通待办数量（所有角色都有）
    final todoMeta = repo.getCachedMeta(RecordType.todo, userId: uid, projectId: pid);
    totalCount += todoMeta?.total ?? 0;

    // 2. 仓管员：加上仓库待办
    if (isStorekeeper) {
      final whMeta = repo.getCachedMeta(RecordType.warehouseTodo, userId: uid, projectId: pid);
      totalCount += whMeta?.total ?? 0;
    }

    // 3. 施工方：加上现场待办
    if (isBuilder || isLaborer) {
      final siteTodoMeta = repo.getCachedMeta(RecordType.siteTodo, userId: uid, projectId: pid);
      totalCount += siteTodoMeta?.total ?? 0;
    }

    // 4. builder、builderSub：加上盘点任务
    // 直接使用传入的 inventoryState 参数，不要用 getIt
    if (isBuilder) {
      totalCount += inventoryState.totalTasks;
    }
  } catch (_) {
    // ignore cache failures
  }

  return totalCount;
}
```

**关键改进**：
- ✅ 直接使用 `meta.total`，不再依赖 `records.length`
- ✅ 不再区分当前激活 tab 和缓存数据
- ✅ Badge 数字保持一致，不会因为切换 tab 而变化
- ✅ 数据来源统一且可靠

### 4. 修改 `bottomNavigationBar` 监听逻辑

使用嵌套的 `BlocBuilder` 同时监听 `InventoryBloc` 和 `RecordsBloc`：

```dart
bottomNavigationBar: BlocBuilder<InventoryBloc, InventoryState>(
  builder: (context, inventoryState) {
    return BlocBuilder<RecordsBloc, RecordsState>(
      builder: (context, recordsState) {
        final isAdmin = sessionState is SessionAdminEstablished;
        final todoCount = _computeTodoBadgeCount(
          recordsState,
          sessionState,
        );
        final items = _buildNavItemsWithBadge(todoCount, isAdmin);
        return BottomNavigationBar(
          // ...
        );
      },
    );
  },
),
```

**为什么要这样做？**
- 当 `InventoryBloc` 的盘点任务数量变化时（如加载新数据、完成盘点等），badge 会自动更新
- 当 `RecordsBloc` 的待办数量变化时，badge 也会自动更新

## 实现细节

### 预加载时机

在 `_buildMainInterface` 的 `BlocConsumer<SessionBloc>` 的 `listener` 中：

```dart
listener: (context, state) {
  if ((state is SessionAdminEstablished ||
          state is SessionProjectEstablished ||
          state is SessionStorekeeperEstablished) &&
      !_isUiInitialized) {
    // ...
    _preloadBadgeCounts(state);  // 👈 关键调用
    // ...
  }
}
```

**触发条件**：
- 用户首次进入会话状态（`!_isUiInitialized`）
- 会话状态为管理员、项目参与方或仓管员

### 数据流程

```
用户登录
  ↓
进入 SessionProjectEstablished
  ↓
_preloadBadgeCounts() 调用
  ↓
发送 LoadRecords(pageSize: 1) 事件
  ↓
RecordsRepository 缓存 meta.total
  ↓
_computeTodoBadgeCount() 读取 meta.total
  ↓
显示 badge 数字
```

### 异常处理

所有的数据获取都包含了异常处理，确保在任何情况下都不会导致 UI 崩溃：

```dart
try {
  final repo = getIt<RecordsRepository>();
  // 获取缓存数据...
} catch (_) {
  // ignore cache failures
}

try {
  final inventoryBloc = getIt<InventoryBloc>();
  // 获取盘点任务数量...
} catch (_) {
  // ignore if InventoryBloc not available
}
```

## 用户体验改进

### 示例场景

#### 场景 1：Builder 角色
- 待办任务：5 个
- 现场待办：3 个  
- 盘点任务：2 个
- **Badge 显示**：10

#### 场景 2：Laborer 角色
- 待办任务：5 个
- 现场待办：3 个
- **Badge 显示**：8

#### 场景 3：Storekeeper 角色
- 待办任务：5 个
- 仓管待办：7 个
- **Badge 显示**：12

#### 场景 4：其他角色（如监理）
- 待办任务：5 个
- **Badge 显示**：5

## 技术亮点

1. **独立性**：badge 计算独立于 RecordsListPage 的 tab 状态，用户切换 tab 不影响 badge 数字
2. **预加载策略**：在会话建立时立即预加载，确保 badge 数据可用
3. **数据源统一**：使用服务端返回的 `total` 字段，数据权威且一致
4. **最小化请求**：使用 `pageSize: 1` 只获取 meta 数据，节省带宽
5. **数据复用**：预加载的数据会被 `RecordsListPage` 复用，避免重复请求
6. **实时更新**：通过 BlocBuilder 监听 InventoryBloc 和 RecordsBloc 状态变化
7. **容错设计**：完善的异常处理，保证 UI 稳定性

## 测试要点

### 核心测试

1. ✅ **builder 角色登录**
   - 验证首次进入时 badge 显示 todo + siteTodo + builderInventory 的总数
   - 在"记录"页切换不同 tab（如验收记录、出库记录等），验证 badge 数字保持不变
   
2. ✅ **builderSub 角色登录**
   - 验证 badge 计算逻辑同 builder
   - 切换 tab 后 badge 不变
   
3. ✅ **laborer 角色登录**
   - 验证 badge 显示 todo + siteTodo 的总数（不包含盘点任务）
   - 切换 tab 后 badge 不变
   
4. ✅ **storekeeper 角色登录**
   - 验证 badge 显示 todo + warehouseTodo 的总数
   - 切换 tab 后 badge 不变

### 数据更新测试

5. ✅ **完成任务后更新**
   - 完成一个待办任务，回到首页，验证 badge 数字减少 1
   
6. ✅ **下拉刷新更新**
   - 在"记录"页任意 tab 下拉刷新，验证 badge 数字更新为最新值
   
7. ✅ **盘点任务完成**
   - builder/builderSub 完成一个盘点任务后，验证 badge 数字减少（需要刷新）

### 边界测试

8. ✅ **tab 切换一致性**（重点测试）
   - 在"待办"tab 时记录 badge 数字
   - 切换到"验收记录"、"出库记录"等其他 tab
   - 验证 badge 数字保持不变
   - 回到"待办"tab，badge 数字仍然一致

9. ✅ **项目切换**
   - 切换到不同项目，验证 badge 数字更新为新项目的任务总数

10. ✅ **角色切换**
    - 从项目参与方切换到仓管员，验证 badge 数字更新为仓管员的任务总数

## 相关文件

- `/lib/pages/main_page.dart` - 主要修改文件
- `/lib/pages/records/records_list_page.dart` - 关联的记录列表页
- `/lib/bloc/inventory/inventory_bloc.dart` - 盘点任务 Bloc
- `/lib/bloc/inventory/inventory_state.dart` - 盘点任务状态
- `/lib/models/user/user_role.dart` - 用户角色定义

## 性能考虑

### 网络请求优化

- **预加载请求量**：每个需要统计的列表类型只发送一次 `pageSize: 1` 的请求
- **典型场景**：
  - Builder 角色：3 个请求（todo、siteTodo、builderInventory）
  - Laborer 角色：2 个请求（todo、siteTodo）
  - Storekeeper 角色：2 个请求（todo、warehouseTodo）
  - 其他角色：1 个请求（todo）

### 数据复用

预加载的数据会缓存在 `RecordsRepository` 中，当用户进入 `RecordsListPage` 时：
- 如果用户直接点击"待办"tab，使用预加载的数据，无需重新请求
- 如果用户点击其他 tab，该 tab 的数据会在切换时加载

### 刷新机制

Badge 数字会在以下情况自动更新：
1. `RecordsBloc` 状态变化时（BlocBuilder 监听）
2. `InventoryBloc` 状态变化时（嵌套 BlocBuilder 监听）
3. 用户在 `RecordsListPage` 下拉刷新时（会更新缓存的 meta）

## 已知限制

1. **初始加载延迟**：badge 数字依赖预加载请求完成，可能有短暂的延迟（通常 < 1 秒）
2. **网络失败**：如果预加载请求失败，badge 显示为 0，但不影响 UI 稳定性
3. **缓存过期**：依赖 `RecordsRepository` 的缓存策略（默认 5 分钟）

## 后续优化建议

1. 可以考虑为不同类型的任务使用不同颜色的 badge（需要 UI 设计）
2. 如果需要更精细的控制，可以为每种任务类型单独显示小 badge
3. 可以添加 badge 数字的加载状态指示器（如闪烁效果）
4. 考虑在网络失败时使用本地持久化的 badge 数据
