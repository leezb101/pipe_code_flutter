# 验收页面 vs 安装页面：异常材料处理对比

## 核心差异

| 维度         | 验收页面 (AcceptancePage)       | 安装页面 (InstallPage)          |
|--------------|---------------------------------|---------------------------------|
| **业务场景** | 批量验收多个材料                | 单个材料逐一安装                |
| **扫码方式** | 批量扫码                        | 单次扫码                        |
| **异常展示** | 集合展示（所有异常在一起）        | 独立展示（每次扫码单独显示）      |
| **展示位置** | 材料列表底部                    | 与正常材料混排，按扫码顺序       |
| **折叠功能** | 可折叠（`collapsible: true`）     | 不可折叠（`collapsible: false`）  |
| **数据结构** | `errorMaterials: List<dynamic>` | `scanResults: List<ScanResult>` |

## 数据结构对比

### 验收页面
```dart
class AcceptanceEditingState {
  final List<MaterialInfo> currentMaterials;   // 正常材料
  final List<dynamic> errorMaterials;          // 异常材料（集合）
}
```

**特点：**
- 正常材料和异常材料分开存储
- 异常材料是一个整体集合
- 无时序关系

### 安装页面
```dart
class InstallReady {
  final List<ScanResult> scanResults;          // 所有扫码结果
}

class ScanResult {
  final MaterialInfo? normalMaterial;          // 正常材料
  final dynamic errorMaterial;                 // 异常材料
  final DateTime scanTime;                     // 扫描时间
}
```

**特点：**
- 每次扫码结果独立封装
- 正常和异常材料互斥存储
- 保留扫码时序信息

## UI 展示对比

### 验收页面
```
┌────────────────────────────────────────┐
│ 正常材料列表                            │
│  • 材料 A                               │
│  • 材料 B                               │
│  • 材料 C                               │
│                                        │
│ ┌────────────────────────────────────┐ │
│ │ ⚠ 验收异常材料 [展开▼] (3项)        │ │
│ │ ────────────────────────────────── │ │
│ │  • 异常 1：供应商编码不存在          │ │
│ │  • 异常 2：材料信息不匹配            │ │
│ │  • 异常 3：二维码格式错误            │ │
│ └────────────────────────────────────┘ │
│                                        │
│ [继续扫码] [提交验收]                   │
└────────────────────────────────────────┘
```

**设计理由：**
- 批量验收时，用户需要先看到所有正常材料
- 异常材料作为次要信息，放在底部
- 可折叠设计减少视觉干扰
- 集中展示便于批量处理

### 安装页面
```
┌────────────────────────────────────────┐
│ 扫码结果（按顺序）                       │
│                                        │
│ [第1次扫码 - 成功]                      │
│ ┌────────────────────────────────────┐ │
│ │ 正常材料：管道 Φ200                 │ │
│ │ 编码：12345678                      │ │
│ │ 桩号：[___________]                │ │
│ │ 照片：[上传] [上传]                 │ │
│ └────────────────────────────────────┘ │
│                                        │
│ [第2次扫码 - 失败]                      │
│ ┌────────────────────────────────────┐ │
│ │ ⚠ 扫码异常                          │ │
│ │ 二维码：ABC123                      │ │
│ │ 错误：供应商编码不存在               │ │
│ │ [查看详情]                          │ │
│ └────────────────────────────────────┘ │
│                                        │
│ [第3次扫码 - 成功]                      │
│ ┌────────────────────────────────────┐ │
│ │ 正常材料：管道 Φ150                 │ │
│ │ 编码：87654321                      │ │
│ │ 桩号：[___________]                │ │
│ │ 照片：[上传] [上传]                 │ │
│ └────────────────────────────────────┘ │
│                                        │
│ [继续扫码]                              │
│ [提交]                                 │
└────────────────────────────────────────┘
```

**设计理由：**
- 安装是逐个进行的，每次扫码都是独立操作
- 用户需要立即知道这次扫码的结果
- 异常扫码也是扫码历史的一部分，需要保留
- 不可折叠，确保用户不会遗漏异常情况

## 代码实现对比

### 验收页面 - 渲染异常材料

```dart
Widget _buildMaterialsListContent(AcceptanceState state) {
  final materials = state.currentMaterials;
  final errorMaterials = state.errorMaterials;

  return Column(
    children: [
      // 正常材料列表
      ...materials.map(_buildMaterialItem),
      
      // 异常材料区域（集合展示）
      if (errorMaterials.isNotEmpty) ...[
        const SizedBox(height: 16),
        ErrorMaterialSection(
          errors: errorMaterials,              // 所有异常一起传入
          title: '验收异常材料',
          collapsible: true,                   // 可折叠
          initialExpanded: true,               // 默认展开
          onErrorItemTap: _handleErrorMaterialTap,
        ),
      ],
    ],
  );
}
```

