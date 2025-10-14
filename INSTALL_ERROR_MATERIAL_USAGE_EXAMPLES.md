# 安装页面异常材料处理 - 使用示例

## 场景示例

### 场景 1：正常扫码流程

**步骤：**
1. 用户进入安装页面
2. 点击"开始扫码添加"按钮
3. 扫描二维码成功
4. 页面显示材料卡片

**代码流程：**
```dart
// 1. 用户扫码
context.pushNamed('qr-scan', extra: config).then((result) {
  materialCubit.getMaterialInfoFromQr(qrCode);
});

// 2. MaterialHandleCubit 返回结果
MaterialHandleScanSuccess(
  materialInfo: MaterialInfoForBusiness(
    normals: [MaterialInfo(...)],
    errors: [],
  ),
)

// 3. InstallBloc 处理
AppendScannedMaterial(materialInfo: materialInfo)
  ↓
_onAppendScannedMaterial()
  ↓
创建 ScanResult(
  normalMaterial: material,
  scanTime: DateTime.now(),
)
  ↓
emit(InstallReady(scanResults: [...]))

// 4. UI 渲染
_buildScanResultsList()
  ↓
_buildMaterialItem()  // 显示蓝色材料卡片
```

**用户看到：**
```
┌────────────────────────────────┐
│ 管道 Φ200                       │
│ 材料编码：12345678              │
│ 批次号：20250114-001            │
│                                │
│ 安装照片                        │
│ [上传照片] [上传照片]            │
│                                │
│ 桩号                            │
│ [_________________]            │
└────────────────────────────────┘
```

---

### 场景 2：扫码异常流程

**步骤：**
1. 用户扫描无效二维码
2. 系统返回异常信息
3. 页面显示红色警告卡片
4. 用户可查看详情或继续扫码

**代码流程：**
```dart
// 1. MaterialHandleCubit 返回异常
MaterialHandleScanSuccess(
  materialInfo: MaterialInfoForBusiness(
    normals: [],
    errors: [
      SyncVendorDataError(
        qrCode: "ABC123",
        code: "VENDOR-001",
        name: "XX供应商",
        msg: "供应商编码不存在",
      ),
    ],
  ),
)

// 2. InstallBloc 处理
_onAppendScannedMaterial()
  ↓
for (error in errors) {
  创建 ScanResult(
    errorMaterial: error,
    scanTime: DateTime.now(),
  )
}
  ↓
emit(InstallReady(
  scanResults: [...],
  materialScanMessage: '扫描到异常材料',
))

// 3. UI 渲染
_buildScanResultsList()
  ↓
_buildErrorMaterialItem()  // 显示红色警告卡片
```

**用户看到：**
```
┌────────────────────────────────┐
│ ⚠ 扫码异常                      │
│                                │
│ 二维码：ABC123                  │
│ 供应商编码：VENDOR-001          │
│ 供应商名称：XX供应商             │
│ 错误信息：供应商编码不存在        │
│                                │
│ [点击查看详细信息]               │
└────────────────────────────────┘

Toast 提示：扫描到异常材料
```

---

### 场景 3：混合扫码流程

**步骤：**
1. 第 1 次扫码 → 成功
2. 第 2 次扫码 → 失败
3. 第 3 次扫码 → 成功
4. 第 4 次扫码 → 重复（第 1 次的材料）

**状态变化：**
```dart
// 第 1 次扫码后
InstallReady(
  scanResults: [
    ScanResult(
      normalMaterial: Material_A,
      scanTime: T1,
    ),
  ],
)

// 第 2 次扫码后
InstallReady(
  scanResults: [
    ScanResult(normalMaterial: Material_A, scanTime: T1),
    ScanResult(errorMaterial: Error_1, scanTime: T2),  // 新增
  ],
)

// 第 3 次扫码后
InstallReady(
  scanResults: [
    ScanResult(normalMaterial: Material_A, scanTime: T1),
    ScanResult(errorMaterial: Error_1, scanTime: T2),
    ScanResult(normalMaterial: Material_B, scanTime: T3),  // 新增
  ],
)

// 第 4 次扫码（重复）
InstallReady(
  scanResults: [
    ScanResult(normalMaterial: Material_A, scanTime: T1),
    ScanResult(errorMaterial: Error_1, scanTime: T2),
    ScanResult(normalMaterial: Material_B, scanTime: T3),
    // 没有新增，因为 Material_A 已存在
  ],
  materialScanMessage: '材料 12345678 已经匹配过了',
)
```

