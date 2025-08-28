# 入库详情页面实现文档

## 概述

基于现有的API服务层、Repository层和数据模型，实现了一个完整的"入库详情"页面，包含Cubit状态管理和UI界面。

## 实现的文件

### 1. Cubit层
- **文件**: `lib/cubits/signin_detail_cubit.dart`
- **功能**: 管理入库详情页面的状态，包括加载、刷新、错误处理等

### 2. UI界面
- **文件**: `lib/pages/signin/signin_detail_page.dart`
- **功能**: 展示入库详情信息的用户界面

### 3. 使用示例
- **文件**: `lib/pages/signin/signin_detail_page_usage_example.dart`
- **功能**: 展示如何在应用中正确集成和使用入库详情页面

## 功能特性

### 数据展示
- ✅ **项目信息**: 显示项目名称、项目ID（如果有）
- ✅ **仓库信息**: 显示仓库名称、仓库ID
- ✅ **操作人信息**: 显示入库操作人姓名（如果有）
- ✅ **物料清单**: 显示所有入库物料，包含数量、安装桩号等信息
- ✅ **入库照片**: 支持查看所有入库相关的图片
- ✅ **物料安装图片**: 展示每个物料的安装图片（如果有）

### 交互功能
- ✅ **图片预览**: 点击小图可查看大图，支持缩放、滑动切换
- ✅ **下拉刷新**: 支持下拉刷新数据
- ✅ **错误重试**: 加载失败时可点击重试
- ✅ **状态指示**: 显示加载中、空数据、错误等状态

### UI设计特点
- ✅ **卡片布局**: 使用Card组件分组展示信息
- ✅ **响应式设计**: 适配不同屏幕尺寸
- ✅ **一致的风格**: 遵循项目现有的UI设计规范
- ✅ **图标和标签**: 使用图标和彩色标签增强视觉效果

## 技术实现

### 状态管理
- 使用 `flutter_bloc` 进行状态管理
- 定义了 `SigninDetailState` 包含加载状态、数据、错误信息
- `SigninDetailCubit` 提供 `loadSigninDetail` 和 `refreshSigninDetail` 方法

### 依赖注入
- 使用 `GetIt` 进行依赖注入
- 通过 `getIt<SigninRepository>()` 获取Repository实例
- 遵循项目现有的依赖注入模式

### 图片预览
- 复用项目现有的 `ImagePreviewWidget` 组件
- 支持网络图片的加载和预览
- 提供加载指示器和错误处理

## 使用方法

### 基本使用
```dart
// 导航到入库详情页面
SigninDetailPageUsageExample.navigateToSigninDetail(context, signinId);
```

### 在MultiBlocProvider中使用
```dart
MultiBlocProvider(
  providers: [
    BlocProvider<SigninDetailCubit>(
      create: (context) => SigninDetailCubit(
        signinRepository: getIt<SigninRepository>(),
      ),
    ),
  ],
  child: SigninDetailPage(signinId: signinId),
)
```

### 路由配置 (go_router)
```dart
GoRoute(
  path: '/signin-detail/:id',
  builder: (context, state) {
    final signinId = int.parse(state.pathParameters['id']!);
    return BlocProvider(
      create: (context) => SigninDetailCubit(
        signinRepository: getIt<SigninRepository>(),
      ),
      child: SigninDetailPage(signinId: signinId),
    );
  },
)
```

## 数据结构

页面展示的数据基于 `SignInInfoVO` 模型：

```dart
class SignInInfoVO {
  final List<MaterialVO> materialList;    // 物料列表
  final List<AttachmentVO> imageList;     // 图片列表
  final int warehouseId;                  // 仓库ID
  final String? warehouseName;            // 仓库名称
  final String? signinUserName;           // 入库操作人名称
  final int? projectId;                   // 项目ID
  final String? projectName;              // 项目名称
}
```

## UI组件结构

```
SigninDetailPage
├── AppBar (标题 + 刷新按钮)
├── RefreshIndicator (下拉刷新)
└── ScrollView
    ├── ProjectInfo Card (项目信息 - 可选)
    ├── WarehouseInfo Card (仓库信息)
    ├── SigninOperatorInfo Card (操作人信息 - 可选)
    ├── MaterialsList Card (物料清单)
    └── SigninPhotos Card (入库照片)
```

## 扩展性

### 添加新的展示字段
1. 在对应的 `_build*` 方法中添加新的UI组件
2. 使用 `_buildInfoRow` 方法快速添加键值对信息

### 添加新的交互功能
1. 在 `SigninDetailCubit` 中添加新的方法
2. 在 `SigninDetailState` 中添加新的状态字段
3. 在UI中使用 `BlocBuilder` 响应状态变化

### 自定义样式
- 所有样式都在UI组件中定义，可以轻松修改
- 遵循Material Design规范
- 可以通过主题定制全局样式

## 注意事项

1. **网络图片加载**: 已处理加载中状态和错误状态
2. **内存管理**: 图片预览组件会自动处理内存释放
3. **错误处理**: 所有网络请求都有完善的错误处理机制
4. **空数据处理**: 当列表为空时会显示友好的提示信息

## 依赖关系

本实现依赖于以下现有组件：
- `SigninRepository` - 数据仓库接口
- `SignInInfoVO` - 数据模型
- `ImagePreviewWidget` - 图片预览组件
- `common_state_widgets` - 通用状态组件
- `GetIt` - 依赖注入容器
