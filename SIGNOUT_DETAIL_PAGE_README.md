# Signout Detail Page 使用说明

## 概述

新增的 `SignoutDetailPage` 是一个专门用于展示出库详情的页面，基于现有的 `SignoutBloc` 构建，提供了完整的出库信息展示功能。

## 功能特性

### 🔍 详情展示
- **出库基础信息**: 仓库名称、物料数量、安装负责人等概览信息
- **物料清单**: 完整的出库物料列表，包含物料名称、ID、数量等详细信息
- **仓库信息**: 出库仓库的详细信息
- **相关人员**: 仓库管理员和安装负责人信息
- **安装信息**: 如果有关联的安装信息，会显示安装相关详情
- **相关照片**: 支持图片预览功能

### 🎨 UI设计
- 采用卡片式布局，信息分类清晰
- 保持与其他详情页面一致的设计风格
- 支持下拉刷新
- 响应式布局，适配不同屏幕尺寸
- 优雅的加载和错误状态处理

## 使用方法

### 1. 路由导航

使用 `go_router` 导航到详情页面：

```dart
// 方法1: 使用 context.go
context.go('/signout-detail?id=123');

// 方法2: 使用 context.push
context.push('/signout-detail?id=123');

// 方法3: 使用 GoRouter.of(context)
GoRouter.of(context).go('/signout-detail?id=123');
```

### 2. 程序化导航

```dart
// 在其他页面中导航到出库详情
void navigateToSignoutDetail(int signoutId) {
  context.push('/signout-detail?id=$signoutId');
}

// 示例：从出库记录列表跳转
ListTile(
  title: Text('出库记录 #123'),
  onTap: () => context.push('/signout-detail?id=123'),
)
```

### 3. 集成到现有功能

可以在以下场景中使用：

```dart
// 在出库记录页面中
IconButton(
  icon: Icon(Icons.visibility),
  onPressed: () => context.push('/signout-detail?id=${record.id}'),
  tooltip: '查看详情',
)

// 在搜索结果中
GestureDetector(
  onTap: () => context.push('/signout-detail?id=${item.signoutId}'),
  child: SignoutRecordCard(item: item),
)
```

## 页面结构

### 头部信息卡片
- 出库记录标题
- 状态标签（已完成）
- 仓库概要信息
- 物料数量统计
- 安装负责人信息

### 物料清单卡片
- 物料数量统计
- 详细物料列表
- 每个物料包含：名称、ID、数量

### 仓库信息卡片
- 仓库名称
- 仓库ID

### 相关人员卡片
- 仓库管理员列表
- 安装负责人信息
- 人员联系方式
- 推送状态标识

### 安装信息卡片（如果有）
- 关联出库ID
- 是否仅安装标识
- 安装质量文档状态

### 相关照片卡片（如果有）
- 缩略图网格展示
- 支持点击放大预览
- 图片加载失败处理

## 状态管理

页面使用 `SignoutBloc` 进行状态管理：

```dart
// 加载数据
context.read<SignoutBloc>().add(LoadSignoutDetail(signinId: signoutId));

// 监听状态变化
BlocBuilder<SignoutBloc, SignoutState>(
  builder: (context, state) {
    if (state is SignoutLoading) {
      return LoadingWidget();
    }
    if (state is SignoutReady && state.signoutDetail != null) {
      return DetailContent(detail: state.signoutDetail!);
    }
    if (state is SignoutDetailError) {
      return ErrorWidget(message: state.message);
    }
    return EmptyWidget();
  },
)
```

## 错误处理

页面提供了完善的错误处理机制：

- **网络错误**: 显示错误信息并提供重试按钮
- **数据为空**: 显示友好的空状态提示
- **图片加载失败**: 显示替代图标和错误提示
- **参数错误**: 路由级别的参数验证

## 刷新功能

支持下拉刷新重新加载数据：

```dart
RefreshIndicator(
  onRefresh: () async {
    context.read<SignoutBloc>().add(LoadSignoutDetail(signinId: widget.signoutId));
  },
  child: SingleChildScrollView(...),
)
```

## 响应式设计

- 使用 `SingleChildScrollView` 支持垂直滚动
- 卡片式布局适配不同屏幕尺寸
- 图片网格使用 `GridView` 自动调整列数
- 文字大小和间距遵循 Material Design 规范

## 扩展建议

1. **添加分享功能**: 可以添加分享出库详情的功能
2. **导出功能**: 支持导出PDF或图片格式的详情报告
3. **打印功能**: 添加打印出库单的功能
4. **历史记录**: 记录用户查看的出库详情历史
5. **快速操作**: 添加快速复制、收藏等功能

## 注意事项

1. **权限控制**: 确保用户有权限查看对应的出库详情
2. **数据实时性**: 考虑添加实时数据更新机制
3. **网络优化**: 对图片加载进行优化，支持缓存
4. **无障碍访问**: 添加适当的语义化标签
5. **性能优化**: 对长列表进行懒加载优化

## 示例代码

完整的使用示例：

```dart
// 在记录列表页面中
class SignoutRecordItem extends StatelessWidget {
  final SignoutRecord record;
  
  const SignoutRecordItem({Key? key, required this.record}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.output, color: Colors.orange),
        title: Text('出库记录 #${record.id}'),
        subtitle: Text('仓库: ${record.warehouseName}'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // 导航到详情页面
          context.push('/signout-detail?id=${record.id}');
        },
      ),
    );
  }
}
```

## 总结

`SignoutDetailPage` 提供了一个完整、美观、易用的出库详情查看界面，可以无缝集成到现有的应用中。页面设计遵循了应用的整体风格，提供了良好的用户体验和完善的错误处理机制。