**用户看到的页面：**
```
┌────────────────────────────────┐
│ [第 1 次扫码]                   │
│ ┌──────────────────────────┐   │
│ │ 管道 Φ200                 │   │
│ │ 编码：12345678            │   │
│ │ 桩号：[_______]          │   │
│ │ 照片：[上传] [上传]       │   │
│ └──────────────────────────┘   │
│                                │
│ [第 2 次扫码]                   │
│ ┌──────────────────────────┐   │
│ │ ⚠ 扫码异常                │   │
│ │ 错误：供应商不存在         │   │
│ └──────────────────────────┘   │
│                                │
│ [第 3 次扫码]                   │
│ ┌──────────────────────────┐   │
│ │ 管道 Φ150                 │   │
│ │ 编码：87654321            │   │
│ │ 桩号：[_______]          │   │
│ │ 照片：[上传] [上传]       │   │
│ └──────────────────────────┘   │
│                                │
│ [继续扫码]                      │
│ [提交]                         │
└────────────────────────────────┘

第 4 次扫码时弹出 Toast：
材料 12345678 已经匹配过了
```

---

## 代码示例

### 1. 在 BLoC 中处理扫码结果

```dart
class InstallBloc extends Bloc<InstallEvent, InstallState> {
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
        
        // 去重检查
        final existingIds = currentState.scanResults
            .where((r) => r.normalMaterial != null)
            .map((r) => r.normalMaterial!.baseInfo.materialId)
            .toSet();

        if (existingIds.contains(material.baseInfo.materialId)) {
          emit(currentState.copyWith(
            materialScanMessage: '材料已经匹配过了',
          ));
          return;
        }

        // 添加正常材料
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

      emit(currentState.copyWith(
        scanResults: updatedScanResults,
      ));
    }
  }
}
```

### 2. 在 UI 中渲染扫码结果

```dart
class _InstallViewState extends State<InstallView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstallBloc, InstallState>(
      builder: (context, state) {
        if (state is InstallReady) {
          return _buildContent(context, state);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildContent(BuildContext context, InstallReady state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 渲染所有扫码结果
          if (state.scanResults.isNotEmpty)
            _buildScanResultsList(state.scanResults),
          
          // 扫码按钮
          _buildScanButton(context),
          
          // 提交按钮
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildScanResultsList(List<ScanResult> scanResults) {
    return Column(
      children: scanResults.map((scanResult) {
        if (scanResult.normalMaterial != null) {
          return _buildMaterialItem(scanResult.normalMaterial!);
        } else if (scanResult.errorMaterial != null) {
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
        errors: [error],
        title: '扫码异常',
        collapsible: false,
        onErrorItemTap: (error) {
          // 显示详情对话框
          _showErrorDetails(error);
        },
      ),
    );
  }
}
```

### 3. 处理异常材料点击事件

```dart
void _handleErrorMaterialTap(dynamic error) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 8),
          const Text('异常材料详情'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('二维码', error.qrCode),
          _buildDetailRow('供应商编码', error.code),
          _buildDetailRow('供应商名称', error.name),
          _buildDetailRow('错误信息', error.msg),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // 重新扫描此材料
            _navigateToQrScan(context);
          },
          child: const Text('重新扫描'),
        ),
      ],
    ),
  );
}

Widget _buildDetailRow(String label, String? value) {
  if (value == null || value.isEmpty) {
    return const SizedBox.shrink();
  }
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
```

---

## 测试场景

### 单元测试

