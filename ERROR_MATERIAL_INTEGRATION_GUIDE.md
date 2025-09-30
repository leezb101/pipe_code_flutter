# 错误材料展示功能集成指南

## 概述

本指南介绍如何在各个业务页面（acceptance、signin、signout、install、dispatch等）中集成错误材料展示功能。该功能能够在扫码获取物料时，除了展示正常材料外，还能展示从`MaterialInfoForBusiness.errors`字段中获取的异常材料信息。

## 功能特性

- ✅ 自动展示正常材料和错误材料
- ✅ 错误材料区域可折叠/展开
- ✅ 提交时自动检查错误材料并提示用户确认
- ✅ 错误材料不会参与实际提交
- ✅ 向后兼容，不影响现有业务流程
- ✅ 统一的视觉设计和交互体验

## 新增组件

### 1. ErrorMaterialListItem
展示单个错误材料的组件，包含二维码、厂家信息、错误消息等。

### 2. ErrorMaterialSection
错误材料区域组件，用于展示错误材料列表，支持折叠/展开。

### 3. MaterialBusinessDisplay
业务页面材料展示的统一组件，自动处理正常材料和错误材料的展示。

### 4. SubmitConfirmationDialog
提交确认对话框，当存在错误材料时提示用户确认。

### 5. MaterialBusinessHelper
辅助工具类，提供便捷的方法来检查错误材料、显示确认对话框等。

## 快速集成

### 方式一：使用MaterialBusinessDisplay组件（推荐）

这是最简单的集成方式，适用于新页面或大幅重构的页面。

```dart
import 'package:pipe_code_flutter/widgets/unified/unified_components.dart';
import 'package:pipe_code_flutter/utils/material_business_helper.dart';

class YourBusinessPage extends StatefulWidget {
  final MaterialInfoForBusiness? materials;
  // ...其他属性
}

class _YourBusinessPageState extends State<YourBusinessPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 其他组件...
          
          // 材料展示区域
          if (widget.materials != null)
            MaterialBusinessDisplay(
              materialInfoForBusiness: widget.materials!,
              businessType: 'your_business_type', // acceptance/signin/signout等
              onMaterialTap: _handleMaterialTap,
              onErrorMaterialTap: _handleErrorMaterialTap,
              showErrorSection: true,
              errorSectionCollapsible: true,
              errorSectionInitialExpanded: true,
            ),
          
          // 提交按钮
          ElevatedButton(
            onPressed: _handleSubmit,
            child: Text('提交'),
          ),
        ],
      ),
    );
  }

  void _handleMaterialTap(dynamic material) {
    // 处理正常材料点击
    print('Material tapped: $material');
  }

  void _handleErrorMaterialTap(dynamic error) {
    // 处理错误材料点击
    print('Error material tapped: $error');
  }

  Future<void> _handleSubmit() async {
    // 检查是否存在错误材料并显示确认对话框
    final shouldProceed = await MaterialBusinessHelper.checkBeforeSubmit(
      context,
      materialInfoForBusiness: widget.materials,
      title: '提交确认',
      businessType: 'your_business_type',
    );

    if (shouldProceed) {
      // 执行实际提交操作
      _performSubmit();
    }
  }

  void _performSubmit() {
    // 实际的提交逻辑
    // 注意：只提交normals中的数据，不提交errors中的数据
    final normals = MaterialBusinessHelper.getNormals(widget.materials);
    // ... 提交逻辑
  }
}
```

### 方式二：在现有页面中添加错误材料区域

适用于已有页面的最小改动集成。

```dart
class _ExistingBusinessPageState extends State<ExistingBusinessPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 现有的正常材料展示
          ...widget.materials?.normals?.map(_buildMaterialItem) ?? [],
          
          // 新增：错误材料展示区域
          if (MaterialBusinessHelper.hasErrors(widget.materials))
            ErrorMaterialSection(
              errors: MaterialBusinessHelper.getErrors(widget.materials),
              onErrorItemTap: _handleErrorMaterialTap,
            ),
          
          // 现有的提交按钮
          ElevatedButton(
            onPressed: _handleSubmitWithConfirmation,
            child: Text('提交'),
          ),
        ],
      ),
    );
  }

  // 现有的材料项构建方法保持不变
  Widget _buildMaterialItem(MaterialInfo material) {
    return MaterialListItem(
      // ... 现有参数
    );
  }

  void _handleErrorMaterialTap(dynamic error) {
    // 处理错误材料点击
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('错误材料详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('二维码: ${error.qrCode ?? '无'}'),
            Text('厂家编码: ${error.code ?? '无'}'),
            Text('厂家名称: ${error.name ?? '无'}'),
            Text('错误信息: ${error.msg ?? '无'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 修改现有的提交方法，增加错误材料检查
  Future<void> _handleSubmitWithConfirmation() async {
    final shouldProceed = await MaterialBusinessHelper.checkBeforeSubmit(
      context,
      materialInfoForBusiness: widget.materials,
      title: '提交确认',
      businessType: 'your_business_type',
    );

    if (shouldProceed) {
      // 调用原有的提交方法
      _originalSubmitMethod();
    }
  }

  void _originalSubmitMethod() {
    // 原有的提交逻辑保持不变
    // 只处理normals中的数据
  }
}
```

### 方式三：使用扩展方法（最便捷）

利用`MaterialBusinessPageExtension`扩展，让集成更加简洁。

