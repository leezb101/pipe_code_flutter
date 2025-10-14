# MaterialVO 数据问题描述功能 - 快速使用指南

## 🚀 快速开始

### 1. 解析材料数据

```dart
// 自动检测问题字段
final materialVO = MaterialVO.fromJson(jsonData);

// 检查是否有数据问题
if (materialVO.hasIssue) {
  print('⚠️ 发现问题: ${materialVO.issueDesc}');
  // 输出: ⚠️ 发现问题: 数据异常：缺少材料ID
}
```

### 2. 在列表中显示

```dart
MaterialListItem(
  materialName: materialVO.displayMaterialName,  // 安全显示
  materialId: materialVO.displayMaterialId,      // 安全显示
  quantity: materialVO.displayNum,               // 安全显示
  issueDesc: materialVO.issueDesc,               // 自动显示问题
  // ... 其他属性
)
```

### 3. 过滤和统计

```dart
// 过滤正常材料
final normalMaterials = materials.where((m) => !m.hasIssue).toList();

// 过滤问题材料
final issueMaterials = materials.where((m) => m.hasIssue).toList();

// 统计显示
Text('正常: ${normalMaterials.length} | 问题: ${issueMaterials.length}')
```

## 📊 实际场景示例

### 场景1: 扫码获取材料列表

```dart
// 调用API获取材料
final result = await materialApi.scanBatchToQueryAll(codes);

if (result.isSuccess && result.data != null) {
  final materials = result.data!.materials;
  
  // 分类统计
  final normal = materials.where((m) => !m.hasIssue).length;
  final issue = materials.where((m) => m.hasIssue).length;
  
  // 显示提示
  if (issue > 0) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('扫码完成'),
        content: Text('正常材料: $normal\n问题材料: $issue'),
      ),
    );
  }
  
  // 展示列表（问题材料会自动显示红色警告）
  ListView.builder(
    itemCount: materials.length,
    itemBuilder: (context, index) {
      final material = materials[index];
      return MaterialListItem(
        materialName: material.displayMaterialName,
        materialId: material.displayMaterialId,
        quantity: material.displayNum,
        issueDesc: material.issueDesc,  // 关键！
        onTap: () => _handleMaterialTap(material),
      );
    },
  );
}
```

### 场景2: 提交前验证

```dart
Future<void> submitMaterials(List<MaterialVO> materials) async {
  // 检查是否有问题材料
  final issueMaterials = materials.where((m) => m.hasIssue).toList();
  
  if (issueMaterials.isNotEmpty) {
    // 提示用户
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('发现问题材料'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('发现 ${issueMaterials.length} 个问题材料：'),
            SizedBox(height: 8),
            ...issueMaterials.map((m) => Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${m.displayMaterialName}: ${m.issueDesc}',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            )),
            SizedBox(height: 8),
            Text('这些材料不会被提交，是否继续？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('继续提交'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
  }
  
  // 只提交正常材料
  final normalMaterials = materials.where((m) => !m.hasIssue).toList();
  await _submitToServer(normalMaterials);
}
```

### 场景3: 问题上报

```dart
void reportIssueMaterial(MaterialVO material) {
  if (!material.hasIssue) return;
  
  // 收集问题信息
  final report = {
    'materialCode': material.materialCode,
    'batchCode': material.batchCode,
    'issueDesc': material.issueDesc,
    'timestamp': DateTime.now().toIso8601String(),
    'reporter': currentUser.name,
  };
  
  // 上报到服务器或日志系统
  reportApi.submitIssue(report);
  
  // 显示确认
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('已上报问题材料')),
  );
}
```

## 💡 最佳实践

### 1. 使用辅助方法

```dart
// ✅ 推荐：使用辅助方法，永远不会为null
Text(materialVO.displayMaterialName)  // "未知材料" 或实际名称
Text(materialVO.displayMaterialId)    // "无" 或实际ID
Text('数量: ${materialVO.displayNum}') // 0 或实际数量

// ❌ 不推荐：直接访问可能为null的字段
Text(materialVO.materialName ?? '未知')  // 容易遗漏判空
```

