# Recovery页面使用指南

## 页面概述

Recovery页面是材料回收模块的用户界面，实现了从供应商选择到动态表单填写的完整回收流程。页面采用了级联选择的设计模式，为用户提供了直观的材料回收操作体验。

## 功能特性

### 🎯 核心功能
- **级联选择流程**：制造厂家 → 材料大类 → 材料类型 → 动态表单
- **动态表单生成**：根据选择的材料类型自动生成相应的属性字段
- **二维码扫描**：支持备用码扫描功能
- **实时验证**：表单字段实时验证和错误提示
- **状态管理**：完整的加载、错误、成功状态处理

### 📱 用户体验
- **响应式布局**：适配不同屏幕尺寸
- **Material Design**：遵循Material Design设计规范
- **一致性体验**：与项目其他页面保持设计一致性
- **友好提示**：清晰的加载状态和错误信息

## 页面结构

```
RecoveryPage
├── AppBar (应用栏)
│   ├── Title: "材料回收"
│   └── Back Button
├── Body (主体内容)
│   ├── 基本信息卡片
│   │   ├── 制造厂家 (下拉选择)
│   │   ├── 材料大类 (级联下拉)
│   │   └── 材料类型 (级联下拉)
│   ├── 材料属性卡片 (动态生成)
│   │   └── 动态表单字段
│   ├── 扫描备用码按钮
│   └── 操作按钮
│       ├── 取消按钮
│       └── 确定按钮
```

## 状态流程

### 1. 初始化流程
```
RecoveryInitial → RecoveryLoading → RecoveryVendorsLoaded
```

### 2. 级联选择流程
```
RecoveryVendorsLoaded 
    ↓ (选择供应商)
RecoveryCategoriesLoaded 
    ↓ (选择材料分类)
RecoveryTypesLoaded 
    ↓ (选择材料类型)
RecoveryFormReady
```

### 3. 表单提交流程
```
RecoveryFormReady 
    ↓ (验证表单)
RecoveryValidationError | RecoverySubmitting 
    ↓ (提交成功)
RecoverySubmissionSuccess
```

## 使用方法

### 基本使用

#### 1. 路由导航
```dart
// 导航到Recovery页面
context.go('/recovery');

// 或使用命名路由
context.goNamed('recovery');
```

#### 2. 页面集成
```dart
import 'package:pipe_code_flutter/pages/recovery/recovery_pages.dart';

// 在路由配置中已经包含
GoRoute(
  path: '/recovery',
  name: 'recovery',
  builder: (context, state) {
    return const RecoveryPage();
  },
),
```

### 高级用法

#### 1. 监听页面结果
```dart
final result = await context.push('/recovery');
if (result != null) {
  // 处理回收结果
  print('回收操作完成: $result');
}
```

#### 2. 自定义扫描处理
页面内部的扫描功能可以根据需要扩展：

```dart
// 在_handleScanQRCode方法中处理扫描结果
context.push('/qr_scan', extra: scanConfig).then((result) {
  if (result != null && result is List<String> && result.isNotEmpty) {
    // 自定义处理逻辑
    _processScannedCode(result.first);
  }
});
```

## 技术实现

### 依赖组件
- **RecoveryBloc**: 状态管理和业务逻辑
- **RecoveryRepository**: 数据访问层
- **QrScanPage**: 二维码扫描功能
- **ToastUtils**: 消息提示工具

### 关键代码片段

#### 状态监听和处理
```dart
BlocConsumer<RecoveryBloc, RecoveryState>(
  listener: (context, state) {
    if (state is RecoveryError) {
      ToastUtils.showError(context, state.message);
    } else if (state is RecoverySubmissionSuccess) {
      ToastUtils.showSuccess(context, state.message);
      Navigator.of(context).pop();
    }
  },
  builder: (context, state) {
    return _buildContent(context, state);
  },
)
```

#### 级联下拉选择
```dart
DropdownButtonFormField<VendorOption>(
  value: selectedVendor,
  items: vendorOptions.map((vendor) {
    return DropdownMenuItem(
      value: vendor,
      child: Text(vendor.name),
    );
  }).toList(),
  onChanged: (VendorOption? value) {
    if (value != null) {
      context.read<RecoveryBloc>().add(
        RecoveryVendorSelected(vendorCode: value.code),
      );
    }
  },
  // ...
)
```

#### 动态表单生成
```dart
...state.formFields.map((field) => 
  TextFormField(
    controller: _controllers[field.key],
    decoration: InputDecoration(
      labelText: field.key,
      errorText: state.fieldErrors[field.key],
    ),
    onChanged: (value) {
      context.read<RecoveryBloc>().add(
        RecoveryFormFieldChanged(fieldKey: field.key, value: value),
      );
    },
  ),
),
```

## 自定义配置

### 主题定制
页面使用Material Design主题，可以通过修改应用主题来定制外观：

```dart
ThemeData(
  primaryColor: Colors.blue,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  // 其他主题配置...
)
```

### 验证规则
可以在页面级别添加自定义验证逻辑：

```dart
validator: (value) {
  if (field.key.contains('必填') && (value == null || value.trim().isEmpty)) {
    return '该字段为必填项';
  }
  // 添加其他验证规则...
  return null;
},
```

## 错误处理

### 常见错误及解决方案

#### 1. 网络连接错误
```
症状：页面显示"加载基础数据失败"
解决：检查网络连接，点击重试按钮
```

#### 2. 数据格式错误
```
症状：选择后没有响应或显示错误
解决：检查API数据格式是否正确
```

#### 3. 验证失败
```
症状：提交时显示验证错误
解决：检查必填字段是否填写完整
```

### 调试支持
页面包含详细的日志记录，可以通过Logger查看运行状态：

```dart
Logger.info('Recovery初始化开始', tag: 'RecoveryBloc');
Logger.error('预加载数据失败: ${result.msg}', tag: 'RecoveryBloc');
```

## 性能优化

### 内存管理
- 自动清理TextEditingController
- 合理的状态更新策略
- 及时释放不使用的资源

### 用户体验优化
- 加载状态指示
- 防抖处理避免重复操作
- 智能错误恢复

## 扩展建议

### 1. 添加新的表单字段类型
在`RetrieveBack`模型中添加字段类型支持：

```dart
enum FieldType { text, number, date, select }

class RetrieveBack {
  final FieldType type;
  // ...
}
```

### 2. 支持批量操作
扩展页面支持批量回收：

```dart
class RecoveryPage extends StatelessWidget {
  final bool isBatch;
  const RecoveryPage({this.isBatch = false});
}
```

### 3. 离线支持
添加离线数据缓存和同步功能：

```dart
class OfflineRecoveryCache {
  static Future<void> cacheFormData(Map<String, dynamic> data) async {
    // 实现离线缓存逻辑
  }
}
```

## 注意事项

⚠️ **重要提醒**

1. **状态管理**：确保Bloc实例正确注入和销毁
2. **内存泄漏**：及时清理TextEditingController和监听器
3. **用户体验**：提供清晰的加载和错误状态
4. **数据一致性**：确保级联选择的数据同步
5. **网络处理**：妥善处理网络异常和超时

## 更新日志

### v1.0.0 (2025-08-22)
- ✨ 初始版本发布
- 🎯 实现完整的回收流程
- 📱 响应式UI设计
- 🔧 集成二维码扫描
- 🛡️ 完善的错误处理
- 📝 详细的文档说明
