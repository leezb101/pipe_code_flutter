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
（历史方案）曾临时增加 isRemoveOperation；现已用统一的 `operation: QrScanOperation.remove` 取代。

### 修改内容

#### 1. QrScanConfig 统一字段
使用 `operation` 枚举： initial / append / remove。

#### 2. 扫码页面逻辑
直接判断 `config.operation == QrScanOperation.remove`，无需上下文字符串或布尔兼容字段。

#### 3. 报废页面调用更新示例
```dart
final result = await flow.startScan(QrScanFlowRequest(
  operation: QrScanOperation.remove,
  currentCodes: existingCodes,
  scanType: QrScanType.scrap,
  batch: true,
));
```

### 效果
- ✅ **扫码删除**：operation=remove 时允许扫描已存在的码
- ✅ **扫码添加**：append/initial 保持重复过滤
- ✅ **稳定性**：不再依赖上下文字符串或临时布尔标志
- ✅ **扩展性**：统一入口便于新增模式

### 测试验证
后续计划：补充针对 QrScanFlowService append/remove 的单元测试。
