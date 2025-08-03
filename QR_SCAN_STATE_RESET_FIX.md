## QR扫描状态管理修复说明

### 问题分析
在复杂导航场景下，QrScanPage和QrScanBloc可能没有被正确释放，导致：
1. 配置信息在不同页面间共享和混乱
2. `isRemoveOperation`等字段读取到错误的缓存值
3. 扫码状态在多次进入/退出后出现混乱

### 解决方案
实施了多层状态清理机制，确保每次进入扫码页面都是干净的状态：

#### 1. **页面级清理（initState/dispose）**
```dart
// initState: 重置所有本地状态变量
_sessionScannedCodes.clear();
_lastScannedCode = null;
_lastScanTime = null;
_hasReturned = false;
_isTemporarilyPaused = false;

// dispose: 发送重置事件清理bloc状态
context.read<QrScanBloc>().add(const ResetScan());
```

#### 2. **Bloc级完全重置**
```dart
// InitializeScan: 先完全重置，再设置新配置
emit(const QrScanState()); // 清空所有状态
emit(QrScanState(status: QrScanStatus.scanning, config: event.config, ...));

// ResetScan: 完全重置到初始状态
emit(const QrScanState()); // 包括清理config
```

#### 3. **数据传递后立即清理**
```dart
// 在popWithResult和handleNavigation中
context.read<QrScanBloc>().add(const ResetScan());
```

### 修复的问题
- ✅ **配置混乱**：每次进入都会获得正确的config值
- ✅ **状态污染**：不再受之前扫码会话影响
- ✅ **重复检测错误**：`isRemoveOperation`等字段始终读取正确值
- ✅ **生命周期问题**：即使bloc未释放也能保证状态干净

### 验证方案
1. 从home页面 → scrap页面 → 扫码添加 → 返回scrap → 再次扫码添加
2. 检查`isRemoveOperation`的值是否始终正确
3. 检查重复扫码提示是否正常工作
4. 验证扫码删除功能是否不受影响

这种多层清理机制确保了无论bloc是否被正确释放，每次进入扫码页面都会有干净的状态。
