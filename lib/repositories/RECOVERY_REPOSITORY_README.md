# RecoveryRepository 使用说明

## 概述

`RecoveryRepository` 是Recovery模块的数据仓库层，负责数据获取、缓存管理、数据转换和验证。为Bloc层提供纯数据操作方法，不涉及UI状态管理。

## 架构关系

```
UI Layer (Widgets)
    ↕️
Bloc Layer (Business Logic & State Management)
    ↕️
Repository Layer (Data Management) ← 我们在这里
    ↕️
API Service Layer (Network Calls)
```

## 核心职责

### 1. 数据获取和缓存
- 从API获取供应商映射数据
- 从API获取物料分类数据  
- 智能缓存管理（30分钟有效期）
- 并行数据预加载

### 2. 数据查询和转换
- 基于缓存的快速数据查询
- 数据格式转换（适配UI需求）
- 关联数据查找

### 3. 数据验证和处理
- 表单数据验证
- 提交数据构建
- 错误信息收集

## 主要方法说明

### 数据获取方法

```dart
// 获取供应商映射数据（带缓存）
Future<Result<VendorsMap>> getVendorsMap()

// 获取物料分类数据（带缓存）  
Future<Result<MaterialCategoriesList>> getMaterialCategories([String? vendorCode])

// 预加载所有基础数据
Future<Result<bool>> preloadData()
```

### 数据查询方法

```dart
// 根据供应商代码获取名称
String? getVendorNameByCode(String vendorCode)

// 根据分类组别获取分类信息
MaterialCategory? getCategoryByGroup(int group)

// 根据类型编号获取物料类型信息  
MaterialType? getMaterialTypeByType(int type)

// 获取指定分类下的所有物料类型
List<MaterialType> getMaterialTypesByCategory(int categoryGroup)

// 获取指定物料类型的检索字段
List<RetrieveBack> getRetrieveBacksByType(int materialType)
```

### 数据转换方法

```dart
// 转换为供应商下拉选项
List<VendorOption> getVendorOptions()

// 转换为分类下拉选项
List<MaterialCategoryOption> getCategoryOptions()

// 转换为类型下拉选项
List<MaterialTypeOption> getTypeOptionsByCategory(int categoryGroup)
```

### 数据验证方法

```dart
// 验证表单数据
ValidationResult validateFormData(Map<String, String?> formData, int materialType)

// 构建提交数据
Map<String, String?> buildSubmissionData(int materialType, Map<String, String?> formData)
```

### 缓存管理方法

```dart
// 检查缓存是否有效
bool get hasValidCache

// 清除所有缓存
void clearCache()
```

## 使用示例

### 1. Bloc中的典型使用流程

```dart
class RecoveryBloc extends Bloc<RecoveryEvent, RecoveryState> {
  final RecoveryRepository _repository;
  
  RecoveryBloc(this._repository) : super(RecoveryInitial());
  
  // 初始化时预加载数据
  Future<void> _onInitialize() async {
    emit(RecoveryLoading());
    
    final result = await _repository.preloadData();
    if (result.isSuccess) {
      // 获取供应商选项供UI使用
      final vendorOptions = _repository.getVendorOptions();
      emit(RecoveryVendorsLoaded(vendors: vendorOptions));
    } else {
      emit(RecoveryError(message: result.msg));
    }
  }
  
  // 用户选择供应商后
  Future<void> _onVendorSelected(String vendorCode) async {
    // 获取材料分类选项
    final categoryOptions = _repository.getCategoryOptions();
    
    // 获取供应商名称
    final vendorName = _repository.getVendorNameByCode(vendorCode);
    
    emit(RecoveryCategoriesLoaded(
      selectedVendor: vendorCode,
      vendorName: vendorName,
      categories: categoryOptions,
    ));
  }
  
  // 用户选择分类后
  void _onCategorySelected(int categoryGroup) {
    // 获取该分类下的物料类型选项
    final typeOptions = _repository.getTypeOptionsByCategory(categoryGroup);
    
    emit(RecoveryTypesLoaded(
      selectedCategory: categoryGroup,
      types: typeOptions,
    ));
  }
  
  // 用户选择物料类型后
  void _onTypeSelected(int materialType) {
    // 获取动态表单字段
    final formFields = _repository.getRetrieveBacksByType(materialType);
    
    emit(RecoveryFormFieldsLoaded(
      selectedType: materialType,
      formFields: formFields,
    ));
  }
  
  // 用户提交表单
  Future<void> _onSubmitForm(Map<String, String?> formData, int materialType) async {
    // 验证表单数据
    final validation = _repository.validateFormData(formData, materialType);
    
    if (!validation.isValid) {
      emit(RecoveryValidationError(
        errors: validation.allErrorMessages,
        fieldErrors: validation.fieldErrors,
      ));
      return;
    }
    
    // 构建提交数据
    final submissionData = _repository.buildSubmissionData(materialType, formData);
    
    // 调用提交API...
    emit(RecoverySubmitting());
    // ... 提交逻辑
  }
}
```

