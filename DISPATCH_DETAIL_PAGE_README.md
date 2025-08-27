# 调拨详情页使用说明

## 概述

`DispatchDetailPage` 是一个只读的调拨记录详情展示页面，用于查看调拨记录的完整信息，不包含任何交互操作。

## 功能特性

✅ **已完成的功能**
- 调拨记录基本信息展示
- 物料清单展示
- 项目信息展示（发出方 → 接收方）
- 仓库信息展示（发出仓库 → 接收仓库）
- 负责人信息展示（发出方负责人、接收方负责人）
- 相关照片展示和预览
- 数据加载状态处理（loading、error、empty state）
- 下拉刷新功能
- 统一的UI设计风格

## 页面结构

### 1. 页面头部
- 页面标题：调拨详情
- 返回按钮

### 2. 页面内容
1. **头部卡片**：调拨记录摘要信息
2. **物料清单**：展示所有调拨的物料及数量
3. **项目信息**：发出项目和接收项目
4. **仓库信息**：发出仓库和接收仓库
5. **负责人信息**：相关负责人的联系方式
6. **相关照片**：调拨过程的图片记录（如有）

## 技术实现

### Bloc 层支持
页面使用现有的 `DispatchBloc`：
- **事件**：`LoadDispatchDetail` - 加载调拨详情
- **状态**：利用 `DispatchState.dispatchDetail` 字段
- **数据类型**：`DispatchDetailVo` 

### 路由配置
```dart
GoRoute(
  path: '/dispatch-detail',
  name: 'dispatch-detail',
  builder: (context, state) {
    final dispatchId = int.tryParse(state.uri.queryParameters['id'] ?? '');
    return BlocProvider(
      create: (context) => getIt<DispatchBloc>(),
      child: DispatchDetailPage(dispatchId: dispatchId),
    );
  },
)
```

## 使用方法

### 1. 通过路由跳转
```dart
// 使用 GoRouter 跳转
context.goNamed(
  'dispatch-detail',
  queryParameters: {'id': '123'},
);

// 或者使用 push
context.pushNamed(
  'dispatch-detail',
  queryParameters: {'id': '123'},
);
```

### 2. 直接使用组件
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => getIt<DispatchBloc>(),
      child: DispatchDetailPage(dispatchId: 123),
    ),
  ),
);
```

## UI 设计特色

### 1. 卡片式布局
- 每个功能模块使用独立的卡片
- 圆角边框和阴影效果
- 清晰的视觉层次

### 2. 色彩体系
- **蓝色系**：物料相关信息
- **绿色系**：项目信息
- **紫色系**：仓库信息
- **靛蓝色系**：负责人信息
- **粉色系**：照片相关

### 3. 状态展示
- **成功状态**：绿色徽章标识
- **空状态**：友好的空白提示
- **加载状态**：统一的 loading 组件
- **错误状态**：带重试按钮的错误提示

### 4. 交互体验
- 下拉刷新
- 图片点击预览（全屏查看）
- 平滑的滚动体验
- 响应式布局

## 数据字段映射

```dart
DispatchDetailVo {
  materialList,        // 物料清单
  imageList,          // 相关照片
  fromProjectId,      // 发出项目ID
  fromProjectName,    // 发出项目名称
  toProjectId,        // 接收项目ID
  toProjectName,      // 接收项目名称
  toWarehouseId,      // 接收仓库ID
  toWarehouseName,    // 接收仓库名称
  fromWarehouseId,    // 发出仓库ID
  fromWarehouseName,  // 发出仓库名称
  toUserId,           // 接收用户ID
  toUserName,         // 接收用户名称
  fromWarehouseUsers, // 发出方负责人列表
  toWarehouseUsers,   // 接收方负责人列表
}
```

## 相关页面对比

| 页面                       | 功能         | 交互操作      |
|----------------------------|------------|-----------|
| `DispatchDetailPage`       | 查看调拨详情 | 无，仅展示     |
| `DispatchConfirmationPage` | 调拨确认     | 确认/拒绝调拨 |
| `DispatchAfterSigninPage`  | 调拨入库     | 扫码入库操作  |
| `DispatchApplicationPage`  | 调拨申请     | 提交调拨申请  |

## 注意事项

1. **参数验证**：页面会检查传入的 `dispatchId` 参数，无效时显示错误页面
2. **权限控制**：页面本身不包含权限验证，需要在路由层或上级页面处理
3. **网络状态**：支持网络错误时的重试机制
4. **图片加载**：图片加载失败时会显示占位符
5. **数据缓存**：依赖于 Bloc 层的状态管理，支持页面间数据共享

## 测试建议

可以使用提供的测试页面 `DispatchDetailTestPage` 进行基本功能测试，该页面包含了不同 ID 的跳转示例。