### 安装页面 - 渲染扫码结果

```dart
Widget _buildScanResultsList(List<ScanResult> scanResults) {
  return Column(
    children: scanResults.map((scanResult) {
      // 正常材料
      if (scanResult.normalMaterial != null) {
        return _buildMaterialItem(materialVO);
      } 
      // 异常材料（单独展示）
      else if (scanResult.errorMaterial != null) {
        return _buildErrorMaterialItem(scanResult.errorMaterial);
      }
      return const SizedBox.shrink();
    }).toList(),
  );
}

Widget _buildErrorMaterialItem(dynamic error) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: ErrorMaterialSection(
      errors: [error],                        // 单个异常
      title: '扫码异常',
      collapsible: false,                     // 不可折叠
      onErrorItemTap: _handleErrorMaterialTap,
    ),
  );
}
```

## BLoC 逻辑对比

### 验收页面 - 追加材料

```dart
void _onAppendEditingMaterialsByCodes(event, emit) {
  // 批量解析二维码
  final result = await repository.scanBatchToQueryAll(codes);
  
  // 合并正常材料（去重）
  final updatedNormals = [...currentMaterials];
  for (final material in result.normals) {
    if (!isDuplicate(material)) {
      updatedNormals.add(material);
    }
  }
  
  // 合并异常材料（追加到集合）
  final updatedErrors = [
    ...currentErrors,
    ...result.errors,
  ];
  
  emit(AcceptanceEditingState(
    currentMaterials: updatedNormals,
    errorMaterials: updatedErrors,
  ));
}
```

### 安装页面 - 追加材料

```dart
void _onAppendScannedMaterial(event, emit) {
  final scanTime = DateTime.now();
  final updatedScanResults = [...currentScanResults];
  
  // 处理正常材料
  if (event.materialInfo.normals.isNotEmpty) {
    final material = event.materialInfo.normals.first;
    
    // 检查去重
    if (isDuplicate(material)) {
      emit(state.copyWith(
        materialScanMessage: '材料已匹配过',
      ));
      return;
    }
    
    // 创建扫码结果
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
  }
  
  emit(InstallReady(
    scanResults: updatedScanResults,
  ));
}
```

## 用户体验对比

### 验收场景
**操作流程：**
1. 用户批量扫描 20 个二维码
2. 系统解析：18 个成功，2 个失败
3. 页面显示：18 个正常材料卡片 + 1 个折叠的异常区域
4. 用户可以：
   - 先处理所有正常材料
   - 最后集中查看和处理异常情况
   - 决定是否报告异常或重新扫描

**优势：**
- 主流程清晰，不被异常打断
- 异常集中处理，效率高
- 适合批量操作场景

### 安装场景
**操作流程：**
1. 用户扫描第 1 个二维码 → 成功 → 填写桩号、上传照片
2. 用户扫描第 2 个二维码 → 失败 → 立即看到红色警告
3. 用户处理异常：查看详情、重新扫描或跳过
4. 用户扫描第 3 个二维码 → 成功 → 继续操作

**优势：**
- 即时反馈，问题立即可见
- 保留完整的操作历史
- 适合逐个操作场景
- 防止遗漏异常情况

## 技术设计原则

### 验收页面
- **分离原则**：正常和异常材料分开管理
- **集合原则**：异常材料作为整体处理
- **次要原则**：异常信息不干扰主流程

### 安装页面
- **统一原则**：所有扫码结果统一管理
- **时序原则**：保留操作时间顺序
- **平等原则**：正常和异常结果同等重要

## 何时使用哪种模式

### 使用集合展示（验收模式）
✅ 批量操作场景  
✅ 异常是次要信息  
✅ 需要集中处理异常  
✅ 主流程不应被异常打断  

### 使用独立展示（安装模式）
✅ 逐个操作场景  
✅ 每次操作结果都重要  
✅ 需要保留操作历史  
✅ 需要即时反馈  

## 总结

两种模式各有优势，选择依据是**业务场景**：

- **验收**是批量处理，关注整体效率
- **安装**是逐个操作，关注即时反馈

通过不同的数据结构和UI设计，我们为两种场景提供了最优的用户体验。
