# 截管记录数据加载优化修复

## 问题描述
之前的实现中，当点击"截管记录"tab时，会同时触发：
1. `CutRecordsBloc` 通过专用的 `CutRecordsApiService` 加载数据（正确）
2. `RecordsBloc` 通过通用的 `RecordsRepository` 尝试加载数据（错误）

由于 `RecordType.cut` 在 `RecordsRepositoryImpl.getRecordsWithMeta()` 的 switch 语句中没有特殊处理，它会走到 `default` 分支，尝试调用不存在的通用 API 端点 `/cut/records`，导致错误请求。

## 解决方案
参考 `RecordType.builderInventory` 的处理方式，对 `RecordType.cut` 进行类似的隔离处理。

## 修改内容

### 1. RecordsRepositoryImpl - 添加 cut 类型的早期返回
**文件**: `lib/repositories/implementations/records_repository_impl.dart`

在 `getRecordsWithMeta` 方法开头，添加对 `RecordType.cut` 的检查：

```dart
@override
Future<PagedRecords<RecordItem>> getRecordsWithMeta({
  required RecordType recordType,
  int? projectId,
  int? userId,
  int pageNum = 1,
  int pageSize = 10,
  bool forceRefresh = false,
}) async {
  // builderInventory 由 InventoryBloc 处理，这里返回空数据
  if (recordType == RecordType.builderInventory) {
    return const PagedRecords(
      records: [],
      meta: PageMeta(total: 0, size: 10, current: 1),
    );
  }

  // cut 由 CutRecordsBloc 处理，这里返回空数据
  if (recordType == RecordType.cut) {
    return const PagedRecords(
      records: [],
      meta: PageMeta(total: 0, size: 10, current: 1),
    );
  }
  
  // ... 后续逻辑
}
```

**作用**: 当请求 cut 类型的数据时，直接返回空结果，不走后续的 switch-default 分支。

### 2. RecordsBloc - 在 SwitchTab 事件中跳过特殊类型
**文件**: `lib/bloc/records/records_bloc.dart`

修改 `_onSwitchTab` 方法：

```dart
Future<void> _onSwitchTab(SwitchTab event, Emitter<RecordsState> emit) async {
  Logger.info('Switching to tab: ${event.recordType}', tag: 'RecordsBloc');

  // builderInventory 和 cut 由各自独立的 Bloc 处理，这里只更新 currentTab
  if (event.recordType == RecordType.builderInventory ||
      event.recordType == RecordType.cut) {
    emit(RecordsInitial(currentTab: event.recordType));
    return;
  }

  // ... 后续逻辑（处理其他类型的 tab 切换）
}
```

**作用**: 当切换到 cut 或 builderInventory tab 时，RecordsBloc 只更新 currentTab 状态，不尝试加载数据。

### 3. RecordsListPage - _onTabSelected 方法优化
**文件**: `lib/pages/records/records_list_page.dart`

虽然 `_onTabSelected` 仍会为 cut tab 发送 `SwitchTab` 事件（用于更新 currentTab），但添加了日志说明：

```dart
void _onTabSelected(RecordType recordType) {
  final ids = _resolveIds(context.read<SessionBloc>().state);

  // 如果切换到盘点任务tab，触发InventoryBloc加载数据
  if (recordType == RecordType.builderInventory) {
    context.read<InventoryBloc>().add(const InventoryTasksFetched());
  }

  // 如果切换到截管记录tab，不需要通过RecordsBloc处理
  // CutRecordsView 内部会自动加载数据
  if (recordType == RecordType.cut) {
    Logger.debug(
      'Tab selected: ${recordType.displayName} (handled by CutRecordsBloc)',
      tag: 'RecordsListPage',
    );
    // 仍然需要通知 RecordsBloc 更新 currentTab，但不加载数据
    context.read<RecordsBloc>().add(SwitchTab(...));
    return;
  }

  // ... 其他 tab 的处理
}
```

### 4. RecordsListPage - _buildContent 方法
**文件**: `lib/pages/records/records_list_page.dart`

该方法已正确实现，当 currentTab 为 cut 时，直接返回 `CutRecordsView`：

```dart
Widget _buildContent() {
  return BlocBuilder<RecordsBloc, RecordsState>(
    builder: (context, recordsState) {
      // 获取当前选中的 tab
      RecordType currentTab = _getCurrentTab(recordsState);

      // 如果是截管记录tab，使用CutRecordsView
      if (currentTab == RecordType.cut) {
        return BlocProvider(
          create: (context) => getIt<CutRecordsBloc>(),
          child: const CutRecordsView(),
        );
      }

      // 如果是盘点任务tab，使用InventoryBloc的数据
      if (currentTab == RecordType.builderInventory) {
        // ... 盘点任务处理
      }

      // 其他tab使用RecordsBloc的数据
      // ...
    },
  );
}
```

## 数据流程对比

### 修复前（错误）
```
用户点击 cut tab
  ↓
RecordsBloc.SwitchTab
  ↓
RecordsRepository.getRecordsWithMeta(cut)
  ↓
switch (cut) → default 分支
  ↓
调用 RecordsApiService.getBusinessRecords(cut)  ← 错误！
  ↓
尝试请求 /cut/records/{projectId} （通用端点，不存在）
  ↓
同时，CutRecordsView 加载后
  ↓
CutRecordsBloc.LoadCutRecords
  ↓
CutRecordsApiService.fetchCutRecords()  ← 正确
  ↓
请求 /cut/records/{projectId} （专用端点）
```

### 修复后（正确）
```
用户点击 cut tab
  ↓
RecordsBloc.SwitchTab(cut)
  ↓
检测到 cut 类型，直接 emit RecordsInitial(currentTab: cut)
  ↓
RecordsListPage._buildContent()
  ↓
检测到 currentTab == cut
  ↓
返回 CutRecordsView（带新的 CutRecordsBloc）
  ↓
CutRecordsView 自动触发 LoadCutRecords
  ↓
CutRecordsBloc 处理
  ↓
CutRecordsApiService.fetchCutStatistics()  ← 正确
CutRecordsApiService.fetchCutRecords()     ← 正确
  ↓
请求专用端点：
  - GET /cut/statistic/{projectId}
  - GET /cut/records/{projectId}
```

## 优势
1. **避免无效请求**: 不再尝试通过通用 API 加载 cut 数据
2. **数据隔离**: cut 数据完全由 `CutRecordsBloc` 管理，不污染 `RecordsBloc` 的状态
3. **一致性**: 与 `builderInventory` 的处理方式保持一致
4. **清晰的职责**: 每个 Bloc 只处理自己负责的数据类型

## 测试要点
1. 点击"截管记录"tab，检查网络请求，应只有：
   - `GET /cut/statistic/{projectId}`
   - `GET /cut/records/{projectId}?pageNum=1&pageSize=10`
   - 不应该有通过通用端点的错误请求
2. 切换到其他 tab 再切回"截管记录"，数据加载正常
3. 下拉刷新功能正常
4. 上拉加载更多功能正常

## 修复日期
2025年10月11日
