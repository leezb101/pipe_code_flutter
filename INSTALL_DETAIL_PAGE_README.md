# 安装记录详情页面实现说明

## 概述

已成功实现 `InstallDetailPage` 安装记录详情页面，用于展示安装记录的详细信息。

## 实现内容

### 1. 页面文件
- **文件路径**: `/lib/pages/install/install_detail_page.dart`
- **功能**: 纯展示页面，显示安装记录的详细信息，不包含任何交互操作

### 2. 数据支持
- **数据模型**: 使用 `InstallDetailVo` (继承自 `DoInstallVo`)
- **Bloc 层**: 复用现有的 `InstallBloc`，已支持 `LoadInstallDetail` 和 `RefreshInstallDetail` 事件
- **状态管理**: 使用 `InstallReady` 状态中的 `detail` 字段

### 3. 路由配置
- **路由名称**: `install-detail`
- **路径**: `/install-detail?id={installId}`
- **参数**: 通过查询参数传递 `installId`

## 页面功能

### 展示内容
1. **安装信息**
   - 安装类型（仅安装/签出后安装）
   - 签出单ID（如果适用）
   - 物料数量统计
   - 附件数量统计

2. **物料清单**
   - 物料名称和数量
   - 物料ID
   - 安装桩号（带图标显示）
   - 安装照片预览（支持点击放大查看）

3. **相关附件**
   - 附件列表展示
   - 支持图片预览
   - 支持PDF文档查看
   - 不同文件类型的图标区分

4. **质量验收报告**
   - 质量验收文档链接
   - 支持PDF预览

### 交互功能
- **下拉刷新**: 支持下拉刷新数据
- **图片预览**: 点击图片可全屏查看
- **PDF查看**: 使用内置PDF预览器查看文档
- **错误处理**: 加载失败时支持重试

## 使用方式

### 导航到详情页面
```dart
// 使用 GoRouter 导航
context.pushNamed('install-detail', queryParameters: {'id': '123'});

// 或者使用 GoRouter 推送
context.push('/install-detail?id=123');
```

### BlocProvider 注入
页面自动处理 `InstallBloc` 的注入，无需手动提供。

## 技术实现

### 状态管理
- 使用 `BlocBuilder` 和 `BlocListener` 处理状态变化
- 支持加载中、成功、失败状态的UI展示
- 实现下拉刷新功能

### UI组件
- 使用 `Card` 组件分组展示信息
- 使用 `Container` 和装饰器美化物料展示
- 使用 `InteractiveViewer` 实现图片缩放功能
- 集成现有的 `PdfPreviewer` 组件

### 错误处理
- 网络图片加载失败时显示占位图标
- PDF文件访问失败时的友好提示
- 数据加载失败时的重试机制

## 依赖的现有组件
- `InstallBloc`: 数据获取和状态管理
- `PdfPreviewer`: PDF文档预览
- `common.LoadingWidget`: 加载状态展示
- `common.ErrorWidget`: 错误状态展示

## 扩展建议

如需添加交互功能，可以考虑：
1. 在物料详情中添加编辑功能
2. 支持添加备注信息
3. 支持导出功能
4. 支持分享功能

## 注意事项

1. 页面为纯展示页面，不包含任何数据修改操作
2. 所有图片和PDF的预览依赖网络连接
3. 页面会自动处理数据为空的情况
4. 支持Material Design的下拉刷新交互