```dart
class _YourBusinessPageState extends State<YourBusinessPage> 
    with MaterialBusinessPageExtension {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 使用扩展方法构建材料展示
          buildMaterialBusinessDisplay(
            materialInfoForBusiness: widget.materials,
            onMaterialTap: _handleMaterialTap,
            businessType: 'your_business_type',
          ),
          
          ElevatedButton(
            onPressed: _handleSubmit,
            child: Text('提交'),
          ),
        ],
      ),
    );
  }

  void _handleMaterialTap(dynamic material) {
    // 处理材料点击
  }

  Future<void> _handleSubmit() async {
    // 使用扩展方法检查和确认
    final shouldProceed = await showMaterialSubmitConfirmation(
      widget.materials,
      title: '提交确认',
      businessType: 'your_business_type',
    );

    if (shouldProceed) {
      _performSubmit();
    }
  }

  void _performSubmit() {
    // 提交逻辑
  }
}
```

## 各业务页面具体集成示例

### Acceptance页面集成

```dart
// lib/pages/acceptance/acceptance_page.dart

// 在现有的材料列表后添加错误材料展示
Widget _buildMaterialsList() {
  return Column(
    children: [
      // 现有的正常材料展示
      ...widget.materials?.normals?.map(_buildMaterialItem) ?? [],
      
      // 新增：错误材料展示
      if (MaterialBusinessHelper.hasErrors(widget.materials))
        ErrorMaterialSection(
          errors: MaterialBusinessHelper.getErrors(widget.materials),
          title: '验收异常材料',
          onErrorItemTap: _showErrorMaterialDetail,
        ),
    ],
  );
}

// 修改提交方法
Future<void> _handleAcceptanceSubmit() async {
  final shouldProceed = await MaterialBusinessHelper.checkBeforeSubmit(
    context,
    materialInfoForBusiness: widget.materials,
    title: '验收提交确认',
    businessType: 'acceptance',
  );

  if (shouldProceed) {
    // 原有的验收提交逻辑，只处理normals
    final normals = MaterialBusinessHelper.getNormals(widget.materials);
    context.read<AcceptanceBloc>().add(
      SubmitAcceptance(materials: normals),
    );
  }
}
```

### Signout页面集成

```dart
// lib/pages/signout/signout_page.dart

Widget _buildMaterialSection() {
  return MaterialBusinessDisplay(
    materialInfoForBusiness: widget.materials,
    businessType: 'signout',
    onMaterialTap: (material) {
      _showMaterialDetail(context, material);
    },
    onErrorMaterialTap: _handleErrorMaterialTap,
  );
}

Future<void> _handleSignoutSubmit() async {
  final shouldProceed = await MaterialBusinessHelper.checkBeforeSubmit(
    context,
    materialInfoForBusiness: widget.materials,
    title: '出库提交确认',
    businessType: 'signout',
  );

  if (shouldProceed) {
    // 执行出库逻辑
    final normalMaterials = MaterialBusinessHelper.getNormals(widget.materials);
    _performSignout(normalMaterials);
  }
}
```

### 其他业务页面

类似地，signin、install、dispatch等页面都可以按照相同的模式进行集成。

## 自定义配置

### 自定义错误材料展示

```dart
ErrorMaterialSection(
  errors: errors,
  title: '自定义标题',
  icon: Icons.custom_icon,
  collapsible: false, // 禁用折叠
  initialExpanded: false, // 初始收起
  onErrorItemTap: (error) {
    // 自定义点击处理
  },
)
```

### 自定义提交确认对话框

```dart
Future<bool?> showCustomConfirmation() {
  return showDialog<bool>(
    context: context,
    builder: (context) => SubmitConfirmationDialog(
      normalCount: normalCount,
      errorCount: errorCount,
      title: '自定义标题',
      businessType: 'custom',
      onConfirm: () {}, // 会被对话框内部处理
    ),
  );
}
```

### 自定义材料项构建器

```dart
MaterialBusinessDisplay(
  materialInfoForBusiness: materials,
  onMaterialTap: _handleTap,
  materialItemBuilder: (material) {
    // 自定义材料项展示
    return CustomMaterialWidget(material: material);
  },
)
```

## 注意事项

1. **向后兼容性**：所有新功能都是可选的，不会影响现有页面的正常运行。

2. **数据安全**：错误材料不会参与实际的业务提交，只用于展示。

3. **性能考虑**：错误材料区域支持折叠，大量错误材料不会影响页面性能。

4. **用户体验**：错误材料有明显的视觉区分，用户能够清晰地识别哪些是正常材料，哪些是异常材料。

5. **错误处理**：所有组件都有完善的错误处理，即使数据格式不符合预期也不会导致崩溃。

## 测试建议

1. **正常流程测试**：确保在没有错误材料时，页面行为与之前完全一致。

2. **错误材料展示测试**：模拟包含错误材料的响应，验证错误材料正确展示。

3. **提交确认测试**：验证在有错误材料时会显示确认对话框，在没有错误材料时正常提交。

4. **边界情况测试**：测试空错误列表、空正常材料列表等边界情况。

## 故障排除

### 常见问题

**Q: 错误材料没有显示**
A: 检查`MaterialInfoForBusiness`的`errors`字段是否包含数据，确保使用了正确的组件。

**Q: 提交时没有显示确认对话框**
A: 确保使用了`MaterialBusinessHelper.checkBeforeSubmit`方法。

**Q: 样式不符合预期**
A: 检查是否正确设置了`businessType`参数，这会影响颜色主题。

**Q: 点击错误材料没有反应**
A: 确保设置了`onErrorMaterialTap`回调函数。

## 更新日志

- **v1.0.0** (2025-09-30): 初始版本，支持基本的错误材料展示和提交确认功能。
