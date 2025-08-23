# 仓管员非项目入库页面图片上传功能实现

## 概述
参照 `scrap_page.dart` 的图片上传实现，为 `storekeeper_non_project_page.dart` 添加了完整的图片上传功能。

## 实现内容

### 1. 依赖导入
```dart
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';
```

### 2. 文件上传组件初始化
- 在 `initState()` 中初始化 `_imageUploadCubit = FileUploadCubit()`
- 在 `dispose()` 中释放资源 `_imageUploadCubit.close()`

### 3. 图片上传UI组件替换
将原来的简化版图片上传区域替换为完整的 `ImageUploadWidget`：
```dart
BlocBuilder<FileUploadCubit, List<FileUploadState>>(
  bloc: _imageUploadCubit,
  builder: (context, states) {
    return ImageUploadWidget(
      title: '照片',
      maxImages: 6,
      states: states,
      onAdd: (files) {
        _imageUploadCubit.addFiles(files);
      },
      onRemove: (uniqueId) {
        _imageUploadCubit.removeFile(uniqueId);
      },
      onRetry: (uniqueId) {
        _imageUploadCubit.retryUpload(uniqueId);
      },
    );
  },
),
```

### 4. 提交逻辑增强
新增 `_submitEntry()` 方法，参照 `scrap_page.dart` 的实现：
- 检查上传状态（是否还在上传中）
- 检查上传失败的情况
- 提取成功上传的照片URL
- 集成到提交流程中

### 5. 上传状态验证
```dart
// 检查是否还有照片在上传中
final isUploading = uploadStates.any((s) => s.status == UploadStatus.uploading);

// 检查是否有上传失败的照片
final hasFailures = uploadStates.any((s) => s.status == UploadStatus.failure);

// 获取成功上传的照片URL
final photoUrls = uploadStates
    .where((s) => s.status == UploadStatus.success && s.uploadResult != null)
    .map((state) => state.uploadResult!.fileUrl)
    .toList();
```

### 6. 用户体验优化
- 上传中时显示提示："照片仍在上传中，请稍候..."
- 上传失败时显示错误："有图片上传失败，请重试或删除。"
- 最大支持 6 张图片上传
- 支持重试失败的上传
- 支持删除已选择的图片

## 技术要点

### 与 scrap_page.dart 的一致性
1. **FileUploadCubit 使用模式**：完全一致的状态管理和生命周期管理
2. **ImageUploadWidget 配置**：相同的参数设置和回调处理
3. **上传状态检查逻辑**：相同的状态验证和错误处理机制
4. **用户反馈**：一致的Toast提示信息

### 架构集成
- 保持了现有的Bloc架构模式
- 图片上传与业务逻辑解耦
- 遵循项目的错误处理规范

## 后续工作

### Bloc事件扩展（建议）
可以考虑在 `StorekeeperNonProjectBloc` 中添加 `UpdatePhotos` 事件来管理照片状态：
```dart
// 在StorekeeperNonProjectEvent中添加
class UpdatePhotos extends StorekeeperNonProjectEvent {
  final List<String> photoUrls;
  const UpdatePhotos(this.photoUrls);
}
```

### 状态持久化
照片URL可以集成到最终的提交数据结构中，确保在提交时包含照片信息。

## 测试验证
- ✅ 静态分析通过：`flutter analyze` 无问题
- ✅ 编译检查通过：无编译错误
- ✅ 代码风格一致：遵循项目代码规范

## 文件修改清单
- `/lib/pages/storekeeper/storekeeper_non_project_page.dart` - 主要实现文件
  - 添加依赖导入
  - 新增 `_submitEntry()` 方法
  - 替换图片上传UI组件
  - 更新提交按钮调用逻辑

---
*实现日期: 2025年8月23日*
*参考页面: scrap_page.dart*
*实现目标: 为仓管员非项目入库功能添加完整的图片上传支持*
