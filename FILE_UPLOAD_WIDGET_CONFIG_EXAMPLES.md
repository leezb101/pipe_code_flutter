# FileUploadWidget 配置参数使用示例

## enableGalleryPicker 参数说明

`enableGalleryPicker` 是一个可选的布尔型参数，用于控制文件上传组件的行为模式。

### 参数值说明

| 参数值  | 默认值 | 行为描述                                               |
|---------|--------|--------------------------------------------------------|
| `true`  | ✅ 是   | 点击上传按钮弹出选择菜单（相册/文件），用户可选择上传方式 |
| `false` | ❌ 否   | 点击上传按钮直接打开文件选择器，跳过选择菜单            |

---

## 使用示例

### 示例 1: 默认模式（启用相册选择）

适用场景：需要上传图片或 PDF 文档，希望提供灵活的选择方式

```dart
BlocBuilder<FileUploadCubit, List<FileUploadState>>(
  bloc: _inspectionReportsCubit,
  builder: (context, states) {
    return FileUploadWidget(
      title: '报验单(图片或pdf)',
      states: states,
      allowedExtensions: const ['pdf', 'jpg', 'png', 'heic'],
      maxFiles: 5,
      // enableGalleryPicker: true, // 默认为 true，可省略
      onAdd: (files) => _inspectionReportsCubit.addFiles(files),
      onRemove: (uniqueId) => _inspectionReportsCubit.removeFile(uniqueId),
      onRetry: (uniqueId) => _inspectionReportsCubit.retryUpload(uniqueId),
    );
  },
)
```

**用户体验流程：**
1. 点击"点击上传文件"按钮
2. 弹出选择菜单
3. 选择"从相册选择"或"从文件选择"
4. 完成文件选择和上传

---

### 示例 2: 仅文件选择模式（禁用相册选择）

适用场景：主要上传 PDF 等非图片文件，或不需要相册选择功能

```dart
BlocBuilder<FileUploadCubit, List<FileUploadState>>(
  bloc: _contractCubit,
  builder: (context, states) {
    return FileUploadWidget(
      title: '合同文件(仅pdf)',
      states: states,
      allowedExtensions: const ['pdf'],
      maxFiles: 3,
      enableGalleryPicker: false, // 🔥 禁用相册选择，直接打开文件选择器
      onAdd: (files) => _contractCubit.addFiles(files),
      onRemove: (uniqueId) => _contractCubit.removeFile(uniqueId),
      onRetry: (uniqueId) => _contractCubit.retryUpload(uniqueId),
    );
  },
)
```

**用户体验流程：**
1. 点击"点击上传文件"按钮
2. 直接打开文件选择器（跳过选择菜单）
3. 完成文件选择和上传

---

### 示例 3: 验收报告（启用相册选择）

```dart
BlocBuilder<FileUploadCubit, List<FileUploadState>>(
  bloc: _acceptanceReportsCubit,
  builder: (context, states) {
    return FileUploadWidget(
      title: '验收报告(图片或pdf)',
      states: states,
      allowedExtensions: const ['pdf', 'jpg', 'png', 'heic'],
      maxFiles: 2,
      enableGalleryPicker: true, // 显式启用相册选择
      onAdd: (files) => _acceptanceReportsCubit.addFiles(files),
      onRemove: (uniqueId) => _acceptanceReportsCubit.removeFile(uniqueId),
      onRetry: (uniqueId) => _acceptanceReportsCubit.retryUpload(uniqueId),
    );
  },
)
```

---

### 示例 4: 技术文档上传（禁用相册选择）

```dart
BlocBuilder<FileUploadCubit, List<FileUploadState>>(
  bloc: _technicalDocsCubit,
  builder: (context, states) {
    return FileUploadWidget(
      title: '技术文档(pdf/word)',
      states: states,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
      maxFiles: 10,
      enableGalleryPicker: false, // 禁用相册选择（不支持图片格式）
      onAdd: (files) => _technicalDocsCubit.addFiles(files),
      onRemove: (uniqueId) => _technicalDocsCubit.removeFile(uniqueId),
      onRetry: (uniqueId) => _technicalDocsCubit.retryUpload(uniqueId),
    );
  },
)
```

---

## 决策树：何时使用哪个配置？

```
是否需要上传图片？
├─ 是 → 是否希望用户从相册选择？
│      ├─ 是 → enableGalleryPicker: true（或省略，使用默认值）
│      └─ 否 → enableGalleryPicker: false
└─ 否（仅文档类文件）→ enableGalleryPicker: false
```

---

## 配置建议

### ✅ 推荐启用相册选择的场景

- 📸 **施工照片**：用户通常从相册选择现场拍摄的照片
- 📋 **报验单**：可能是图片或 PDF，提供选择更灵活
- 📄 **验收报告**：支持图片扫描件或 PDF 文件
- 🖼️ **现场图片**：任何需要拍照或从相册选择的场景

### ✅ 推荐禁用相册选择的场景

- 📑 **合同文件**：通常是 PDF 格式，不需要相册选择
- 📊 **Excel 报表**：纯文档类型上传
- 📝 **技术文档**：Word、PDF 等办公文档
- 🗂️ **备份文件**：ZIP、RAR 等压缩文件

---

## 兼容性说明

### 向后兼容

所有现有代码无需修改，默认行为保持一致（启用相册选择）：

```dart
// 旧代码 - 无需修改，自动启用相册选择功能
FileUploadWidget(
  title: '报验单',
  states: states,
  allowedExtensions: const ['pdf', 'jpg', 'png'],
  maxFiles: 5,
  onAdd: (files) => _cubit.addFiles(files),
  onRemove: (uniqueId) => _cubit.removeFile(uniqueId),
  onRetry: (uniqueId) => _cubit.retryUpload(uniqueId),
)
```

### 新功能使用

需要禁用相册选择时，只需添加一个参数：

```dart
// 新代码 - 添加 enableGalleryPicker 参数
FileUploadWidget(
  title: '合同文件',
  states: states,
  allowedExtensions: const ['pdf'],
  maxFiles: 3,
  enableGalleryPicker: false, // 🆕 新增配置
  onAdd: (files) => _cubit.addFiles(files),
  onRemove: (uniqueId) => _cubit.removeFile(uniqueId),
  onRetry: (uniqueId) => _cubit.retryUpload(uniqueId),
)
```

---

## 总结

`enableGalleryPicker` 参数提供了灵活的配置选项：

- ✨ **默认体验**：启用相册选择，提供更好的用户体验
- 🎯 **简化流程**：禁用相册选择，直接打开文件选择器
- 🔄 **向后兼容**：无需修改现有代码
- 🛠️ **灵活配置**：根据实际业务需求选择合适的模式

根据上传文件的类型和用户使用场景，选择合适的配置以提供最佳的用户体验！
