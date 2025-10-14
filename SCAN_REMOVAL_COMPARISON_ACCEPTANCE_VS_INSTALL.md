# 扫码剔除功能对比：验收页面 vs 安装页面

## 核心差异总结

| 维度         | 验收页面                                        | 安装页面                      |
|--------------|-------------------------------------------------|-------------------------------|
| **数据结构** | 分离存储（`currentMaterials` + `errorMaterials`） | 统一存储（`scanResults`）       |
| **展示方式** | 集合展示                                        | 独立卡片展示                  |
| **剔除实现** | 集合过滤（`where`）                               | 索引删除（`removeAt`）          |
| **顺序要求** | 不强调顺序                                      | 严格保持扫码顺序              |
| **扫码模式** | 批量扫码（`QrScanMode.batch`）                    | 单次扫码（`QrScanMode.single`） |
| **UI 按钮**  | 独立按钮组（继续扫码、扫码剔除）                   | 水平排列两按钮                |

## 数据结构对比

### 验收页面数据结构

```dart
class AcceptanceEditingState {
  // 正常材料列表
  final List<MaterialInfo> currentMaterials;
  
  // 材料ID集合（用于快速查重）
  final Set<int> materialIds;
  
  // 异常材料列表
  final List<dynamic> errorMaterials;
  
  // 其他状态字段...
}
```

**特点：**
- 正常材料和异常材料分开存储
- 使用 Set 维护 ID 集合用于去重
- 无时序信息

### 安装页面数据结构

```dart
class InstallReady {
  // 所有扫码结果（统一存储）
  final List<ScanResult> scanResults;
  
  // 向后兼容字段
  final MaterialInfoForBusiness? materialInfos;
}

class ScanResult {
  final MaterialInfo? normalMaterial;  // 正常材料
  final dynamic errorMaterial;         // 异常材料（互斥）
  final DateTime scanTime;             // 扫描时间
}
```

**特点：**
- 正常材料和异常材料统一存储在 `ScanResult` 中
- 每个 `ScanResult` 包含扫描时间戳
- 严格按扫码顺序排列

## 剔除逻辑对比

### 验收页面剔除逻辑

```dart
Future<void> _onRemoveEditingMaterialsByCodes(
  RemoveEditingMaterialsByCodes event,
  Emitter<AcceptanceState> emit,
) async {
  // 1. 解析扫码结果
  final rsp = await _materialHandleRepository.scanBatchToQueryAll(
    event.codes,
  );

  // 2. 剔除正常材料（集合过滤）
  final idsToRemove = rsp.data!.normals
      .map((m) => m.baseInfo.materialId)
      .toSet();
      
  final newList = editing.currentMaterials
      .where((m) => !idsToRemove.contains(m.baseInfo.materialId))
      .toList();
  
  final newIds = Set<int>.from(editing.materialIds)
    ..removeAll(idsToRemove);

  // 3. 剔除异常材料（遍历删除）
  final currentErrors = List<dynamic>.from(editing.errorMaterials);
  for (final scannedError in rsp.data!.errors) {
    final scannedQrCode = _getErrorQrCode(scannedError);
    
    for (int i = currentErrors.length - 1; i >= 0; i--) {
      final existingQrCode = _getErrorQrCode(currentErrors[i]);
      if (existingQrCode == scannedQrCode && scannedQrCode.isNotEmpty) {
        currentErrors.removeAt(i);
        removedError++;
        break;
      }
    }
  }

  // 4. 发出新状态
  emit(
    editing.copyWith(
      currentMaterials: newList,
      materialIds: newIds,
      errorMaterials: currentErrors,
      message: msg,
    ),
  );
}
```

**关键特点：**
- **集合过滤**：使用 `where` 过滤掉要剔除的材料
- **不关心顺序**：过滤后的列表顺序仍然有效但不是重点
- **分别处理**：正常材料和异常材料分别处理
- **统计简单**：主要统计剔除数量和未匹配数量

### 安装页面剔除逻辑

