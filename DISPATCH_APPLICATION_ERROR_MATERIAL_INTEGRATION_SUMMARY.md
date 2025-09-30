# Dispatch Application 错误材料集成总结

## 概述
为调拨申请页面(`DispatchApplicationPage`)和相关的状态管理(`DispatchBloc`)集成了完整的错误材料显示和处理功能，与acceptance和JSF acceptance页面保持一致的用户体验。

## 主要改进

### 1. 状态管理层 (DispatchState)
**文件**: `lib/bloc/dispatch/dispatch_state.dart`

**新增字段**:
```dart
final List<dynamic> errorMaterials; // 错误材料列表
```

**修改内容**:
- 在构造函数中添加`errorMaterials`参数，默认为空列表
- 在`copyWith`方法中添加`errorMaterials`参数支持
- 在`props`中添加`errorMaterials`字段用于状态比较

### 2. 业务逻辑层 (DispatchBloc)
**文件**: `lib/bloc/dispatch/dispatch_bloc.dart`

**核心改进**:

#### a. 初始化材料处理 (`_onInitializeMaterialsFromCodes`)
```dart
final MaterialInfoForBusiness bundle = rsp.data!;
final ids = bundle.normals.map((m) => m.baseInfo.materialId).toSet();
// ... 处理正常材料
emit(
  state.copyWith(
    status: DispatchStatus.success,
    materialIds: ids,
    materialList: materialVos,
    errorMaterials: bundle.errors, // 新增：设置错误材料
  ),
);
```

#### b. 追加材料处理 (`_onUpdateApplicationMaterialListWithAppendingCodes`)
- 同时处理正常材料和错误材料的追加
- 基于QR码对错误材料进行重复检查
- 提供详细的追加结果反馈（正常材料x项、异常材料x项）

**关键代码片段**:
```dart
// 处理错误材料追加
final currentErrorMaterials = List<dynamic>.from(state.errorMaterials);
int errorAddedCount = 0;
for (final error in bundle.errors) {
  final qrCode = _getErrorQrCode(error);
  final isDuplicate = currentErrorMaterials.any((existingError) => 
    _getErrorQrCode(existingError) == qrCode);
  
  if (!isDuplicate) {
    currentErrorMaterials.add(error);
    errorAddedCount++;
  }
}
```

#### c. 剔除材料处理 (`_onUpdateApplicationMaterialListWithRemovingCodes`)
- 同时剔除正常材料和错误材料
- 通过`_getErrorQrCode`辅助方法进行错误材料精确匹配
- 提供分类的剔除结果统计

**关键代码片段**:
```dart
// 处理错误材料剔除
for (final errorToRemove in bundle.errors) {
  final qrCodeToRemove = _getErrorQrCode(errorToRemove);
  
  for (int i = currentErrorMaterials.length - 1; i >= 0; i--) {
    final existingQrCode = _getErrorQrCode(currentErrorMaterials[i]);
    if (existingQrCode == qrCodeToRemove && qrCodeToRemove.isNotEmpty) {
      currentErrorMaterials.removeAt(i);
      removedErrorCount++;
      break;
    }
  }
}
```

#### d. 辅助方法
```dart
/// 从错误材料对象中提取qrCode
String _getErrorQrCode(dynamic error) {
  if (error is Map<String, dynamic>) {
    return error['qrCode']?.toString() ?? error['qr_code']?.toString() ?? '';
  }
  try {
    return (error as dynamic).qrCode?.toString() ?? '';
  } catch (e) {
    return '';
  }
}
```

### 3. 用户界面层 (DispatchApplicationPage)
**文件**: `lib/pages/dispatch/dispatch_application_page.dart`

**UI集成**:

#### a. 材料列表重构
```dart
Widget _buildMaterialList(List<MaterialVO> materials) {
  return UnifiedCard(
    child: BlocBuilder<DispatchBloc, DispatchState>(
      builder: (context, state) {
        return Column(
          children: [
            // 正常材料列表
            if (materials.isNotEmpty) ...[
              ...materials.map((material) => MaterialListItem(...)),
            ],
            
            // 错误材料区域
            if (state.errorMaterials.isNotEmpty) ...[
              if (materials.isNotEmpty) const SizedBox(height: AppTheme.spacingMedium),
              ErrorMaterialSection(
                errors: state.errorMaterials,
                onErrorItemTap: _handleErrorMaterialTap,
              ),
            ],
          ],
        );
      },
    ),
  );
}
```

#### b. 错误材料详情处理
```dart
void _handleErrorMaterialTap(dynamic errorMaterial) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('异常材料详情'),
      content: Text(errorInfo),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('确定'),
        ),
      ],
    ),
  );
}
```

