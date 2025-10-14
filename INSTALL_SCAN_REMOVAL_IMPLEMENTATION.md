# 安装页面扫码剔除功能实现总结

## 概述

为安装页面添加了"扫码剔除"功能，允许用户通过扫码快速剔除已添加的材料（包括正常材料和异常材料）。该功能参考了验收页面的实现，但考虑了安装页面的业务特殊性：**材料是单独独立展示，而非集合展示**。

## 业务特点对比

### 验收页面的扫码剔除
- **集合操作**：一次扫码可以剔除多个材料
- **批量模式**：支持连续扫码批量剔除
- **集合展示**：所有材料在一个列表中

### 安装页面的扫码剔除
- **单独操作**：每次扫码剔除对应的单个材料
- **单个模式**：默认单次扫码（可以连续多次操作）
- **独立展示**：每个材料（包括异常材料）都有独立的卡片

## 实现细节

### 1. 事件定义（install_event.dart）

```dart
/// 扫码剔除材料
class RemoveScannedMaterialsByCodes extends InstallEvent {
  final List<String> codes;

  const RemoveScannedMaterialsByCodes({required this.codes});

  @override
  List<Object?> get props => [codes];
}
```

**设计说明：**
- 接受二维码列表，支持单次或多次扫码的结果
- 与 `AppendScannedMaterial` 形成对称操作

### 2. BLoC 逻辑实现（install_bloc.dart）

#### 依赖注入更新

```dart
class InstallBloc extends Bloc<InstallEvent, InstallState> {
  final InstallRepository _installRepository;
  final MaterialHandleRepository _materialHandleRepository;  // 新增
  
  InstallBloc({
    required InstallRepository installRepository,
    required MaterialHandleRepository materialHandleRepository,  // 新增
  })  : _installRepository = installRepository,
        _materialHandleRepository = materialHandleRepository,
        super(const InstallReady()) {
    // ...
    on<RemoveScannedMaterialsByCodes>(_onRemoveScannedMaterialsByCodes);
  }
}
```

#### 剔除逻辑实现

```dart
Future<void> _onRemoveScannedMaterialsByCodes(
  RemoveScannedMaterialsByCodes event,
  Emitter<InstallState> emit,
) async {
  final currentState = state;
  if (currentState is! InstallReady) return;

  try {
    if (event.codes.isEmpty) return;

    // 1. 调用接口解析扫码的材料ID
    final rsp = await _materialHandleRepository.scanBatchToQueryAll(
      event.codes,
    );

    if (!rsp.isSuccess || rsp.data == null) {
      emit(currentState.copyWith(
        materialScanMessage: '未匹配到可剔除的材料',
      ));
      return;
    }

    final updatedScanResults = List<ScanResult>.from(currentState.scanResults);
    int removedNormal = 0;
    int removedError = 0;
    int unmatchedNormal = 0;
    int unmatchedError = 0;

    // 2. 处理正常材料的剔除（基于 materialId 匹配）
    final idsToRemove = rsp.data!.normals
        .map((m) => m.baseInfo.materialId)
        .toSet();

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

    // 3. 处理异常材料的剔除（基于 qrCode 匹配）
    for (final scannedError in rsp.data!.errors) {
      final scannedQrCode = _getErrorQrCode(scannedError);
      if (scannedQrCode.isEmpty) {
        unmatchedError++;
        continue;
      }

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
    }

    // 4. 更新 materialInfos（保持向后兼容）
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

    // 5. 构建用户反馈消息
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

    // 6. 发出新状态
    emit(
      currentState.copyWith(
        scanResults: updatedScanResults,
        materialInfos: newMaterialInfos,
        materialScanMessage: message,
      ),
    );
  } catch (e) {
    emit(
      currentState.copyWith(
        materialScanMessage: '剔除材料失败，请重试',
      ),
    );
  }
}
```

**关键设计点：**

1. **双类型剔除**：同时支持正常材料和异常材料的剔除
2. **精确匹配**：
   - 正常材料通过 `materialId` 匹配
   - 异常材料通过 `qrCode` 匹配
