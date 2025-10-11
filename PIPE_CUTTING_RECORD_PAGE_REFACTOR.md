# 截管记录详情页面独立化重构

## 重构背景

之前的 `PipeCuttingRecordPage` 依赖于 `MaterialDetailBloc`，这导致：
1. 该页面必须作为 `material-detail` 的子路由存在
2. 无法在其他场景（如截管记录列表）中直接复用
3. 需要传递额外的 `MaterialDetailBloc` 实例作为 extra 参数

为了提高复用性和降低耦合，我们将其重构为独立页面。

## 重构方案

### 1. 创建独立的 BLoC

创建了 `PipeCuttingRecordBloc` 来专门处理截管记录详情的状态管理：

**文件位置：**
- `lib/bloc/pipe_cutting_record/pipe_cutting_record_bloc.dart`
- `lib/bloc/pipe_cutting_record/pipe_cutting_record_event.dart`
- `lib/bloc/pipe_cutting_record/pipe_cutting_record_state.dart`

**Event:**
- `LoadPipeCuttingRecord` - 加载截管记录详情
- `RefreshPipeCuttingRecord` - 刷新截管记录详情

**State:**
- `PipeCuttingRecordInitial` - 初始状态
- `PipeCuttingRecordLoading` - 加载中
- `PipeCuttingRecordLoaded` - 加载成功
- `PipeCuttingRecordError` - 加载失败

**依赖：**
- `CutApiService` - 通过 `getCuttingHistory()` 方法获取截管树数据

### 2. 修改 PipeCuttingRecordPage

将页面从依赖外部 `MaterialDetailBloc` 改为使用自己的 `PipeCuttingRecordBloc`：

**修改前：**
```dart
class PipeCuttingRecordPage extends StatefulWidget {
  // 在 initState 中调用 context.read<MaterialDetailBloc>()
  // 依赖外部提供的 MaterialDetailBloc
}
```

**修改后：**
```dart
class PipeCuttingRecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PipeCuttingRecordBloc>()
        ..add(LoadPipeCuttingRecord(materialId: materialId)),
      child: PipeCuttingRecordView(materialId: materialId),
    );
  }
}
```

**主要变化：**
- 从 `StatefulWidget` 改为 `StatelessWidget`
- 内部自己创建 `PipeCuttingRecordBloc` 实例
- 不再需要外部传入 `MaterialDetailBloc`
- 状态管理完全独立

### 3. 更新路由配置

将 `pipe-cutting-record` 从 `material-detail` 的子路由提升为独立路由：

**修改前：**
```dart
GoRoute(
  path: 'material-detail',
  routes: [
    GoRoute(
      path: 'pipe-cutting-record',  // 子路由
      builder: (context, state) {
        final cubit = state.extra as MaterialDetailBloc?;  // 需要传入 bloc
        return BlocProvider.value(
          value: cubit,
          child: PipeCuttingRecordPage(materialId: materialId),
        );
      },
    ),
  ],
),
```

**修改后：**
```dart
GoRoute(
  path: 'pipe-cutting-record',  // 独立路由
  name: 'pipe-cutting-record',
  builder: (context, state) {
    final materialId = state.uri.queryParameters['materialId'];
    return PipeCuttingRecordPage(materialId: materialId);  // 无需传入 bloc
  },
),
```

**路由变化：**
- 路径保持不变：`/pipe-cutting-record`
- 不再需要 `extra` 参数传递 `MaterialDetailBloc`
- 只需要 `materialId` 查询参数

### 4. 注册服务和 BLoC

在 `service_locator.dart` 中注册必要的服务和 BLoC：

```dart
// 注册 CutApiService（之前缺失）
getIt.registerLazySingleton<CutApiService>(
  () => ApiServiceFactory.createCutService(),
);

// 注册 PipeCuttingRecordBloc
getIt.registerFactory<PipeCuttingRecordBloc>(
  () => PipeCuttingRecordBloc(
    cutApiService: getIt<CutApiService>(),
  ),
);
```