```dart
void main() {
  group('InstallBloc ScanResult Tests', () {
    test('should add normal material to scanResults', () async {
      // Arrange
      final bloc = InstallBloc(installRepository: mockRepository);
      final materialInfo = MaterialInfoForBusiness(
        normals: [testMaterial],
        errors: [],
      );

      // Act
      bloc.add(AppendScannedMaterial(materialInfo: materialInfo));

      // Assert
      await expectLater(
        bloc.stream,
        emits(predicate<InstallReady>((state) {
          return state.scanResults.length == 1 &&
                 state.scanResults.first.normalMaterial != null &&
                 state.scanResults.first.errorMaterial == null;
        })),
      );
    });

    test('should add error material to scanResults', () async {
      // Arrange
      final bloc = InstallBloc(installRepository: mockRepository);
      final materialInfo = MaterialInfoForBusiness(
        normals: [],
        errors: [testError],
      );

      // Act
      bloc.add(AppendScannedMaterial(materialInfo: materialInfo));

      // Assert
      await expectLater(
        bloc.stream,
        emits(predicate<InstallReady>((state) {
          return state.scanResults.length == 1 &&
                 state.scanResults.first.errorMaterial != null &&
                 state.scanResults.first.normalMaterial == null;
        })),
      );
    });

    test('should prevent duplicate materials', () async {
      // Arrange
      final bloc = InstallBloc(installRepository: mockRepository);
      final materialInfo = MaterialInfoForBusiness(
        normals: [testMaterial],
        errors: [],
      );

      // Act
      bloc.add(AppendScannedMaterial(materialInfo: materialInfo));
      await Future.delayed(Duration.zero);
      bloc.add(AppendScannedMaterial(materialInfo: materialInfo));

      // Assert
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<InstallReady>((state) => state.scanResults.length == 1),
          predicate<InstallReady>((state) => 
            state.materialScanMessage == '材料已经匹配过了'
          ),
        ]),
      );
    });
  });
}
```

### Widget 测试

```dart
void main() {
  group('InstallPage Error Display Tests', () {
    testWidgets('should display error material card', (tester) async {
      // Arrange
      final mockBloc = MockInstallBloc();
      when(() => mockBloc.state).thenReturn(InstallReady(
        scanResults: [
          ScanResult(
            errorMaterial: testError,
            scanTime: DateTime.now(),
          ),
        ],
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
      expect(find.text('扫码异常'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('should show error details on tap', (tester) async {
      // Arrange
      final mockBloc = MockInstallBloc();
      when(() => mockBloc.state).thenReturn(InstallReady(
        scanResults: [
          ScanResult(
            errorMaterial: testError,
            scanTime: DateTime.now(),
          ),
        ],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: mockBloc,
            child: const InstallPage(),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ErrorMaterialListItem));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('异常材料详情'), findsOneWidget);
      expect(find.text('关闭'), findsOneWidget);
    });
  });
}
```

---

## 常见问题 (FAQ)

### Q1: 异常材料会影响提交吗？
**A:** 不会。异常材料仅作为扫码历史记录，不影响正常材料的提交流程。

### Q2: 异常材料可以删除吗？
**A:** 当前版本不支持删除。异常材料作为扫码历史的一部分被保留。如需此功能，可以扩展 `ScanResult` 添加删除标记。

### Q3: 如何处理重复扫描？
**A:** 系统会基于 `materialId` 去重。如果扫描重复材料，会显示 Toast 提示，不会添加到列表。

### Q4: 异常材料的顺序重要吗？
**A:** 是的。异常材料按扫码时间顺序展示，帮助用户回溯扫码历史。

### Q5: 可以批量扫码吗？
**A:** 安装页面设计为单次扫码。如需批量扫码，请使用验收页面。

---

## 扩展建议

### 1. 添加删除功能
```dart
class RemoveScanResult extends InstallEvent {
  final DateTime scanTime;
  const RemoveScanResult({required this.scanTime});
}

// 在 BLoC 中
void _onRemoveScanResult(event, emit) {
  final updated = state.scanResults
      .where((r) => r.scanTime != event.scanTime)
      .toList();
  emit(state.copyWith(scanResults: updated));
}
```

### 2. 添加重试功能
```dart
Widget _buildErrorMaterialItem(dynamic error) {
  return ErrorMaterialSection(
    errors: [error],
    title: '扫码异常',
    trailing: IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () => _retryScanning(error.qrCode),
    ),
  );
}
```

### 3. 添加导出功能
```dart
void exportErrorMaterials() {
  final errors = state.scanResults
      .where((r) => r.errorMaterial != null)
      .map((r) => r.errorMaterial)
      .toList();
  
  // 生成 CSV 或 Excel
  exportToCsv(errors);
}
```