### 2. 缓存管理示例

```dart
class RecoveryService {
  final RecoveryRepository _repository;
  
  // 应用启动时预加载数据
  Future<void> initializeApp() async {
    if (!_repository.hasValidCache) {
      await _repository.preloadData();
    }
  }
  
  // 强制刷新数据
  Future<void> refreshData() async {
    _repository.clearCache();
    await _repository.preloadData();
  }
}
```

### 3. 数据查询示例

```dart
class RecoveryHelper {
  final RecoveryRepository _repository;
  
  // 获取完整的表单配置
  FormConfig? getFormConfig(int materialType) {
    final materialTypeInfo = _repository.getMaterialTypeByType(materialType);
    if (materialTypeInfo == null) return null;
    
    final formFields = _repository.getRetrieveBacksByType(materialType);
    
    return FormConfig(
      typeName: materialTypeInfo.name,
      fields: formFields.map((field) => FormFieldConfig(
        key: field.key,
        label: field.name,
        isRequired: true,
        placeholder: '请输入${field.name}',
      )).toList(),
    );
  }
  
  // 验证并格式化提交数据
  SubmissionResult prepareSubmission(
    int materialType, 
    Map<String, String?> userInput,
  ) {
    final validation = _repository.validateFormData(userInput, materialType);
    
    if (!validation.isValid) {
      return SubmissionResult.error(validation.allErrorMessages);
    }
    
    final submissionData = _repository.buildSubmissionData(materialType, userInput);
    return SubmissionResult.success(submissionData);
  }
}
```

## ValidationResult 详细说明

### 属性说明
- `isValid`: 验证是否通过
- `errorMessages`: 全局错误信息列表
- `fieldErrors`: 字段级错误信息 (fieldKey -> errorMessage)
- `hasErrors`: 是否有任何错误
- `allErrorMessages`: 所有错误信息（全局 + 字段）

### 使用示例
```dart
final validation = repository.validateFormData(formData, materialType);

if (validation.hasErrors) {
  // 显示全局错误
  for (final error in validation.errorMessages) {
    showSnackBar(error);
  }
  
  // 显示字段错误
  validation.fieldErrors.forEach((fieldKey, errorMessage) {
    highlightFieldError(fieldKey, errorMessage);
  });
}
```

## 缓存策略

### 缓存机制
- **有效期**: 30分钟
- **缓存数据**: VendorsMap、MaterialCategoriesList
- **缓存检查**: 每次查询前自动检查缓存有效性
- **智能刷新**: 缓存过期时自动从API重新获取

### 缓存优势
1. **性能提升**: 避免重复的网络请求
2. **离线支持**: 缓存期间可离线使用基础功能
3. **用户体验**: 快速响应，减少等待时间
4. **网络优化**: 减少带宽消耗

## 注意事项

1. **数据依赖**: 大部分查询方法依赖缓存数据，使用前确保已调用相应的获取方法
2. **错误处理**: 所有异步方法都返回Result类型，需要检查isSuccess
3. **空值处理**: 查询方法可能返回null，使用前需要检查
4. **缓存时效**: 缓存有30分钟有效期，超时后会自动重新获取
5. **线程安全**: 所有方法都是线程安全的，可以在不同线程中调用