3. **按扫码顺序剔除**：使用 `indexWhere` 查找并删除，保持剩余材料的顺序
4. **统计反馈**：详细统计剔除成功、未匹配的数量
5. **状态同步**：同时更新 `scanResults` 和 `materialInfos`

### 3. UI 实现（install_page.dart）

#### 按钮布局更新

```dart
Widget _buildScanButton(
  BuildContext context,
  List<MaterialInfo> scannedMaterials,
) {
  return Row(
    children: [
      // 继续扫码按钮
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
      
      // 扫码剔除按钮（仅当有材料时显示）
      if (scannedMaterials.isNotEmpty) ...[
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.remove_circle_outline),
            label: const Text('扫码剔除'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,  // 警告色
            ),
            onPressed: () => _navigateToQrScanForRemoval(context),
          ),
        ),
      ],
    ],
  );
}
```

**UI 设计说明：**
- **按钮位置**：两个按钮水平排列，等宽
- **显示条件**：仅当有材料时才显示"扫码剔除"按钮
- **视觉区分**：使用警告色（橙色/黄色）区分剔除操作
- **图标选择**：使用 `remove_circle_outline` 表示剔除操作

#### 扫码剔除导航

```dart
void _navigateToQrScanForRemoval(BuildContext context) {
  final config = QrScanConfig(
    title: '扫码剔除',
    scanMode: QrScanMode.single,        // 单次扫码
    operation: QrScanOperation.remove,  // 标记为剔除操作
  );

  context.pushNamed('qr-scan', extra: config).then((result) {
    if (mounted && result != null && result is List<QrScanResult>) {
      final codes = result
          .where((r) => r.code.isNotEmpty)
          .map((r) => r.code)
          .toList();

      if (codes.isNotEmpty) {
        // 触发扫码剔除事件
        context.read<InstallBloc>().add(
          RemoveScannedMaterialsByCodes(codes: codes),
        );
      }
    }
  });
}
```

**交互流程：**
1. 用户点击"扫码剔除"按钮
2. 进入扫码页面，标题显示"扫码剔除"
3. 扫描要剔除的材料二维码
4. 返回后触发 `RemoveScannedMaterialsByCodes` 事件
5. BLoC 处理剔除逻辑
6. UI 刷新，显示剔除结果 Toast

## 用户体验流程

### 场景 1：剔除正常材料

```
用户操作：
1. 查看安装页面，有 3 个正常材料
2. 点击"扫码剔除"按钮
3. 扫描第 2 个材料的二维码
4. 返回安装页面

结果：
┌────────────────────────────────┐
│ [第 1 次扫码 - 成功]            │
│ 材料 A                         │
└────────────────────────────────┘
┌────────────────────────────────┐
│ [第 2 次扫码 - 成功]  [已删除]  │
│ 材料 B                         │
└────────────────────────────────┘  ← 这个被剔除
┌────────────────────────────────┐
│ [第 3 次扫码 - 成功]            │
│ 材料 C                         │
└────────────────────────────────┘

Toast 提示：已剔除 1 个正常材料
```

### 场景 2：剔除异常材料

```
用户操作：
1. 查看安装页面，有 1 个正常材料和 1 个异常材料
2. 点击"扫码剔除"按钮
3. 扫描异常材料的二维码
4. 返回安装页面

结果：
┌────────────────────────────────┐
│ 材料 A                         │
└────────────────────────────────┘
┌────────────────────────────────┐
│ ⚠ 扫码异常  [已删除]            │
│ 错误：供应商不存在              │
└────────────────────────────────┘  ← 这个被剔除

Toast 提示：已剔除 1 个异常材料
```

### 场景 3：扫描不存在的材料

```
用户操作：
1. 查看安装页面，有 2 个材料
2. 点击"扫码剔除"按钮
3. 扫描一个不在列表中的二维码
4. 返回安装页面

结果：
列表无变化

Toast 提示：忽略未在列表 1 个
```

### 场景 4：混合剔除

