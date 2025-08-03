<!--
 * @Author: LeeZB
 * @Date: 2025-08-03 15:32:29
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 15:34:10
 * @copyright: Copyright © 2025 高新供水.
-->
## QR扫描重复检查逻辑修改说明

### 问题描述
在报废页面进行扫码删除材料时，会显示"该耗材已添加，请勿重复扫描"的错误提示，即使扫码成功了。这是因为原来的逻辑通过解析context字符串来判断操作类型，在复杂导航场景下不够稳定。

### 解决方案
添加了一个明确的布尔字段 `isRemoveOperation` 来标识删除操作，而不是依赖字符串解析。

### 修改内容

#### 1. QrScanConfig 添加新字段
```dart
// 新增字段
final bool isRemoveOperation; // 默认为false
```

#### 2. 扫码页面逻辑简化
```dart
// 修改前：依赖字符串解析
bool _isRemoveOperation() {
  final source = widget.config.context?['source'] as String?;
  return source != null && 
         (source.contains('Remove') || 
          source.contains('remove') ||
          source.toLowerCase().contains('delete'));
}

// 修改后：直接使用布尔字段
bool _isRemoveOperation() {
  return widget.config.isRemoveOperation;
}
```

#### 3. 报废页面调用更新
```dart
// 扫码添加材料（保持不变）
final config = QrScanConfig(
  scanType: QrScanType.scrap,
  scanMode: QrScanMode.batch,
  context: {'source': 'scrapPage'},
  // isRemoveOperation默认为false
);

// 扫码删除材料（明确标记）
final config = QrScanConfig(
  scanType: QrScanType.scrap,
  scanMode: QrScanMode.batch,
  context: {'source': 'scrapPageRemove'},
  isRemoveOperation: true, // 明确标记为删除操作
);
```

### 效果
- ✅ **扫码删除**：不再显示重复扫描提示，可以正常扫描已存在的材料进行删除
- ✅ **扫码添加**：保持原有的重复检测功能
- ✅ **稳定性**：不依赖字符串解析，避免复杂导航场景下的判断错误
- ✅ **扩展性**：其他页面也可以使用这个字段来控制重复检测行为

### 测试验证
已添加单元测试验证JSON序列化/反序列化和默认值处理。