```dart
Future<void> _onRemoveScannedMaterialsByCodes(
  RemoveScannedMaterialsByCodes event,
  Emitter<InstallState> emit,
) async {
  // 1. 解析扫码结果
  final rsp = await _materialHandleRepository.scanBatchToQueryAll(
    event.codes,
  );

  final updatedScanResults = List<ScanResult>.from(currentState.scanResults);

  // 2. 剔除正常材料（按索引删除）
  final idsToRemove = rsp.data!.normals
      .map((m) => m.baseInfo.materialId)
      .toSet();

  for (final id in idsToRemove) {
    final indexToRemove = updatedScanResults.indexWhere(
      (r) => r.normalMaterial?.baseInfo.materialId == id,
    );

    if (indexToRemove != -1) {
      updatedScanResults.removeAt(indexToRemove);  // 按索引删除
      removedNormal++;
    } else {
      unmatchedNormal++;
    }
  }

  // 3. 剔除异常材料（按索引删除）
  for (final scannedError in rsp.data!.errors) {
    final scannedQrCode = _getErrorQrCode(scannedError);
    
    final indexToRemove = updatedScanResults.indexWhere(
      (r) => r.errorMaterial != null && 
             _getErrorQrCode(r.errorMaterial) == scannedQrCode,
    );

    if (indexToRemove != -1) {
      updatedScanResults.removeAt(indexToRemove);  // 按索引删除
      removedError++;
    } else {
      unmatchedError++;
    }
  }

  // 4. 重建 materialInfos（向后兼容）
  final updatedNormals = updatedScanResults
      .where((r) => r.normalMaterial != null)
      .map((r) => r.normalMaterial!)
      .toList();
      
  final updatedErrors = updatedScanResults
      .where((r) => r.errorMaterial != null)
      .map((r) => r.errorMaterial)
      .toList();

  final newMaterialInfos = MaterialInfoForBusiness(
    normals: updatedNormals,
    errors: updatedErrors.cast(),
  );

  // 5. 发出新状态
  emit(
    currentState.copyWith(
      scanResults: updatedScanResults,
      materialInfos: newMaterialInfos,
      materialScanMessage: message,
    ),
  );
}
```

**关键特点：**
- **索引删除**：使用 `indexWhere` + `removeAt` 删除
- **保持顺序**：剔除后剩余材料的扫码顺序不变
- **统一处理**：在同一个 `scanResults` 列表中处理
- **详细统计**：分别统计正常材料、异常材料的剔除和未匹配数量

## 实现细节对比

### 1. 正常材料剔除

#### 验收页面
```dart
// 使用 where 过滤
final newList = editing.currentMaterials
    .where((m) => !idsToRemove.contains(m.baseInfo.materialId))
    .toList();

// 优点：代码简洁
// 缺点：无法知道具体剔除了哪些位置的材料
```

#### 安装页面
```dart
// 使用 indexWhere + removeAt
for (final id in idsToRemove) {
  final indexToRemove = updatedScanResults.indexWhere(
    (r) => r.normalMaterial?.baseInfo.materialId == id,
  );

  if (indexToRemove != -1) {
    updatedScanResults.removeAt(indexToRemove);
    removedNormal++;
  } else {
    unmatchedNormal++;
  }
}

// 优点：精确控制删除位置，保持顺序
// 缺点：代码稍复杂，需要遍历每个要删除的ID
```

### 2. 异常材料剔除

#### 验收页面
```dart
// 从后向前遍历删除
for (int i = currentErrors.length - 1; i >= 0; i--) {
  final existingQrCode = _getErrorQrCode(currentErrors[i]);
  if (existingQrCode == scannedQrCode && scannedQrCode.isNotEmpty) {
    currentErrors.removeAt(i);
    removedError++;
    break;  // 找到一个就停止
  }
}

// 优点：安全删除（从后向前）
// 缺点：需要break控制，逻辑略复杂
```

#### 安装页面
```dart
// 查找并删除
final indexToRemove = updatedScanResults.indexWhere(
  (r) => r.errorMaterial != null && 
         _getErrorQrCode(r.errorMaterial) == scannedQrCode,
);

if (indexToRemove != -1) {
  updatedScanResults.removeAt(indexToRemove);
  removedError++;
} else {
  unmatchedError++;
}

// 优点：逻辑清晰，统计准确
// 缺点：每次都要遍历整个列表查找
```

### 3. 统计反馈

#### 验收页面
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

final msg = messages.isNotEmpty ? messages.join('，') : '未找到可剔除的物料';
```

**特点：**
- 统计详细，分类清晰
- 消息友好，易于理解

#### 安装页面
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
  messages.add('忽略未在列表 $total 个');
}

final message = messages.isNotEmpty 
    ? messages.join('，') 
    : '未找到可剔除的材料';
```

**特点：**
- 与验收页面类似的统计方式
- 措辞稍有不同（"未在列表"vs"未在页面"）

## UI 对比

### 验收页面 UI

```dart
// 按钮布局：垂直或水平独立按钮组
Row(
  children: [
    Expanded(
      child: UnifiedButton(
        text: '继续扫码',
        type: UnifiedButtonType.outlined,
        businessType: 'acceptance',
        onPressed: _scanAppendMaterials,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: UnifiedButton(
        text: '扫码剔除',
        type: UnifiedButtonType.outlined,
        businessType: 'acceptance',
        onPressed: _scanRemoveMaterials,
      ),
    ),
  ],
)
```

**特点：**
- 使用 `UnifiedButton` 统一按钮
- `outlined` 类型，视觉统一
- 始终显示两个按钮

### 安装页面 UI