```
用户操作：
1. 连续剔除 2 个正常材料和 1 个异常材料

Toast 提示：已剔除 2 个正常材料，已剔除 1 个异常材料
```

## 技术亮点

### 1. 精确匹配策略

**正常材料匹配：**
```dart
final indexToRemove = updatedScanResults.indexWhere(
  (r) => r.normalMaterial?.baseInfo.materialId == id,
);
```
- 使用 `materialId` 作为唯一标识
- 确保剔除的是正确的材料

**异常材料匹配：**
```dart
final indexToRemove = updatedScanResults.indexWhere(
  (r) => r.errorMaterial != null && 
         _getErrorQrCode(r.errorMaterial) == scannedQrCode,
);
```
- 使用 `qrCode` 作为标识（异常材料没有 materialId）
- 通过辅助方法 `_getErrorQrCode` 安全提取二维码

### 2. 扫码顺序保持

```dart
final indexToRemove = updatedScanResults.indexWhere(...);
if (indexToRemove != -1) {
  updatedScanResults.removeAt(indexToRemove);
  removedNormal++;
}
```
- 使用 `indexWhere` + `removeAt` 按位置删除
- 保持剩余材料的扫码顺序不变
- 与集合操作（`where` 过滤）不同，这里强调顺序

### 3. 统计与反馈

```dart
int removedNormal = 0;
int removedError = 0;
int unmatchedNormal = 0;
int unmatchedError = 0;

// ... 剔除逻辑 ...

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
```
- 详细统计各类操作结果
- 提供清晰的用户反馈
- 区分成功和未匹配情况

### 4. 向后兼容

```dart
final newMaterialInfos = MaterialInfoForBusiness(
  normals: updatedNormals,
  errors: updatedErrors.cast(),
);

emit(
  currentState.copyWith(
    scanResults: updatedScanResults,    // 新的状态结构
    materialInfos: newMaterialInfos,    // 保持向后兼容
    materialScanMessage: message,
  ),
);
```
- 同时更新 `scanResults` 和 `materialInfos`
- 确保依赖旧结构的代码仍然可用

## 与验收页面的对比

| 特性         | 验收页面                              | 安装页面                       |
|--------------|---------------------------------------|--------------------------------|
| **数据结构** | `currentMaterials` + `errorMaterials` | `scanResults` (包含正常和异常) |
| **剔除方式** | 从集合中过滤                          | 按索引删除                     |
| **顺序保持** | 不强调顺序                            | 保持扫码顺序                   |
| **UI 展示**  | 集合列表                              | 独立卡片                       |
| **操作反馈** | 统计总数                              | 详细分类统计                   |
| **扫码模式** | 批量扫码                              | 单次扫码（可连续）               |

## 代码变更文件

### 新增/修改的文件

1. **lib/bloc/install/install_event.dart**
   - 新增 `RemoveScannedMaterialsByCodes` 事件

2. **lib/bloc/install/install_bloc.dart**
   - 添加 `MaterialHandleRepository` 依赖
   - 实现 `_onRemoveScannedMaterialsByCodes` 方法
   - 添加 `_getErrorQrCode` 辅助方法

3. **lib/pages/install/install_page.dart**
   - 更新 BLoC 创建（注入 `MaterialHandleRepository`）
   - 修改 `_buildScanButton` 为两按钮布局
   - 添加 `_navigateToQrScanForRemoval` 方法

## 测试建议

### 单元测试

```dart
group('InstallBloc RemoveScannedMaterialsByCodes Tests', () {
  test('should remove normal material by materialId', () async {
    // Arrange
    final bloc = InstallBloc(
      installRepository: mockInstallRepository,
      materialHandleRepository: mockMaterialHandleRepository,
    );
    
    // 先添加材料
    bloc.add(AppendScannedMaterial(materialInfo: testMaterialInfo));
    await Future.delayed(Duration.zero);
    
    // Act - 剔除材料
    bloc.add(RemoveScannedMaterialsByCodes(codes: ['test-code']));
    
    // Assert
    await expectLater(
      bloc.stream,
      emits(predicate<InstallReady>((state) {
        return state.scanResults.isEmpty &&
               state.materialScanMessage?.contains('已剔除') == true;
      })),
    );
  });

  test('should remove error material by qrCode', () async {
    // 测试异常材料剔除
  });

  test('should handle unmatched codes', () async {
    // 测试扫描不存在的二维码
  });

  test('should maintain scan order after removal', () async {
    // 测试剔除后顺序保持
  });
});
```

