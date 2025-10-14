# 安装页面异常材料处理实现总结

## 概述

本次更新为安装页面添加了异常材料（errors）的处理和展示功能。与验收页面的集合展示方式不同，安装页面由于其业务特殊性，需要将每次扫码的结果（包括正常材料和异常材料）单独展示在各自区域。

## 实现方案

### 1. 数据结构设计

#### ScanResult 类（新增）
```dart
/// 单次扫码结果，包含正常材料和异常材料
class ScanResult extends Equatable {
  const ScanResult({
    this.normalMaterial,
    this.errorMaterial,
    required this.scanTime,
  });

  /// 正常材料（如果扫描成功）
  final MaterialInfo? normalMaterial;

  /// 异常材料信息（如果扫描失败）
  final dynamic errorMaterial;

  /// 扫描时间戳，用于排序和唯一标识
  final DateTime scanTime;
}
```

**设计要点：**
- 封装单次扫码的完整结果
- `normalMaterial` 和 `errorMaterial` 互斥，只有一个会有值
- `scanTime` 用于维护扫码顺序和唯一标识每次扫码操作

### 2. 状态管理更新

#### InstallState 修改
在 `InstallReady` 状态中新增 `scanResults` 字段：

```dart
class InstallReady extends InstallState {
  const InstallReady({
    this.detail,
    this.materialInfos,  // 保留用于向后兼容
    this.scanResults = const [],  // 新增
    this.materialScanMessage,
    this.clearScanMessage = true,
  });

  /// 所有扫码结果列表（包含正常和异常材料），按扫描顺序排列
  final List<ScanResult> scanResults;
}
```

### 3. BLoC 逻辑更新

#### InstallBloc._onAppendScannedMaterial 方法重构

**原逻辑：**
- 仅处理 `normals` 列表
- 忽略 `errors` 列表

**新逻辑：**
```dart
Future<void> _onAppendScannedMaterial(
  AppendScannedMaterial event,
  Emitter<InstallState> emit,
) async {
  final currentState = state;
  if (currentState is InstallReady) {
    final scanTime = DateTime.now();
    final updatedScanResults = List<ScanResult>.from(currentState.scanResults);

    // 处理正常材料
    if (event.materialInfo.normals.isNotEmpty) {
      final material = event.materialInfo.normals.first;
      
      // 检查是否已存在（基于 materialId 去重）
      final existingMaterialIds = currentState.scanResults
          .where((r) => r.normalMaterial != null)
          .map((r) => r.normalMaterial!.baseInfo.materialId)
          .toSet();

      if (existingMaterialIds.contains(material.baseInfo.materialId)) {
        // 发出提示：材料已存在
        emit(currentState.copyWith(
          materialScanMessage: '材料已经匹配过了',
          clearScanMessage: false,
        ));
        return;
      }

      // 添加到扫码结果
      updatedScanResults.add(ScanResult(
        normalMaterial: material,
        scanTime: scanTime,
      ));
    }
    // 处理异常材料
    else if (event.materialInfo.errors.isNotEmpty) {
      for (final error in event.materialInfo.errors) {
        updatedScanResults.add(ScanResult(
          errorMaterial: error,
          scanTime: scanTime,
        ));
      }
      
      emit(currentState.copyWith(
        materialScanMessage: '扫描到异常材料',
        clearScanMessage: false,
      ));
    }

    // 更新状态
    emit(newReadyState);
  }
}
```

**关键改进：**
1. 同时处理正常材料和异常材料
2. 维护扫码顺序（通过 `scanTime`）
3. 每次扫码都记录独立的 `ScanResult`
4. 保持向后兼容性（更新 `materialInfos`）

### 4. UI 展示实现

#### 主渲染方法
```dart
Widget _buildScanResultsList(List<ScanResult> scanResults) {
  return Column(
    children: scanResults.map((scanResult) {
      if (scanResult.normalMaterial != null) {
        // 渲染正常材料
        return _buildMaterialItem(materialVO);
      } else if (scanResult.errorMaterial != null) {
        // 渲染异常材料
        return _buildErrorMaterialItem(scanResult.errorMaterial);
      }
      return const SizedBox.shrink();
    }).toList(),
  );
}
```

