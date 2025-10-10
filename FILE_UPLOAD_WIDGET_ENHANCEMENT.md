# FileUploadWidget 增强说明

## 修改日期
2025年10月10日

## 修改目的
为 `FileUploadWidget` 增加从相册选择图片的功能，让用户在上传"报验单"和"验收报告"时可以选择从相册选择图片或从文件管理器选择文件。

## 修改内容

### 1. 新增依赖
- 引入 `image_picker` 包，用于相册选择功能

### 2. 新增方法

#### `_pickImagesFromGallery()`
从相册选择图片文件的方法：
- 支持单选和多选（根据剩余可上传数量自动判断）
- 图片质量压缩到 80%
- 最大宽度限制为 1920px
- 自动处理超出限制的情况，并给用户提示

#### `_showUploadOptions()`
显示上传方式选择的底部弹窗：
- **从相册选择**：使用 `ImagePicker` 从相册选择图片文件
- **从文件选择**：使用原有的 `FilePicker` 从文件管理器选择文件
- **取消**：关闭弹窗

### 3. 新增配置参数

#### `enableGalleryPicker`
布尔型可选参数，默认值为 `true`：
- **true**（默认）：点击上传按钮时弹出选择菜单（相册/文件）
- **false**：点击上传按钮时直接打开文件选择器，跳过选择菜单

### 4. 修改内容
- 修改 `_buildAddFileButton()` 中的点击事件，从直接调用 `_pickFiles()` 改为调用 `_showUploadOptions()`
- 在 `_showUploadOptions()` 方法中增加判断逻辑，根据 `enableGalleryPicker` 参数决定是否显示弹窗

## 使用方式

### 默认使用（启用相册选择）
无需修改任何代码，原有的调用方式保持不变，默认启用相册选择功能：

```dart
FileUploadWidget(
  title: '报验单(图片或pdf)',
  states: states,
  allowedExtensions: const ['pdf', 'jpg', 'png', 'heic'],
  maxFiles: 5,
  onAdd: (files) => _inspectionReportsCubit.addFiles(files),
  onRemove: (uniqueId) => _inspectionReportsCubit.removeFile(uniqueId),
  onRetry: (uniqueId) => _inspectionReportsCubit.retryUpload(uniqueId),
  // enableGalleryPicker: true, // 可选，默认为 true
)
```

### 禁用相册选择（仅使用文件选择器）
如果需要禁用相册选择功能，只使用文件选择器，可以设置 `enableGalleryPicker` 为 `false`：

```dart
FileUploadWidget(
  title: '报验单(图片或pdf)',
  states: states,
  allowedExtensions: const ['pdf', 'jpg', 'png', 'heic'],
  maxFiles: 5,
  enableGalleryPicker: false, // 禁用相册选择，点击直接打开文件选择器
  onAdd: (files) => _inspectionReportsCubit.addFiles(files),
  onRemove: (uniqueId) => _inspectionReportsCubit.removeFile(uniqueId),
  onRetry: (uniqueId) => _inspectionReportsCubit.retryUpload(uniqueId),
)
```

## 用户体验流程

### 启用相册选择模式（默认）
1. 用户点击"点击上传文件"按钮
2. 弹出底部弹窗，显示两个选项：
   - **从相册选择**：打开系统相册，用户可以选择图片文件
   - **从文件选择**：打开文件管理器，用户可以选择支持的文件格式（pdf、jpg、png、heic）
3. 用户选择完成后，文件自动上传

### 禁用相册选择模式
1. 用户点击"点击上传文件"按钮
2. 直接打开文件管理器，用户可以选择支持的文件格式
3. 用户选择完成后，文件自动上传

## 功能特点

1. **灵活配置**：通过 `enableGalleryPicker` 参数控制是否启用相册选择
2. **智能选择**：根据 `allowedExtensions` 中包含的图片格式，自动支持相册选择
3. **数量限制**：自动根据 `maxFiles` 和当前已上传数量计算剩余可选数量
4. **用户友好**：选择超出限制时会自动截取并提示用户
5. **向后兼容**：不需要修改现有代码，完全兼容旧的调用方式（默认行为与增强后一致）

## 技术实现

### 相册选择逻辑
```dart
if (remainingSlots == 1) {
  // 单张选择
  final XFile? pickedFile = await _imagePicker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 80,
    maxWidth: 1920,
  );
} else {
  // 多选
  pickedFiles = await _imagePicker.pickMultiImage(
    imageQuality: 80,
    maxWidth: 1920,
    limit: remainingSlots,
  );
}
```

### 弹窗选择界面
使用 `showModalBottomSheet` 创建底部弹窗，提供清晰的选择界面：
- 相册图标（蓝色）+ "从相册选择"
- 文件夹图标（橙色）+ "从文件选择"
- 取消图标（灰色）+ "取消"

## 使用场景建议

### 推荐启用相册选择（enableGalleryPicker: true）
适用于以下场景：
- 用户主要上传图片文件（如照片、截图）
- 需要支持多种文件格式（图片 + PDF 等）
- 希望提供更友好的用户体验（让用户选择最方便的方式）
- 例如：**报验单**、**验收报告**、**施工照片**等

### 推荐禁用相册选择（enableGalleryPicker: false）
适用于以下场景：
- 主要上传非图片文件（如 PDF、Word 文档等）
- 不需要从相册选择的场景
- 需要简化操作流程，直接进入文件选择
- 例如：纯文档类上传、合同上传等

## 注意事项

1. **权限要求**（仅当 enableGalleryPicker 为 true 时需要）：
   - iOS: 需要在 Info.plist 中添加相册访问权限
   - Android: 需要在 AndroidManifest.xml 中添加存储权限

2. **文件格式**：
   - 相册选择只能选择图片格式
   - 如需选择 PDF 等其他格式，请使用"从文件选择"选项
   - 禁用相册选择时，所有文件格式均通过文件选择器选择

3. **性能优化**：
   - 图片自动压缩到 80% 质量（仅从相册选择时）
   - 最大宽度限制为 1920px（仅从相册选择时）
   - 避免上传过大的文件

## 测试建议

### 启用相册选择模式测试（enableGalleryPicker: true）
1. 测试点击上传按钮是否弹出选择菜单
2. 测试从相册选择单张图片
3. 测试从相册选择多张图片
4. 测试达到数量限制时的行为
5. 测试选择超出限制数量时的提示
6. 测试从文件选择 PDF 文件
7. 测试取消操作

### 禁用相册选择模式测试（enableGalleryPicker: false）
1. 测试点击上传按钮是否直接打开文件选择器
2. 测试从文件选择器选择图片文件
3. 测试从文件选择器选择 PDF 文件
4. 测试达到数量限制时的行为

## 相关文件

- `/lib/widgets/file_upload/file_upload_widget.dart` - 主要修改文件
- `/lib/pages/acceptance/acceptance_page.dart` - 使用该组件的页面
- `/lib/widgets/file_upload/image_upload_widget.dart` - 参考实现
