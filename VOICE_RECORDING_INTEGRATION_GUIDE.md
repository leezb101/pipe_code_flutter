# 语音录制功能集成指南

## 功能概述

本功能在现有语音识别服务的基础上，新增了同时录制语音文件并上传到服务器的能力。用户在使用语音输入时，系统会：

1. **同时进行语音识别和录音** - 不影响原有语音识别功能
2. **自动上传录音文件** - 录音完成后自动上传到服务器
3. **返回文件路径** - 上传成功后返回服务器文件路径
4. **集成到表单** - 文件路径可作为表单字段一起提交

## 技术架构

### 核心组件

1. **BaseVoiceRecordingService** (`lib/services/base_voice_recording_service.dart`)
   - 抽象接口，定义录音服务的基本功能
   - 状态管理、权限检查、错误处理

2. **VoiceRecordingService** (`lib/services/voice_recording_service.dart`)
   - 具体实现，使用 `record` 库
   - 集成文件上传功能
   - 自动清理本地文件

3. **SpeechInputWidget** (`lib/widgets/speech_input_widget.dart`)
   - 扩展现有组件，集成录音功能
   - 通过回调机制传递录音文件路径
   - 保持与原有语音识别功能的兼容性

### 技术特点

- **非侵入式设计** - 不影响现有语音识别功能
- **独立服务架构** - 录音服务与语音识别服务解耦
- **异步处理** - 录音和上传在后台进行
- **错误处理** - 完整的错误处理和用户提示
- **资源管理** - 自动清理临时文件

## 使用方法

### 1. 在表单中使用

```dart
SpeechInputWidget(
  controller: _textController,
  decoration: const InputDecoration(
    hintText: '请输入或语音输入...',
    border: OutlineInputBorder(),
  ),
  // 新增：录音文件路径回调
  onVoiceRecordingPath: (filePath) {
    // 录音上传完成，保存文件路径到表单数据
    setState(() {
      _voiceFilePath = filePath;
    });
    
    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('录音已上传成功！')),
    );
  },
)
```

### 2. 提交表单数据

```dart
void _submitForm() {
  final formData = {
    'text': _textController.text,        // 语音识别的文字
    'voiceFile': _voiceFilePath,         // 录音文件路径
    'submitTime': DateTime.now().toIso8601String(),
  };
  
  // 调用API提交数据
  await apiService.submitForm(formData);
}
```

### 3. 完整示例

参考 `lib/examples/example_form_with_voice_recording.dart` 文件，该示例展示了：

- 如何在表单中使用多个语音输入组件
- 如何处理录音文件路径回调
- 如何在UI中显示录音状态
- 如何将录音路径与表单数据一起提交

## 配置说明

### 1. 依赖配置

已在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  record: ^5.1.2  # 录音功能
```

### 2. 服务注册

在 `lib/config/service_locator.dart` 中已注册：

```dart
getIt.registerLazySingleton<BaseVoiceRecordingService>(
  () => VoiceRecordingService(getIt<UploadApiService>()),
);
```

### 3. 权限配置

录音功能需要麦克风权限，`record` 库会自动处理权限请求。

#### Android 权限
在 `android/app/src/main/AndroidManifest.xml` 中添加：
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS 权限
在 `ios/Runner/Info.plist` 中添加：
```xml
<key>NSMicrophoneUsageDescription</key>
<string>需要麦克风权限进行语音录制</string>
```

## API 接口

### BaseVoiceRecordingService

```dart
abstract class BaseVoiceRecordingService {
  // 状态流
  Stream<VoiceRecordingStatus> get statusStream;
  Stream<double> get progressStream;
  Stream<String> get errorStream;
  
  // 核心功能
  Future<void> initialize();
  Future<void> startRecording({
    required Function(String filePath) onResult,
    Function(String error)? onError,
  });
  Future<void> stopRecording();
  Future<void> cancelRecording();
  
  // 权限管理
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  
  // 平台支持
  bool get isSupported;
  void dispose();
}
```

### VoiceRecordingStatus

```dart
enum VoiceRecordingStatus {
  idle,        // 空闲状态
  recording,   // 录音中
  processing,  // 处理中
  uploading,   // 上传中
  completed,   // 完成
  error,       // 错误
}
```

## 错误处理

### 常见错误场景

1. **权限被拒绝**
   ```dart
   onError: (error) {
     if (error.contains('权限被拒绝')) {
       // 提示用户开启麦克风权限
     }
   }
   ```

2. **录制失败**
   ```dart
   onError: (error) {
     if (error.contains('录制失败')) {
       // 检查设备兼容性和存储空间
     }
   }
   ```

3. **上传失败**
   ```dart
   onError: (error) {
     if (error.contains('上传失败')) {
       // 检查网络连接和服务器状态
     }
   }
   ```

### 错误处理最佳实践

```dart
SpeechInputWidget(
  controller: controller,
  onVoiceRecordingPath: (filePath) {
    // 成功处理
    _handleRecordingSuccess(filePath);
  },
  onVoiceRecordingError: (error) {
    // 错误处理
    _handleRecordingError(error);
  },
)
```

## 注意事项

### 1. 平台兼容性
- 支持 iOS、Android、macOS、Windows
- 不同平台的录音格式可能不同（iOS: m4a, Android: aac）

### 2. 文件管理
- 录音文件上传成功后会自动删除本地临时文件
- 文件命名格式：`voice_recording_${timestamp}.aac`

### 3. 性能考虑
- 录音和语音识别同时进行，CPU使用率会有所提升
- 建议在录音时显示进度指示器

### 4. 用户体验
- 录音开始时提供视觉反馈（按钮状态变化）
- 上传过程中显示进度提示
- 完成后提供明确的成功提示

## 测试建议

### 1. 功能测试
- [ ] 语音识别功能正常工作
- [ ] 录音功能正常工作
- [ ] 两个功能同时工作不冲突
- [ ] 文件上传成功
- [ ] 错误处理正确

### 2. 边界测试
- [ ] 网络断开时的处理
- [ ] 权限被拒绝时的处理
- [ ] 存储空间不足时的处理
- [ ] 长时间录音的处理

### 3. 兼容性测试
- [ ] 不同Android版本
- [ ] 不同iOS版本
- [ ] 不同设备型号

## 扩展建议

### 1. 功能增强
- 添加录音时长限制
- 支持录音暂停/恢复
- 添加录音质量配置选项
- 支持录音文件预览播放

### 2. UI优化
- 录音波形动画
- 录音时长显示
- 文件大小显示
- 上传进度条

### 3. 性能优化
- 录音文件压缩
- 批量上传支持
- 离线录音暂存
