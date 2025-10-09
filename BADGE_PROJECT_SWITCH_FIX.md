# Badge 项目切换 Bug 修复

## 问题描述

### 现象
1. **首次加载**：Badge 正常显示 ✅
2. **切换项目后**：
   - MainPage 底部导航栏的"记录" badge 先显示再消失 ❌
   - RecordsListPage 顶部 tab 的 badge 也消失 ❌
3. **在 RecordsListPage 切换 tab 后**：Badge 才重新出现 ✅

### 用户影响
- 切换项目后，用户无法看到新项目的待办任务数量
- 必须手动切换到 RecordsListPage 并切换 tab 才能看到 badge
- 用户体验差，可能误以为没有待办任务

## 根本原因分析

### 问题1：MainPage 只在首次初始化时预加载

**代码问题**：
```dart
listener: (context, state) {
  if ((state is SessionAdminEstablished ||
          state is SessionProjectEstablished ||
          state is SessionStorekeeperEstablished) &&
      !_isUiInitialized) {  // ❌ 只在首次初始化时执行
    _preloadBadgeCounts(state);
  }
}
```

**问题分析**：
- `!_isUiInitialized` 条件导致只在首次初始化时预加载
- 切换项目时，`_isUiInitialized` 已经是 `true`
- 不会触发 `_preloadBadgeCounts`，导致缓存的 meta 数据仍然是旧项目的
- `_computeTodoBadgeCount` 检查到 meta 为 null 或旧数据，返回 0

**执行流程**：
```
1. 首次进入（项目A）
   → _preloadBadgeCounts(项目A) ✅
   → badge 显示正常 ✅

2. 切换到项目B
   → SessionBloc 发出新的 SessionProjectEstablished(项目B)
   → listener 检查：_isUiInitialized = true ❌
   → 不执行 _preloadBadgeCounts ❌
   → 缓存中仍然是项目A的数据
   → _computeTodoBadgeCount 检查项目B的数据：meta = null
   → 返回 0，badge 消失 ❌

3. 在 RecordsListPage 切换 tab
   → 触发 LoadRecords 或 InventoryTasksFetched
   → 重新加载数据并缓存 meta
   → badge 重新出现 ✅
```

### 问题2：RecordsListPage 切换项目时只刷新当前 tab

**代码问题**：
```dart
if (typeChanged || projectChanged) {
  context.read<RecordsBloc>().add(
    RefreshRecords(
      recordType: _initialTab,  // ❌ 只刷新默认 tab
      userId: ids.$1,
      projectId: ids.$2,
    ),
  );
}
```

**问题分析**：
- 项目切换时只刷新了 `_initialTab`（通常是 `todo`）
- 其他需要显示 badge 的 tab（`siteTodo`、`builderInventory`、`warehouseTodo`）没有预加载
- 这些 tab 的 meta 数据仍然是旧项目的或为 null
- 导致 badge 数量不正确或消失

## 解决方案

### 修复1：MainPage 监听项目切换并重新预加载

#### 添加项目ID追踪
```dart
class _MainPageState extends State<MainPage> {
  int? _lastProjectId; // 🎯 追踪当前项目ID
  bool _isBadgeDataReady = false;
  // ...
}
```

#### 修改 listener 逻辑
```dart
listener: (context, state) {
  // 🎯 检测是否是首次初始化或项目切换
  bool isFirstInit = !_isUiInitialized;
  bool isProjectSwitch = false;

  if (state is SessionProjectEstablished) {
    final currentProjectId = state.project.projectId;
    if (_lastProjectId != null && _lastProjectId != currentProjectId) {
      isProjectSwitch = true; // 项目发生了切换
    }
    _lastProjectId = currentProjectId;
  } else if (state is SessionStorekeeperEstablished) {
    // 仓管员切换身份时也需要重新加载
    if (_lastProjectId != null) {
      isProjectSwitch = true;
    }
    _lastProjectId = null;
  }

  // 🎯 首次初始化或项目切换时，都需要预加载 badge 数据
  if ((state is SessionAdminEstablished ||
          state is SessionProjectEstablished ||
          state is SessionStorekeeperEstablished) &&
      (isFirstInit || isProjectSwitch)) {
    
    // 项目切换时重置 badge 数据准备状态
    if (isProjectSwitch) {
      setState(() {
        _isBadgeDataReady = false;
      });
    }

    // 🎯 预加载 badge 数据
    _preloadBadgeCounts(state);

    if (isFirstInit) {
      // 首次初始化的其他逻辑
      // ...
    }
  }
}
```

