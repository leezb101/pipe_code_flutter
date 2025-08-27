# SignoutDetailPage 功能增强

## 更新概述

基于您的反馈，我们为 `signout_detail_page.dart` 添加了以下缺失的功能：

### 1. MaterialVO 安装信息显示

#### 新增功能：
- **安装桩号显示**：当 `installPileNo` 不为空时，显示安装桩号信息
- **安装照片预览**：展示 `installImageUrl1` 和 `installImageUrl2` 的缩略图
- **图片点击预览**：点击缩略图可以查看大图，支持缩放操作

#### 实现细节：
```dart
// 安装桩号信息
if (material.installPileNo != null) ...[
  Row(
    children: [
      Icon(Icons.location_on, size: 16, color: Colors.green[600]),
      Text('安装桩号: ${material.installPileNo}'),
    ],
  ),
]

// 安装照片展示
if (material.installImageUrl1 != null || material.installImageUrl2 != null) ...[
  Row(
    children: [
      if (material.installImageUrl1 != null)
        _buildImagePreview(material.installImageUrl1!, '安装照片1'),
      if (material.installImageUrl2 != null)
        _buildImagePreview(material.installImageUrl2!, '安装照片2'),
    ],
  ),
]
```

### 2. PDF 文档预览功能

#### 新增功能：
- **PDF文档预览**：为 `installQualityUrl` 添加了PDF文档查看功能
- **交互式界面**：点击文档区域可以打开PDF预览器
- **用户体验优化**：使用PDF图标和提示文本引导用户操作

#### 实现细节：
```dart
GestureDetector(
  onTap: () => _showPdfViewer(installInfo.installQualityUrl!, '安装质量文档'),
  child: Container(
    // PDF文档显示区域
    child: Row(
      children: [
        Icon(Icons.picture_as_pdf), // PDF图标
        Text('点击查看PDF文档'),     // 提示文本
        Icon(Icons.open_in_new),    // 打开图标
      ],
    ),
  ),
)
```

### 3. 新增辅助方法

#### `_buildImagePreview(String imageUrl, String label)`
- 创建80x80的图片缩略图
- 支持加载状态和错误状态显示
- 点击触发图片查看器

#### `_showImageViewer(String imageUrl, String title)`
- 全屏图片查看器
- 支持手势缩放和拖拽
- 显示图片标题和关闭按钮

#### `_showPdfViewer(String pdfUrl, String title)`
- 使用 `PdfPreviewer` 组件打开PDF文档
- 支持PDF文档的查看和操作

### 4. 条件渲染逻辑

考虑到安装发生在出库之后，实现了智能的条件渲染：

```dart
// 只有当安装桩号存在时才显示
if (material.installPileNo != null) ...

// 只有当安装图片存在时才显示
if (material.installImageUrl1 != null || material.installImageUrl2 != null) ...

// 只有当安装质量文档存在时才显示
if (installInfo.installQualityUrl != null) ...
```

### 5. UI 优化

#### 视觉改进：
- 使用绿色主题表示安装相关信息
- 添加位置图标表示桩号信息
- 使用PDF图标和打开图标提升用户体验
- 保持与现有UI风格的一致性

#### 用户体验：
- 缩略图大小适中（80x80）便于预览
- 加载状态和错误状态的友好提示
- 全屏图片查看器支持自由缩放
- PDF文档在单独页面中打开

## 参考实现

本次更新参考了 `install_detail_page.dart` 的以下实现模式：
- 图片预览组件的设计
- PDF预览器的使用方式
- 条件渲染的处理逻辑
- UI组件的样式规范

## 使用说明

1. **查看安装桩号**：在物料列表中，如果物料已安装，会显示绿色的安装桩号信息
2. **预览安装照片**：点击安装照片缩略图可以查看大图
3. **查看安装质量文档**：在安装信息部分点击PDF文档区域可以预览文档

## 注意事项

- 所有新功能都采用了条件渲染，只有在相关数据存在时才会显示
- 图片和PDF的加载错误都有相应的错误处理机制
- UI设计保持了与其他页面的一致性和用户体验的连贯性
