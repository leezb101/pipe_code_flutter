# 安装页面扫码剔除 - 快速参考

## 快速开始

### 用户操作流程

```
1. 进入安装页面
   ↓
2. 扫码添加材料（可多次）
   ↓
3. 发现有材料需要剔除
   ↓
4. 点击"扫码剔除"按钮
   ↓
5. 扫描要剔除的材料二维码
   ↓
6. 自动返回，Toast 显示剔除结果
   ↓
7. 继续扫码或提交安装
```

## 代码调用示例

### 触发剔除

```dart
// 方式 1：通过 UI 触发（推荐）
void _navigateToQrScanForRemoval(BuildContext context) {
  final config = QrScanConfig(
    title: '扫码剔除',
    scanMode: QrScanMode.single,
    operation: QrScanOperation.remove,
  );

  context.pushNamed('qr-scan', extra: config).then((result) {
    if (mounted && result != null && result is List<QrScanResult>) {
      final codes = result
          .where((r) => r.code.isNotEmpty)
          .map((r) => r.code)
          .toList();

      if (codes.isNotEmpty) {
        context.read<InstallBloc>().add(
          RemoveScannedMaterialsByCodes(codes: codes),
        );
      }
    }
  });
}

// 方式 2：直接调用 BLoC（测试或特殊场景）
context.read<InstallBloc>().add(
  RemoveScannedMaterialsByCodes(
    codes: ['QR123', 'QR456'],
  ),
);
```

### 监听剔除结果

```dart
BlocListener<InstallBloc, InstallState>(
  listener: (context, state) {
    if (state is InstallReady && state.materialScanMessage != null) {
      // 显示剔除结果消息
      context.showInfoToast(state.materialScanMessage!);
    }
  },
  child: ...,
)
```

## UI 组件

### 按钮组件

```dart
// 在 _buildContent 中添加按钮
Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('继续扫码'),
        onPressed: () => _navigateToQrScan(context),
      ),
    ),
    if (scannedMaterials.isNotEmpty) ...[
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.remove_circle_outline),
          label: const Text('扫码剔除'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.warningColor,
          ),
          onPressed: () => _navigateToQrScanForRemoval(context),
        ),
      ),
    ],
  ],
)
```

## 状态管理

### 状态变化流程

```
扫码剔除前:
InstallReady(
  scanResults: [
    ScanResult(normalMaterial: Material_A, scanTime: T1),
    ScanResult(normalMaterial: Material_B, scanTime: T2),
    ScanResult(errorMaterial: Error_C, scanTime: T3),
  ],
)

↓ 扫码剔除 Material_B

扫码剔除后:
InstallReady(
  scanResults: [
    ScanResult(normalMaterial: Material_A, scanTime: T1),
    ScanResult(errorMaterial: Error_C, scanTime: T3),
  ],
  materialScanMessage: '已剔除 1 个正常材料',
)
```

## 错误处理

### 常见错误场景

```dart
// 1. 扫描不存在的材料
Toast: "忽略未在列表 1 个"

// 2. 网络请求失败
Toast: "剔除材料失败，请重试"

// 3. 扫描空码
// 自动过滤，不会触发剔除

// 4. 重复剔除
// 第一次：成功剔除
// 第二次：Toast 显示 "忽略未在列表 1 个"
```

## 测试命令

### 单元测试

```bash
# 测试 BLoC 剔除逻辑
flutter test test/bloc/install/install_bloc_test.dart --name "RemoveScannedMaterialsByCodes"

# 测试特定场景
flutter test test/bloc/install/install_bloc_test.dart --name "should remove normal material"
flutter test test/bloc/install/install_bloc_test.dart --name "should remove error material"
```

### Widget 测试

```bash
# 测试 UI 组件
flutter test test/pages/install/install_page_test.dart --name "remove button"
```

### 集成测试

```bash
# 测试完整流程
flutter test integration_test/install_removal_test.dart
```

## 调试技巧

### 打印调试信息

