# 错误材料剔除功能增强

## 问题描述
用户在使用acceptance页面进行扫码剔除操作时，发现扫到异常材料的二维码时，无法将其从异常材料列表中剔除，只能剔除正常材料。

## 解决方案
修改`AcceptanceBloc`中的`_onRemoveEditingMaterialsByCodes`方法，增加对错误材料的剔除处理。

### 核心改进
1. **双重剔除逻辑**：同时处理正常材料和错误材料的剔除
2. **QR码匹配**：使用`_getErrorQrCode`辅助方法进行错误材料的精确匹配
3. **详细反馈**：提供分类的剔除结果信息（正常材料、异常材料、未匹配项）

### 代码变更要点

#### 原有逻辑
- 只处理`rsp.data!.normals`中的材料剔除
- 只更新`currentMaterials`和`materialIds`
- 简单的数量统计

#### 新增逻辑
```dart
// 处理错误材料的剔除
final currentErrors = List<dynamic>.from(editing.errorMaterials);
int removedError = 0;
int unmatchedError = 0;

for (final scannedError in rsp.data!.errors) {
  final scannedQrCode = _getErrorQrCode(scannedError);
  bool found = false;
  
  for (int i = currentErrors.length - 1; i >= 0; i--) {
    final existingQrCode = _getErrorQrCode(currentErrors[i]);
    if (existingQrCode == scannedQrCode && scannedQrCode.isNotEmpty) {
      currentErrors.removeAt(i);
      removedError++;
      found = true;
      break;
    }
  }
  
  if (!found) {
    unmatchedError++;
  }
}
```

#### 消息构建改进
```dart
final messages = <String>[];
if (removedNormal > 0) {
  messages.add('已剔除 $removedNormal 个正常材料');
}
if (removedError > 0) {
  messages.add('已剔除 $removedError 个异常材料');
}
if (unmatchedNormal > 0 || unmatchedError > 0) {
  final total = unmatchedNormal + unmatchedError;
  messages.add('忽略未在页面 $total 个');
}
```

### 其他修复
- 修复`AppendEditingMaterialsByCodes`中默认`AcceptanceEditingState`构造缺少`errorMaterials`字段的问题
- 确保所有状态构造都包含完整的字段

## 功能验证
现在用户可以：
1. 扫码剔除正常材料（原有功能）
2. 扫码剔除异常材料（新增功能）
3. 获得详细的剔除操作反馈
4. 混合扫码时同时剔除正常和异常材料

## 影响范围
- `lib/bloc/acceptance/acceptance_bloc.dart`：核心业务逻辑修改
- 用户体验：完善了异常材料的管理流程
- 数据一致性：确保UI和state的同步更新