```dart
// 按钮布局：条件显示
Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(scannedMaterials.isEmpty ? '开始扫码' : '继续扫码'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.getBusinessColor('install'),
        ),
        onPressed: () => _navigateToQrScan(context),
      ),
    ),
    
    // 仅当有材料时才显示剔除按钮
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

**特点：**
- 使用 `ElevatedButton.icon` 标准按钮
- 扫码按钮始终显示
- 剔除按钮条件显示（有材料时才显示）
- 剔除按钮使用警告色区分

## 扫码配置对比

### 验收页面扫码配置

```dart
// 继续扫码
final config = flow.buildConfig(QrScanFlowRequest(
  operation: QrScanOperation.append,
  currentCodes: [],
  batch: true,  // 批量扫码
  context: const {
    'source': 'acceptance',
    'operation': 'append',
  },
  title: '继续扫码',
));

// 扫码剔除
final config = flow.buildConfig(QrScanFlowRequest(
  operation: QrScanOperation.remove,
  currentCodes: [],
  batch: true,  // 批量扫码
  context: const {
    'source': 'acceptance',
    'operation': 'remove',
  },
  title: '扫码剔除',
));
```

**特点：**
- 使用 `QrScanFlowService` 构建配置
- `batch: true` 支持批量扫码
- 包含详细的上下文信息

### 安装页面扫码配置

```dart
// 继续扫码
final config = QrScanConfig(
  title: '扫码安装',
  scanMode: QrScanMode.single,  // 单次扫码
);

// 扫码剔除
final config = QrScanConfig(
  title: '扫码剔除',
  scanMode: QrScanMode.single,        // 单次扫码
  operation: QrScanOperation.remove,  // 标记为剔除操作
);
```

**特点：**
- 直接使用 `QrScanConfig`
- `scanMode: QrScanMode.single` 单次扫码
- 配置简洁明了

## 使用场景对比

### 验收页面适用场景

✅ **批量验收**：一次验收多个材料  
✅ **集合操作**：需要对材料列表进行整体操作  
✅ **灵活排序**：材料顺序不是关键信息  
✅ **分类管理**：正常材料和异常材料需要分开管理  

**示例流程：**
```
1. 批量扫码 20 个材料
2. 系统解析：18 个正常，2 个异常
3. 用户查看列表，发现 3 个需要剔除
4. 批量扫码这 3 个材料进行剔除
5. 继续验收流程
```

### 安装页面适用场景

✅ **逐个安装**：一个一个安装材料  
✅ **独立展示**：每个材料有独立的卡片  
✅ **顺序重要**：需要保持扫码的时间顺序  
✅ **即时反馈**：每次扫码后立即显示结果  

**示例流程：**
```
1. 扫第 1 个材料 → 填写桩号、上传照片
2. 扫第 2 个材料 → 填写桩号、上传照片
3. 发现第 1 个扫错了
4. 点击"扫码剔除"，扫第 1 个材料的码
5. 第 1 个卡片消失，第 2 个卡片保持
6. 继续扫第 3 个材料
```

## 性能对比

### 验收页面

**优势：**
- `where` 过滤操作简单高效
- Set 去重查找 O(1) 复杂度

**劣势：**
- 创建新列表需要遍历整个材料列表
- 大量材料时内存占用较高

### 安装页面

**优势：**
- 按索引删除，不需要重建整个列表
- 保持原有列表结构，内存效率高

**劣势：**
- `indexWhere` 需要遍历查找，时间复杂度 O(n)
- 多次删除时每次都要遍历

**性能建议：**
- 安装页面材料数量通常较少（<20），性能差异可忽略
- 验收页面材料数量可能很多（>100），集合过滤更合适

## 最佳实践建议

### 验收页面最佳实践

1. **使用批量扫码**：提高操作效率
2. **集合操作**：利用 Dart 的集合方法（`where`, `map`, `toSet`）
3. **分离存储**：正常材料和异常材料分开管理
4. **统计优先**：关注剔除数量而非具体位置

### 安装页面最佳实践

1. **单次扫码**：符合逐个安装的业务流程
2. **保持顺序**：使用 `removeAt` 而非 `where`
3. **统一存储**：使用 `ScanResult` 统一管理
4. **条件显示**：剔除按钮仅在有材料时显示

## 总结

| 方面         | 验收页面          | 安装页面          |
|--------------|-------------------|-------------------|
| **核心理念** | 批量处理，集合操作 | 逐个处理，独立展示 |
| **数据结构** | 分离存储，Set 去重 | 统一存储，时序保持 |
| **剔除方式** | 集合过滤，简洁高效 | 索引删除，顺序保持 |
| **扫码模式** | 批量扫码，效率优先 | 单次扫码，逐个确认 |
| **UI 设计**  | 始终显示，统一样式 | 条件显示，视觉区分 |
| **适用场景** | 大批量材料验收    | 逐个材料安装      |

两种实现各有优势，完全符合各自的业务特点：
- **验收页面**：强调批量效率和集合管理
- **安装页面**：强调独立操作和时序保持

选择实现方式时，应优先考虑业务场景的实际需求。
