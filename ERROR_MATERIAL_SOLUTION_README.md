# 错误材料展示功能优化升级方案

## 方案概述

针对`MaterialInfoForBusiness`中`errors`字段被忽略的问题，我们设计了一套完整的错误材料展示解决方案。该方案在不影响现有业务流程的前提下，为所有业务页面（acceptance、signin、signout、install、dispatch等）提供了统一的错误材料展示和处理能力。

## ✅ 核心功能

1. **错误材料展示**：在扫码获取物料后，自动展示`MaterialInfoForBusiness.errors`中的异常材料
2. **视觉区分**：错误材料使用独特的红色主题设计，与正常材料明显区分
3. **提交确认**：当存在错误材料时，自动弹出确认对话框提醒用户
4. **向后兼容**：所有新功能都是可选的，不影响现有代码运行
5. **统一体验**：所有业务页面都使用相同的设计规范和交互模式

## 📁 文件结构

```
lib/
├── widgets/unified/
│   └── unified_components.dart          # 扩展了错误材料相关组件
├── utils/
│   └── material_business_helper.dart    # 业务辅助工具类
├── examples/
│   └── acceptance_page_with_error_material.dart  # 完整集成示例
└── ERROR_MATERIAL_INTEGRATION_GUIDE.md # 详细集成指南
```

## 🚀 新增组件

### 1. ErrorMaterialListItem
```dart
ErrorMaterialListItem(
  qrCode: error.qrCode,
  vendorCode: error.code,
  vendorName: error.name,
  errorMessage: error.msg,
  onTap: () => _handleErrorTap(error),
)
```

### 2. ErrorMaterialSection
```dart
ErrorMaterialSection(
  errors: materialInfo.errors,
  title: '异常材料',
  collapsible: true,
  onErrorItemTap: _handleErrorTap,
)
```

### 3. MaterialBusinessDisplay
```dart
MaterialBusinessDisplay(
  materialInfoForBusiness: materials,
  businessType: 'acceptance',
  onMaterialTap: _handleMaterialTap,
  onErrorMaterialTap: _handleErrorTap,
)
```

### 4. SubmitConfirmationDialog
```dart
SubmitConfirmationDialog(
  normalCount: 5,
  errorCount: 2,
  businessType: 'acceptance',
  onConfirm: () => _performSubmit(),
)
```

## 🛠 工具类

### MaterialBusinessHelper
提供便捷的静态方法：

```dart
// 检查是否有错误材料
bool hasErrors = MaterialBusinessHelper.hasErrors(materials);

// 获取错误材料数量
int errorCount = MaterialBusinessHelper.getErrorCount(materials);

// 显示提交确认对话框
bool shouldProceed = await MaterialBusinessHelper.checkBeforeSubmit(
  context,
  materialInfoForBusiness: materials,
  businessType: 'acceptance',
);
```

## 📖 使用示例

### 快速集成（推荐）

```dart
class _YourBusinessPageState extends State<YourBusinessPage> {
  
  Widget _buildMaterialSection() {
    return MaterialBusinessDisplay(
      materialInfoForBusiness: widget.materials,
      businessType: 'your_business_type',
      onMaterialTap: _handleMaterialTap,
      onErrorMaterialTap: _handleErrorMaterialTap,
    );
  }

  Future<void> _handleSubmit() async {
    final shouldProceed = await MaterialBusinessHelper.checkBeforeSubmit(
      context,
      materialInfoForBusiness: widget.materials,
      businessType: 'your_business_type',
    );

    if (shouldProceed) {
      // 只提交normals中的数据
      final normals = MaterialBusinessHelper.getNormals(widget.materials);
      _performActualSubmit(normals);
    }
  }
}
```

### 最小改动集成

```dart
class _ExistingPageState extends State<ExistingPage> {
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 现有的正常材料展示
        ...widget.materials?.normals?.map(_buildMaterialItem) ?? [],
        
        // 新增：错误材料展示
        if (MaterialBusinessHelper.hasErrors(widget.materials))
          ErrorMaterialSection(
            errors: MaterialBusinessHelper.getErrors(widget.materials),
          ),
        
        // 现有的提交按钮（修改onPressed）
        ElevatedButton(
          onPressed: _handleSubmitWithCheck,
          child: Text('提交'),
        ),
      ],
    );
  }

  Future<void> _handleSubmitWithCheck() async {
    final shouldProceed = await MaterialBusinessHelper.checkBeforeSubmit(
      context,
      materialInfoForBusiness: widget.materials,
    );
    if (shouldProceed) _originalSubmitMethod();
  }
}
```

## 🎨 设计特点

- **红色主题**：错误材料使用红色系设计，视觉上与正常材料明显区分
- **信息完整**：展示二维码、厂家编码、厂家名称、错误信息等完整信息
- **可折叠**：错误材料区域支持折叠/展开，不影响页面性能
- **统计展示**：页面头部显示正常材料和错误材料的数量统计
- **提示说明**：清晰提示用户错误材料不会参与提交

## ⚠️ 重要提醒

1. **数据安全**：错误材料仅用于展示，不会参与业务提交
2. **向后兼容**：现有页面无需修改即可正常运行
3. **性能优化**：大量错误材料时支持折叠，不影响页面性能
4. **用户体验**：提供清晰的视觉提示和操作确认

## 📚 文档参考

- [详细集成指南](ERROR_MATERIAL_INTEGRATION_GUIDE.md)
- [完整示例代码](lib/examples/acceptance_page_with_error_material.dart)
- [组件API文档](lib/widgets/unified/unified_components.dart)
- [工具类文档](lib/utils/material_business_helper.dart)

## 🔄 升级路径

1. **Phase 1**：在一个业务页面中试验集成（如acceptance页面）
2. **Phase 2**：逐步推广到其他业务页面
3. **Phase 3**：根据用户反馈优化交互和视觉设计

## 🤝 支持

如有集成问题或建议，请参考文档或联系开发团队。