**注意：** `CutApiService` 之前没有在 service_locator 中注册，只在 `RepositoryFactory.createMaterialDetailRepository()` 中通过 `ApiServiceFactory.createCutService()` 创建。为了让 `PipeCuttingRecordBloc` 能够通过依赖注入获取 `CutApiService`，我们需要将其注册到 GetIt 中。

### 5. 实现截管记录列表的点击跳转

在 `CutRecordsView` 中添加点击事件处理：

```dart
void _onRecordTap(BuildContext context, CutRecordsItemVO record) {
  context.pushNamed(
    'pipe-cutting-record',
    queryParameters: {
      'materialId': record.materialId.toString(),
    },
  );
}
```

## 技术要点

### 1. API 调用复用

`PipeCuttingRecordBloc` 和 `MaterialDetailBloc` 都使用相同的 API 方法：
- `CutApiService.getCuttingHistory(materialId)` 
- 返回 `Result<PipeCuttingRecord>`

这保证了数据获取逻辑的一致性。

### 2. 状态管理简化

新的 BLoC 状态更简洁：
- 只关注截管记录的加载状态
- 不包含其他无关数据（如材料详情、生命周期等）

### 3. 页面职责单一

`PipeCuttingRecordPage` 现在只负责：
1. 创建自己的 BLoC 实例
2. 触发数据加载
3. 展示截管树视图

不再依赖外部状态管理。

## 使用场景

重构后的页面可以在多个场景中使用：

### 场景1：材料详情页跳转（原有场景）
```dart
// 从材料详情页跳转
context.pushNamed(
  'pipe-cutting-record',
  queryParameters: {'materialId': materialId},
);
```

### 场景2：截管记录列表跳转（新增场景）
```dart
// 从截管记录列表点击跳转
void _onRecordTap(BuildContext context, CutRecordsItemVO record) {
  context.pushNamed(
    'pipe-cutting-record',
    queryParameters: {
      'materialId': record.materialId.toString(),
    },
  );
}
```

### 场景3：其他任何需要查看截管记录的场景
只需要提供 `materialId` 即可。

## 影响范围

### 修改的文件
1. **新增：**
   - `lib/bloc/pipe_cutting_record/pipe_cutting_record_bloc.dart`
   - `lib/bloc/pipe_cutting_record/pipe_cutting_record_event.dart`
   - `lib/bloc/pipe_cutting_record/pipe_cutting_record_state.dart`

2. **修改：**
   - `lib/pages/material/pipe_cutting_record_page.dart` - 使用新 BLoC
   - `lib/config/routes.dart` - 路由独立化
   - `lib/config/service_locator.dart` - 注册 CutApiService 和 PipeCuttingRecordBloc
   - `lib/widgets/cut_records_view.dart` - 添加点击跳转

### 向后兼容性

✅ **完全兼容** - 从材料详情页跳转的现有逻辑不受影响，因为：
- 路由名称保持不变：`pipe-cutting-record`
- 查询参数保持不变：`materialId`
- UI 展示保持不变

唯一区别是不再需要传递 `MaterialDetailBloc` 作为 extra 参数。

## 设计优势

### 1. 解耦
- 截管记录详情页不再依赖材料详情的状态管理
- 各自的 BLoC 职责更清晰

### 2. 复用
- 可以在任何地方使用截管记录详情页
- 只需要 materialId 参数

### 3. 测试
- 更容易进行单元测试
- 减少 mock 的依赖

### 4. 维护
- 代码结构更清晰
- 状态管理更简单
- 降低认知负担

## 总结

通过这次重构，我们：
1. ✅ 创建了独立的 `PipeCuttingRecordBloc`
2. ✅ 将 `PipeCuttingRecordPage` 改造为独立页面
3. ✅ 更新了路由配置，使其成为顶级路由
4. ✅ 实现了从截管记录列表点击跳转到详情页的功能
5. ✅ 保持了向后兼容性

现在 `PipeCuttingRecordPage` 可以在项目的任何地方复用，而不仅仅局限于材料详情页的子页面。