```dart
// 在 _onRemoveScannedMaterialsByCodes 中添加
print('剔除前材料数量: ${currentState.scanResults.length}');
print('要剔除的码: $codes');
print('剔除后材料数量: ${updatedScanResults.length}');
print('剔除统计: 正常=$removedNormal, 异常=$removedError');
```

### 使用 Logger

```dart
import 'package:pipe_code_flutter/utils/logger.dart';

// 在关键位置添加日志
Logger.debug('开始剔除材料: $codes', tag: 'InstallBloc');
Logger.info('剔除成功: $message', tag: 'InstallBloc');
Logger.error('剔除失败: $e', tag: 'InstallBloc');
```

## 性能优化建议

### 1. 避免重复遍历

```dart
// ❌ 不好的做法
for (final id in idsToRemove) {
  updatedScanResults.removeWhere(
    (r) => r.normalMaterial?.baseInfo.materialId == id,
  );
}

// ✅ 好的做法
for (final id in idsToRemove) {
  final index = updatedScanResults.indexWhere(
    (r) => r.normalMaterial?.baseInfo.materialId == id,
  );
  if (index != -1) {
    updatedScanResults.removeAt(index);
  }
}
```

### 2. 批量操作优化

```dart
// 如果需要剔除多个材料，考虑批量收集索引
final indicesToRemove = <int>[];
for (final id in idsToRemove) {
  final index = updatedScanResults.indexWhere(...);
  if (index != -1) {
    indicesToRemove.add(index);
  }
}

// 从后向前删除，避免索引偏移
indicesToRemove.sort((a, b) => b.compareTo(a));
for (final index in indicesToRemove) {
  updatedScanResults.removeAt(index);
}
```

## 常见问题 FAQ

### Q1: 剔除按钮什么时候显示？
**A:** 当 `scanResults` 非空时显示。即至少有一个材料（正常或异常）时。

### Q2: 可以批量剔除吗？
**A:** 当前实现是单次扫码剔除。如需批量剔除，修改 `QrScanConfig`:
```dart
final config = QrScanConfig(
  scanMode: QrScanMode.batch,  // 改为批量模式
  operation: QrScanOperation.remove,
);
```

### Q3: 剔除后顺序会变吗？
**A:** 不会。使用 `removeAt` 删除，保持剩余材料的扫码顺序。

### Q4: 异常材料可以剔除吗？
**A:** 可以。支持剔除正常材料和异常材料。

### Q5: 剔除失败会怎样？
**A:** 显示错误 Toast，状态不变，用户可以重试。

### Q6: 能撤销剔除吗？
**A:** 当前版本不支持。需要重新扫码添加。

### Q7: 剔除后提交按钮状态会更新吗？
**A:** 会。`_recomputeCanSubmit()` 会重新计算提交条件。

### Q8: 如何清理剔除材料的资源？
**A:** 当前未实现。建议在剔除后清理对应的 Cubit 和控制器：
```dart
// 清理照片上传 Cubit
_materialPhotoCubits[materialId]?.close();
_materialPhotoCubits.remove(materialId);

// 清理桩号控制器
_stakeNumberControllers[materialId]?.dispose();
_stakeNumberControllers.remove(materialId);
```

## 相关文档

- [完整实现说明](./INSTALL_SCAN_REMOVAL_IMPLEMENTATION.md)
- [与验收页面对比](./SCAN_REMOVAL_COMPARISON_ACCEPTANCE_VS_INSTALL.md)
- [安装页面异常材料处理](./INSTALL_ERROR_MATERIAL_INTEGRATION_SUMMARY.md)

## 版本历史

- **v1.0** (2025-10-14): 初始实现
  - 支持扫码剔除正常材料
  - 支持扫码剔除异常材料
  - 保持扫码顺序
  - 详细的统计反馈

## 贡献者

- 实现参考：验收页面扫码剔除功能
- 技术栈：Flutter BLoC + Repository Pattern
- 业务适配：安装页面独立展示特性