**关键改进**：
1. ✅ 使用 `_lastProjectId` 追踪项目切换
2. ✅ 区分 `isFirstInit` 和 `isProjectSwitch`
3. ✅ 项目切换时重置 `_isBadgeDataReady = false`
4. ✅ 项目切换时也调用 `_preloadBadgeCounts`

### 修复2：RecordsListPage 预加载所有 badge tab

#### 添加预加载方法
```dart
/// 预加载需要显示 badge 的 tab 数据（项目切换时调用）
void _preloadTabBadgeCounts(SessionState sessionState, int? uid, int? pid) {
  // 根据用户角色预加载相应的 tab 数据
  if (sessionState is SessionStorekeeperEstablished) {
    // 仓管员：预加载 warehouseTodo
    context.read<RecordsBloc>().add(
      LoadRecords(
        recordType: RecordType.warehouseTodo,
        pageSize: 1,
        // ...
      ),
    );
  }

  if (sessionState is SessionProjectEstablished) {
    final role = sessionState.currentUserRoleInfo.projectRoleType;
    
    // 所有项目参与方：预加载 todo
    context.read<RecordsBloc>().add(
      LoadRecords(recordType: RecordType.todo, pageSize: 1, ...),
    );

    // builder、builderSub、laborer：预加载 siteTodo
    if (role == UserRole.builder || role == UserRole.builderSub || role == UserRole.laborer) {
      context.read<RecordsBloc>().add(
        LoadRecords(recordType: RecordType.siteTodo, pageSize: 1, ...),
      );
    }

    // builder、builderSub：预加载 builderInventory
    if (role == UserRole.builder || role == UserRole.builderSub) {
      context.read<InventoryBloc>().add(
        const InventoryTasksFetched(isRefresh: true),
      );
    }
  }
}
```

#### 在项目切换时调用
```dart
if (typeChanged || projectChanged) {
  setState(() {
    _setupTabsBySession(sessionState);
    final ids = _resolveIds(sessionState);
    
    // 🎯 预加载所有需要显示 badge 的 tab 数据
    _preloadTabBadgeCounts(sessionState, ids.$1, ids.$2);
    
    // 刷新当前 tab
    context.read<RecordsBloc>().add(
      RefreshRecords(recordType: _initialTab, ...),
    );
  });
}
```

## 修复后的执行流程

### 场景：用户从项目A切换到项目B

```
┌─────────────────────────────────────────────────────────────┐
│ 1. 用户在 HomePage 点击切换项目                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. SessionBloc 发出 SessionProjectEstablished(项目B)       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. MainPage listener 检测到项目切换                         │
│    → _lastProjectId (项目A) != currentProjectId (项目B)    │
│    → isProjectSwitch = true                                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. MainPage 重置 badge 状态                                 │
│    → _isBadgeDataReady = false                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. MainPage 预加载项目B的 badge 数据                        │
│    → LoadRecords(todo, 项目B, pageSize: 1)                 │
│    → LoadRecords(siteTodo, 项目B, pageSize: 1)             │
│    → InventoryTasksFetched(项目B)                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. RecordsListPage listener 也检测到项目切换                │
│    → _preloadTabBadgeCounts(项目B)                          │
│    → 预加载所有 badge tab 的数据                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 7. 所有接口陆续返回                                         │
│    → RecordsRepository 缓存项目B的 meta 数据                │
│    → InventoryBloc 更新 totalTasks                          │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 8. BlocBuilder 重建 UI                                      │
│    → _computeTodoBadgeCount 检查：所有数据都准备好 ✅       │
│    → 返回项目B的总数，badge 一次性显示 ✅                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 9. 用户看到的效果                                           │
│    ✅ MainPage badge 显示项目B的任务总数                    │
│    ✅ RecordsListPage tab badges 显示各类型的数量           │
│    ✅ 无闪烁，数据一致                                      │
└─────────────────────────────────────────────────────────────┘
```

