# Recovery Bloc 使用指南

## 概述

Recovery Bloc 是回收模块的业务逻辑层，负责管理供应商选择、材料分类选择、材料类型选择以及动态表单的状态管理。它采用 BLoC 模式，实现了清晰的关注点分离和状态管理。

## 架构设计

```
UI Layer (RecoveryPage)
     ↓
Bloc Layer (RecoveryBloc)
     ↓
Repository Layer (RecoveryRepository)
     ↓
API Service Layer (RecoveryApiService)
```

## 核心功能

### 1. 数据预加载
- 应用启动时自动加载供应商数据和材料分类数据
- 支持缓存机制，避免重复加载
- 处理网络错误和数据异常

### 2. 级联选择流程
1. **供应商选择** → 加载材料分类
2. **材料分类选择** → 加载材料类型
3. **材料类型选择** → 生成动态表单
4. **表单填写** → 验证并提交

### 3. 动态表单管理
- 根据材料类型动态生成表单字段
- 实时验证用户输入
- 支持必填字段和格式验证
- 提供友好的错误提示

## 状态管理

### 状态层次结构

```dart
RecoveryState
├── RecoveryInitial          // 初始状态
├── RecoveryLoading          // 加载中
├── RecoveryError            // 错误状态
├── RecoveryVendorsLoaded    // 供应商已加载
├── RecoveryCategoriesLoaded // 材料分类已加载
├── RecoveryTypesLoaded      // 材料类型已加载
├── RecoveryFormReady        // 表单准备就绪
├── RecoveryValidationError  // 验证错误
├── RecoverySubmitting       // 提交中
└── RecoverySubmissionSuccess // 提交成功
```

### 事件处理

```dart
// 初始化事件
RecoveryInitialized()

// 数据刷新事件
RecoveryDataRefreshed(forceRefresh: true)

// 选择事件
RecoveryVendorSelected(vendorCode: 'vendor_001')
RecoveryCategorySelected(categoryGroup: 'pipes')
RecoveryMaterialTypeSelected(materialType: 'steel_pipe')

// 表单事件
RecoveryFormFieldChanged(fieldKey: 'diameter', value: '100')
RecoveryFormValidated()
RecoveryFormSubmitted()
RecoveryFormReset()
```

## 使用示例

### 1. 页面初始化

```dart
class RecoveryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RecoveryBloc>()
        ..add(const RecoveryInitialized()),
      child: RecoveryView(),
    );
  }
}
```

### 2. 状态监听

```dart
BlocListener<RecoveryBloc, RecoveryState>(
  listener: (context, state) {
    if (state is RecoveryError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    } else if (state is RecoverySubmissionSuccess) {
      Navigator.of(context).pop();
    }
  },
  child: BlocBuilder<RecoveryBloc, RecoveryState>(
    builder: (context, state) {
      return _buildContent(context, state);
    },
  ),
)
```

### 3. 供应商选择

```dart
void _onVendorSelected(String vendorCode) {
  context.read<RecoveryBloc>().add(
    RecoveryVendorSelected(vendorCode: vendorCode),
  );
}
```

### 4. 动态表单处理

```dart
// 表单字段变更
void _onFieldChanged(String fieldKey, String? value) {
  context.read<RecoveryBloc>().add(
    RecoveryFormFieldChanged(fieldKey: fieldKey, value: value),
  );
}

// 表单提交
void _onSubmit() {
  context.read<RecoveryBloc>().add(const RecoveryFormSubmitted());
}
```

## 错误处理

### 1. 网络错误
- 自动重试机制
- 友好的错误提示
- 支持手动刷新

### 2. 验证错误
- 实时字段验证
- 提交前整体验证
- 详细的错误消息

### 3. 状态恢复
- 支持表单重置
- 错误状态清除
- 数据重新加载

## 性能优化

### 1. 缓存策略
- Repository层实现30分钟缓存
- 避免重复API调用
- 支持强制刷新

### 2. 状态管理
- 使用不可变状态对象
- 通过copyWith实现高效更新
- 避免不必要的UI重建

### 3. 内存管理
- 适当的资源释放
- 避免内存泄漏
- 合理的依赖注入

## 扩展指南

### 1. 添加新的表单字段类型
在`RetrieveBack`模型中添加新的字段类型，并在Repository的验证逻辑中处理。

### 2. 自定义验证规则
在`RecoveryRepository.validateFormData`方法中添加自定义验证逻辑。

### 3. 新增业务流程
通过添加新的Event和State来扩展业务流程，保持状态机的清晰性。

## 调试支持

### 1. 日志记录
所有关键操作都有详细的日志记录，便于问题定位。

### 2. 状态追踪
通过BlocObserver可以追踪所有状态变化。

### 3. 错误报告
详细的错误信息和堆栈跟踪，便于问题诊断。

## 注意事项

1. **状态一致性**：确保UI状态与Bloc状态保持一致
2. **内存管理**：及时释放不需要的资源
3. **错误处理**：始终处理可能的异常情况
4. **用户体验**：提供清晰的加载状态和错误提示
5. **性能考虑**：避免频繁的状态更新和UI重建
