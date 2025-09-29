# 带位置自动获取的水印相机功能说明

## 功能概述

现在 `ImageWatermarkUtils` 已经集成了 `LocationService`，可以在启用位置水印时自动获取当前 GPS 坐标并添加到水印中，无需手动传入位置文本。

## 主要改进

### 1. 自动位置获取
- 当 `includeLocationWatermark: true` 时，系统会自动调用 `LocationService.getCurrentLocation()` 获取当前位置
- 位置信息格式：`纬度, 经度`（保留4位小数，如：`30.5728, 104.0668`）
- 自动处理坐标转换（WGS84 → GCJ02）
- 如果位置获取失败，会显示 "位置信息获取失败"

### 2. 新的API方法

#### `addAutoWatermark()` - 推荐使用
```dart
String? watermarkedPath = await ImageWatermarkUtils.addAutoWatermark(
  imagePath,
  customText: '高新供水工程部',
  includeTime: true,
  includeLocation: true, // 自动获取位置
  textStyle: TextStyle(color: Colors.white, fontSize: 12),
);
```

#### `generateDefaultWatermarkText()` - 异步版本
```dart
String watermarkText = await ImageWatermarkUtils.generateDefaultWatermarkText(
  customText: '高新供水工程部',
  includeTime: true,
  includeLocation: true, // 自动获取位置
);
```

#### `generateDefaultWatermarkTextSync()` - 同步版本（预览用）
```dart
String watermarkText = ImageWatermarkUtils.generateDefaultWatermarkTextSync(
  customText: '高新供水工程部',
  includeTime: true,
  includeLocation: false, // 同步版本不支持自动位置获取
  locationText: '手动输入的位置', // 如果需要位置，需手动提供
);
```

### 3. 向后兼容性
- `locationText` 参数仍然保留，但已标记为废弃
- 如果同时提供了 `locationText` 和 `includeLocation: true`，会优先使用 `locationText`
- 现有代码无需修改即可继续工作

## 使用示例

### ImageUploadWidget 中的使用
```dart
ImageUploadWidget(
  title: '工程照片',
  states: uploadStates,
  onAdd: onAddImages,
  onRemove: onRemoveImage,
  onRetry: onRetryUpload,
  enableWatermark: true,
  watermarkText: '高新供水工程部',
  includeTimeWatermark: true,
  includeLocationWatermark: true, // 启用自动位置获取
  // locationText 参数不再需要，位置会自动获取
)
```

### WatermarkCameraPage 中的改进
- 预览时使用同步方法快速显示水印（不包含实时位置）
- 拍照时使用异步方法获取精确位置信息并添加到最终图片

## 权限要求

确保应用已申请位置权限：
- Android: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- iOS: `NSLocationWhenInUseUsageDescription`

`LocationService` 会自动处理权限请求和错误处理。

## 位置信息格式

自动获取的位置信息格式为：`纬度, 经度`
- 示例：`30.5728, 104.0668`
- 坐标系：GCJ02（火星坐标系）
- 精度：保留4位小数

## 错误处理

- 位置服务未开启：不添加位置信息
- 位置权限被拒绝：不添加位置信息
- 网络超时：显示 "位置信息获取失败"
- GPS 信号弱：可能显示缓存的位置（10秒内）

## 性能优化

- 位置信息有10秒缓存，避免频繁请求
- 异步获取位置，不阻塞UI
- 支持超时设置（默认10秒）

## 迁移指南

### 从旧版本迁移
1. 移除手动传入的 `locationText` 参数
2. 设置 `includeLocationWatermark: true` 启用自动位置获取
3. 确保应用已申请位置权限

### 保持兼容性
如果暂时不想使用自动位置获取，可以：
1. 保持 `includeLocationWatermark: false`
2. 继续使用 `locationText` 参数手动提供位置信息