## 测试验证

### 测试场景1：项目切换
1. 以 builder 身份登录项目A
2. 验证 badge 显示正确（如：todo=2, siteTodo=1, inventory=1, 总计=4）
3. 切换到项目B
4. **验证**：
   - ✅ Badge 不会闪烁（先显示再消失）
   - ✅ Badge 立即显示项目B的正确数量
   - ✅ RecordsListPage 的 tab badges 也正确显示

### 测试场景2：角色切换
1. 以 builder 身份（项目参与方）登录
2. 切换到仓管员身份
3. **验证**：
   - ✅ Badge 显示仓管员的待办数量（warehouseTodo）
   - ✅ 不显示项目相关的 badge

### 测试场景3：快速切换
1. 快速连续切换多个项目
2. **验证**：
   - ✅ Badge 始终显示最新项目的数量
   - ✅ 没有出现旧数据或错误数量

### 测试场景4：网络慢速情况
1. 在 DevTools 中模拟慢速网络（3G）
2. 切换项目
3. **验证**：
   - ✅ Badge 在所有数据加载完成前不显示（避免跳闪）
   - ✅ 加载完成后一次性显示正确数量

## 代码改动总结

### MainPage 改动
| 文件 | 改动 | 说明 |
|------|------|------|
| `lib/pages/main_page.dart` | 添加 `_lastProjectId` 字段 | 追踪当前项目ID |
| `lib/pages/main_page.dart` | 修改 `listener` 逻辑 | 检测项目切换并预加载 |

### RecordsListPage 改动
| 文件 | 改动 | 说明 |
|------|------|------|
| `lib/pages/records/records_list_page.dart` | 添加 `_preloadTabBadgeCounts` 方法 | 预加载所有 badge tab |
| `lib/pages/records/records_list_page.dart` | 修改 `listener` 逻辑 | 项目切换时预加载 |

## 性能影响

### 网络请求
- **之前**：切换项目后不加载，直到用户手动切换 tab
- **现在**：切换项目时立即预加载所有 badge tab（pageSize=1）

**评估**：
- 增加的请求：3-4个（取决于用户角色）
- 每个请求数据量：极小（只请求 meta，pageSize=1）
- 用户体验提升：显著（badge 立即显示正确数量）

### 内存开销
- 增加了 1 个 `int?` 字段（`_lastProjectId`）
- 可忽略不计（< 8 字节）

### CPU 开销
- 增加了项目切换检测逻辑（简单的 int 比较）
- 可忽略不计（纳秒级）

## 相关文档
- [Badge 加载优化](./BADGE_LOADING_OPTIMIZATION.md)
- [MainPage Badge 优化](./MAIN_PAGE_BADGE_OPTIMIZATION.md)
- [RecordsListPage Tab Badges](./RECORDS_LIST_PAGE_TAB_BADGES.md)

## 总结

### ✅ 修复内容
1. MainPage 现在能正确检测项目切换并重新预加载 badge 数据
2. RecordsListPage 在项目切换时预加载所有需要显示 badge 的 tab
3. Badge 数据完整性检查确保只在所有数据准备好时才显示

### 🎯 用户体验改善
- ✅ 切换项目后 badge 立即显示正确数量
- ✅ 无闪烁或跳跃
- ✅ 数据一致性得到保证

### 📊 性能影响
- 增加少量网络请求（3-4个，数据量极小）
- CPU 和内存开销可忽略
- 用户体验显著提升

这次修复彻底解决了项目切换后 badge 消失的问题！🎉