#### 异常材料卡片
```dart
Widget _buildErrorMaterialItem(dynamic error) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: ErrorMaterialSection(
      errors: [error],
      title: '扫码异常',
      collapsible: false,  // 不可折叠
      onErrorItemTap: _handleErrorMaterialTap,
    ),
  );
}
```

**与验收页面的区别：**

| 特性             | 验收页面                               | 安装页面                             |
|------------------|----------------------------------------|--------------------------------------|
| 异常材料展示方式 | 集合展示（所有异常材料在一个可折叠区域） | 单独展示（每次扫码的异常材料独立显示） |
| 可折叠性         | `collapsible: true`                    | `collapsible: false`                 |
| 初始展开状态     | `initialExpanded: true`                | 不适用                               |
| 位置             | 材料列表底部                           | 与正常材料混排，按扫码顺序            |

## 用户体验

### 扫码流程
1. **扫码成功**：
   - 正常材料卡片显示在列表中
   - 可输入桩号、上传照片

2. **扫码异常**：
   - 红色警告卡片立即显示
   - 提示 "扫描到异常材料"
   - 卡片显示错误信息（二维码、供应商信息、错误原因）
   - 点击卡片查看详细信息

3. **继续扫码**：
   - 新的扫码结果追加到列表底部
   - 保持历史扫码记录的顺序

### 视觉效果
- 正常材料：蓝色主题卡片
- 异常材料：红色警告卡片
- 每次扫码结果独立展示，清晰区分

## 代码文件变更

### 修改的文件
1. **lib/bloc/install/install_state.dart**
   - 新增 `ScanResult` 类
   - 在 `InstallReady` 中添加 `scanResults` 字段

2. **lib/bloc/install/install_bloc.dart**
   - 重构 `_onAppendScannedMaterial` 方法
   - 同时处理正常材料和异常材料
   - 维护扫码历史记录

3. **lib/pages/install/install_page.dart**
   - 新增 `_buildScanResultsList` 方法
   - 新增 `_buildErrorMaterialItem` 方法
   - 新增 `_handleErrorMaterialTap` 方法
   - 新增 `_getErrorField` 和 `_buildErrorField` 辅助方法
   - 更新 `_buildContent` 使用新的渲染逻辑

### 依赖组件
- `ErrorMaterialSection`（来自 `unified_components.dart`）
- `MaterialInfoForBusiness`（保持向后兼容）
- `SyncVendorDataError`（异常材料数据模型）

## 技术特点

1. **状态不可变性**：使用 `copyWith` 确保状态更新的不可变性
2. **类型安全**：使用 Equatable 确保状态比较的准确性
3. **向后兼容**：保留 `materialInfos` 字段，确保现有代码不受影响
4. **扩展性**：`ScanResult` 设计支持未来添加更多扫码元数据
5. **用户反馈**：扫码后立即给予视觉和文本反馈

## 测试建议

### 功能测试
1. 扫描正常材料 → 验证材料卡片正确显示
2. 扫描异常材料 → 验证红色警告卡片显示
3. 混合扫描（正常+异常） → 验证顺序正确
4. 重复扫描正常材料 → 验证去重提示
5. 点击异常材料卡片 → 验证详情对话框

### UI 测试
1. 验证异常材料卡片视觉样式
2. 验证扫码顺序保持正确
3. 验证滚动流畅性
4. 验证提交按钮逻辑（异常材料不影响提交）

### 边界测试
1. 连续扫描多个异常材料
2. 异常材料字段为空的情况
3. 大量扫码结果的性能

## 后续优化建议

1. **批量操作**：添加"清除所有异常材料"功能
2. **过滤功能**：提供"仅显示异常"的过滤器
3. **统计信息**：在顶部显示正常/异常材料数量
4. **持久化**：考虑将扫码历史保存到本地
5. **导出功能**：支持导出异常材料清单

## 总结

本次实现成功为安装页面添加了异常材料处理功能，关键特点是**单独展示每次扫码的结果**，与验收页面的**集合展示**形成区分。这种设计更符合安装业务的实际场景，让用户能清楚地看到每次扫码的具体结果，提升了用户体验和问题排查效率。