### 2. 检查问题状态

```dart
// ✅ 推荐：使用 hasIssue getter
if (materialVO.hasIssue) {
  // 处理问题材料
}

// ❌ 不推荐：手动判断
if (materialVO.issueDesc != null && materialVO.issueDesc!.isNotEmpty) {
  // 代码冗余
}
```

### 3. 在UI中展示

```dart
// ✅ 推荐：直接传递 issueDesc，组件会自动处理显示
MaterialListItem(
  issueDesc: materialVO.issueDesc,
  // ...
)

// ❌ 不推荐：手动判断和显示
if (materialVO.issueDesc != null) {
  // 手动构建警告UI，代码重复
}
```

## 🎨 UI 效果说明

### 正常材料
```
┌─────────────────────────────────────┐
│ 🔵 [材料图标]                        │
│                                     │
│    球墨铸铁管                        │
│    XT08K3312501272006              │
│    批次: 2025-1272-6                │
│    ID: 123                          │
│                                     │
│                              [10个] │
└─────────────────────────────────────┘
```

### 问题材料（自动显示警告）
```
┌─────────────────────────────────────┐
│ 🔵 [材料图标]                        │
│                                     │
│    球墨铸铁管                        │
│    XT08K3312501272006              │
│    批次: 2025-1272-6                │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ ⚠️ 数据异常：缺少材料ID         │  │ ← 红色警告框
│  └───────────────────────────────┘  │
│                                     │
│                              [10个] │
└─────────────────────────────────────┘
```

## 🔍 问题排查

### 问题1: issueDesc 没有显示

**可能原因**:
- 忘记传递 `issueDesc` 参数给 `MaterialListItem`
- `issueDesc` 为 null 或空字符串

**解决方案**:
```dart
// 确保传递了 issueDesc
MaterialListItem(
  // ... 其他参数
  issueDesc: materialVO.issueDesc,  // ← 必须传递
)
```

### 问题2: 字段缺失但没有生成 issueDesc

**可能原因**:
- 使用了旧的 MaterialVO.g.dart 文件
- 没有运行 build_runner

**解决方案**:
```bash
# 重新生成代码
dart run build_runner build --delete-conflicting-outputs
```

### 问题3: 类型转换错误

**可能原因**:
- 直接访问可能为 null 的字段
- 使用了类型不安全的代码

**解决方案**:
```dart
// ✅ 使用辅助方法
final name = materialVO.displayMaterialName;
final id = materialVO.displayMaterialId;
final num = materialVO.displayNum;

// ❌ 避免直接访问
final name = materialVO.materialName!;  // 可能崩溃
```

## 📝 常见问题 FAQ

**Q: issueDesc 会被序列化到 JSON 吗？**  
A: 不会。`issueDesc` 使用了 `@JsonKey(includeFromJson: false, includeToJson: false)` 注解，只在内存中存在。

**Q: 如何判断某个字段是否缺失？**  
A: 检查 `issueDesc` 内容，或者直接判断字段是否为 null。

**Q: 可以自定义 issueDesc 的内容吗？**  
A: 可以，使用 `copyWith` 方法：
```dart
final updated = materialVO.copyWith(issueDesc: '自定义描述');
```

**Q: 如何过滤掉所有问题材料？**  
A: 使用 `where` 过滤：
```dart
final normalOnly = materials.where((m) => !m.hasIssue).toList();
```

**Q: 问题材料会影响提交吗？**  
A: 不会自动影响。你需要在提交前手动过滤问题材料，参考"场景2: 提交前验证"示例。

## 📚 更多资源

- **完整文档**: `MATERIAL_VO_ISSUE_DESC_IMPLEMENTATION.md`
- **问题分析**: `MATERIAL_BATCH_SCAN_DATA_ISSUE.md`
- **测试代码**: `test/material_vo_issue_desc_test.dart`
- **模型文件**: `lib/models/acceptance/material_vo.dart`
- **组件文件**: `lib/widgets/unified/unified_components.dart`

---

**更新日期**: 2025-10-14  
**作者**: GitHub Copilot