#### c. 提交确认机制
```dart
void _submit() async {
  // 检查是否有错误材料，如有则显示确认对话框
  if (state.errorMaterials.isNotEmpty) {
    final shouldContinue = await _showErrorMaterialSubmitConfirmation(
      state.errorMaterials.length,
    );
    if (!shouldContinue) {
      return; // 用户取消提交
    }
  }
  // ... 继续提交逻辑
}
```

#### d. 提交确认对话框
```dart
Future<bool> _showErrorMaterialSubmitConfirmation(int errorCount) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => SubmitConfirmationDialog(
      normalCount: context.read<DispatchBloc>().state.materialList?.length ?? 0,
      errorCount: errorCount,
      title: '调拨申请提交确认',
      businessType: 'dispatch',
      // ... 回调处理
    ),
  );
  return result == true;
}
```

## 功能特性

### ✅ 错误材料显示
- 在正常材料列表下方独立显示错误材料区域
- 使用`ErrorMaterialSection`组件，支持折叠/展开
- 点击错误材料可查看详细信息

### ✅ 错误材料管理
- **初始化**: 扫码初始化时同时加载正常材料和错误材料
- **追加**: 继续扫码时能同时追加正常和错误材料，避免重复
- **剔除**: 扫码剔除时能精确匹配并移除错误材料

### ✅ 提交保护机制
- 提交调拨申请前检查是否存在错误材料
- 如有错误材料，显示"异常材料已单独列出，请确认真实材料状态再进行提交"警告
- 用户必须明确确认才能继续提交

### ✅ 用户体验优化
- 详细的操作反馈信息（如"已添加 2 个正常材料，3 个异常材料"）
- 一致的视觉设计和交互模式
- 错误材料使用红色主题突出显示

## 技术实现

### 数据流向
1. **扫码** → `MaterialHandleRepository.scanBatchToQueryAll()` → `MaterialInfoForBusiness{normals, errors}`
2. **状态更新** → `DispatchBloc.emit()` → `DispatchState{materialList, errorMaterials}`
3. **UI渲染** → `BlocBuilder<DispatchBloc, DispatchState>` → 正常材料列表 + `ErrorMaterialSection`

### 状态管理模式
- 使用Flutter BLoC模式管理状态
- 状态不可变，通过`copyWith`方法更新
- 支持状态监听和响应式UI更新

### 错误处理
- 健壮的错误材料数据提取（支持Map和对象格式）
- QR码匹配的容错处理
- 用户操作的异常捕获和友好提示

## 与其他页面的一致性

| 功能         | Acceptance页面             | JSF Acceptance页面         | Dispatch Application页面   | 一致性 |
|--------------|----------------------------|----------------------------|----------------------------|--------|
| 错误材料显示 | ✅ ErrorMaterialSection     | ✅ ErrorMaterialSection     | ✅ ErrorMaterialSection     | ✅      |
| 错误材料剔除 | ✅ 支持                     | ✅ 支持                     | ✅ 支持                     | ✅      |
| 提交确认机制 | ✅ SubmitConfirmationDialog | ✅ SubmitConfirmationDialog | ✅ SubmitConfirmationDialog | ✅      |
| 操作反馈信息 | ✅ 详细分类统计             | ✅ 详细分类统计             | ✅ 详细分类统计             | ✅      |
| 视觉设计     | ✅ 红色主题                 | ✅ 红色主题                 | ✅ 红色主题                 | ✅      |

## 编译验证
- ✅ `DispatchState` 编译正常
- ✅ `DispatchBloc` 编译正常  
- ✅ `DispatchApplicationPage` 编译正常
- ✅ 所有依赖组件正确导入

## 业务场景适配

### 调拨申请特殊需求
1. **项目间调拨**: 支持从源项目调拨到目标项目
2. **仓库管理**: 集成仓库负责人推送机制
3. **权限控制**: 基于用户角色的操作权限
4. **审批流程**: 错误材料不影响正常的调拨审批流程

### 与验收页面的差异
- **业务上下文**: 调拨申请 vs 材料验收
- **数据结构**: `MaterialVO` vs `MaterialInfo`
- **状态管理**: `DispatchBloc` vs `AcceptanceBloc`/`JsfAcceptanceCubit`
- **UI主题**: 'dispatch' vs 'acceptance'/'jsf_acceptance'

## 后续扩展建议

1. **调拨记录**: 将错误材料信息记录到调拨历史中
2. **统计报表**: 添加错误材料的统计分析功能
3. **批量操作**: 支持批量处理错误材料状态
4. **流程优化**: 根据错误类型提供处理建议

## 总结
Dispatch Application页面现在具备了完整的错误材料处理能力，与acceptance和JSF acceptance页面保持功能和体验的一致性。用户可以在调拨申请过程中完整地查看、管理错误材料，并在提交时获得适当的确认提示，确保调拨流程的完整性和数据的准确性。

调拨申请业务流程现在更加健壮，能够有效处理扫码过程中出现的异常材料，为用户提供清晰的操作指引和确认机制。