### Widget 测试

```dart
testWidgets('should show remove button when materials exist', (tester) async {
  // Arrange
  final mockBloc = MockInstallBloc();
  when(() => mockBloc.state).thenReturn(InstallReady(
    scanResults: [testScanResult],
  ));

  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider.value(
        value: mockBloc,
        child: const InstallPage(),
      ),
    ),
  );

  // Assert
  expect(find.text('扫码剔除'), findsOneWidget);
});

testWidgets('should not show remove button when no materials', (tester) async {
  // 测试空列表时不显示剔除按钮
});
```

### 集成测试

1. **完整流程测试**：
   - 添加 3 个正常材料
   - 扫码剔除第 2 个
   - 验证剩余 2 个，顺序正确

2. **混合材料测试**：
   - 添加正常材料和异常材料
   - 分别剔除两种类型
   - 验证各自独立剔除

3. **边界情况测试**：
   - 剔除所有材料
   - 扫描不存在的码
   - 重复剔除同一个码

## 注意事项

1. **不能剔除已提交的材料**：当前实现不检查提交状态，实际使用中可能需要添加
2. **UI 文件控制器清理**：剔除材料后，对应的文件上传 Cubit 和桩号控制器需要清理
3. **提交按钮状态**：剔除材料后需要重新计算是否满足提交条件

## 后续优化建议

1. **批量剔除模式**：
   ```dart
   final config = QrScanConfig(
     scanMode: QrScanMode.batch,  // 批量模式
     operation: QrScanOperation.remove,
   );
   ```

2. **确认对话框**：
   ```dart
   void _navigateToQrScanForRemoval(BuildContext context) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('确认剔除'),
         content: const Text('扫码后将直接剔除材料，是否继续？'),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('取消'),
           ),
           TextButton(
             onPressed: () {
               Navigator.pop(context);
               _doNavigateToQrScanForRemoval(context);
             },
             child: const Text('确认'),
           ),
         ],
       ),
     );
   }
   ```

3. **撤销功能**：
   ```dart
   // 保存剔除前的状态
   InstallReady? _beforeRemove;
   
   void _onRemoveScannedMaterialsByCodes(...) {
     _beforeRemove = currentState;
     // ... 剔除逻辑 ...
     
     // Toast 中添加撤销按钮
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text(message),
         action: SnackBarAction(
           label: '撤销',
           onPressed: () {
             bloc.add(RestoreState(state: _beforeRemove!));
           },
         ),
       ),
     );
   }
   ```

4. **清理关联资源**：
   ```dart
   void _onRemoveScannedMaterialsByCodes(...) {
     // ... 剔除逻辑 ...
     
     // 清理被剔除材料的相关资源
     for (final id in idsToRemove) {
       _materialPhotoCubits[id]?.close();
       _materialPhotoCubits.remove(id);
       _stakeNumberControllers[id]?.dispose();
       _stakeNumberControllers.remove(id);
       _materialStakeNumbers.remove(id);
     }
     
     // ... emit 新状态 ...
   }
   ```

## 总结

成功为安装页面添加了扫码剔除功能，关键特点：

✅ **独立展示适配**：考虑安装页面单独展示的特性，按索引删除保持顺序  
✅ **双类型支持**：同时支持正常材料和异常材料的剔除  
✅ **精确匹配**：使用 materialId 和 qrCode 确保准确剔除  
✅ **详细反馈**：统计并反馈剔除结果，提升用户体验  
✅ **向后兼容**：同步更新新旧数据结构  
✅ **UI 友好**：按钮布局合理，视觉区分明显  

该功能让用户可以快速纠正扫码错误，提升了安装流程的灵活性和容错性。
