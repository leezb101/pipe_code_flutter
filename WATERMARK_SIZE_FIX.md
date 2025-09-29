# 水印大小统一修复说明

## 问题描述
之前在拍照预览时看到的水印比较大，但生成的图片中水印很小，大约只有预览时的1/4大小。这是因为：

1. **预览水印字体大小固定**：预览界面使用固定的16像素字体
2. **实际图片水印字体大小固定**：生成图片时使用固定的12像素字体  
3. **分辨率差异未考虑**：相机预览分辨率和实际拍摄分辨率差异很大

## 解决方案

### 1. 动态字体大小计算
现在系统会根据图片实际分辨率动态计算合适的水印字体大小：

```dart
// 根据图片宽度动态计算字体大小
// 以1080p为基准（1920x1080），字体大小为36
final double baseFontSize = (originalImage.width / 1920.0) * 36.0;
final double fontSize = baseFontSize.clamp(24.0, 72.0); // 限制范围
```

### 2. 预览界面字体大小适配
预览界面也会根据相机分辨率计算合适的字体大小：

```dart
// 根据相机预览尺寸计算预览水印字体大小
// 以720p（1280x720）为基准，字体大小为16
final double fontSize = (baseSize / 720.0) * 16.0;
```

### 3. 字体大小范围限制
- **实际图片水印**：字体大小限制在 24-72 像素之间
- **预览界面水印**：字体大小限制在 12-24 像素之间

## 分辨率适配表

| 图片分辨率 | 基准比例 | 水印字体大小 | 说明               |
|------------|----------|--------------|--------------------|
| 1920x1080  | 1.0x     | 36px         | 1080p标准          |
| 3840x2160  | 2.0x     | 72px         | 4K分辨率           |
| 1280x720   | 0.67x    | 24px         | 720p分辨率         |
| 640x480    | 0.33x    | 24px         | 低分辨率（最小限制） |

## 代码改进

### addAutoWatermark() 方法改进
```dart
// 现在会自动计算字体大小，无需手动指定
final String? watermarkedImagePath = await ImageWatermarkUtils.addAutoWatermark(
  imagePath,
  customText: widget.watermarkText,
  includeTime: widget.includeTimeWatermark,
  includeLocation: widget.includeLocationWatermark,
  // textStyle 参数被移除，系统自动计算合适大小
);
```

### 相机预览界面改进
```dart
// 动态计算预览水印字体大小
final double previewFontSize = _calculatePreviewFontSize(state.controller!);

return CameraPreviewWithWatermark(
  controller: state.controller!,
  watermarkText: _watermarkDisplayText,
  watermarkStyle: TextStyle(
    color: Colors.white,
    fontSize: previewFontSize, // 使用动态计算的大小
    fontWeight: FontWeight.w500,
  ),
);
```

## 测试建议

在不同设备上测试水印效果：

1. **低分辨率设备**（720p相机）
   - 预览水印：约12-16px
   - 实际水印：约24-32px

2. **中等分辨率设备**（1080p相机）
   - 预览水印：约16px
   - 实际水印：约36px

3. **高分辨率设备**（4K相机）
   - 预览水印：约20-24px
   - 实际水印：约72px

## 向后兼容性

- 如果手动指定了 `textStyle` 参数，系统仍然会使用指定的样式
- 只是在字体大小上会根据图片分辨率进行调整
- 现有代码无需修改即可获得改进效果

## 预期效果

修复后，用户在拍照预览时看到的水印大小与最终生成图片中的水印大小应该保持视觉一致性，不再出现大小差异过大的问题。
