# Android语音识别集成指南

## 当前状态

项目现在已经实现了平台分离的语音识别架构：

- **iOS端**: 使用 `speech_to_text` 插件，功能正常
- **Android端**: 当前为占位实现，需要集成第三方语音识别方案

## 架构设计

### 1. 抽象接口 (BaseSpeechService)
所有平台的语音识别服务都需要实现 `BaseSpeechService` 接口：

```dart
abstract class BaseSpeechService {
  Stream<String> get statusStream;
  Future<void> ensureInitialized();
  void startListening({required Function(String) onResult});
  void stopListening();
  void dispose();
  bool get isSupported;
}
```

### 2. 平台实现
- `SpeechToTextService`: iOS端实现，基于 speech_to_text 插件
- `AndroidSpeechService`: Android端占位实现，待集成具体方案

### 3. 工厂模式
`SpeechServiceFactory` 根据平台自动选择合适的实现。

## Android端集成建议方案

### 方案一：科大讯飞语音识别

1. **添加依赖**
   ```yaml
   dependencies:
     # 在 pubspec.yaml 中添加
     flutter_xfyun_asr: ^x.x.x
   ```

2. **修改 AndroidSpeechService**
   ```dart
   class AndroidSpeechService implements BaseSpeechService {
     // 初始化科大讯飞SDK
     @override
     Future<void> ensureInitialized() async {
       // 初始化科大讯飞语音识别
     }
     
     @override
     void startListening({required Function(String) onResult}) {
       // 开始科大讯飞语音识别
     }
   }
   ```

### 方案二：百度语音识别

1. **添加依赖**
   ```yaml
   dependencies:
     baidu_speech_recognition: ^x.x.x
   ```

2. **实现相关接口方法**

### 方案三：自定义Native Bridge

如果需要使用特定的Android原生语音识别SDK：

1. **创建Method Channel**
2. **实现Android端原生代码**
3. **在AndroidSpeechService中调用**

## 修改步骤

### 1. 选择语音识别方案
根据项目需求选择合适的第三方语音识别服务。

### 2. 修改 AndroidSpeechService
在 `lib/services/android_speech_service.dart` 中实现具体的语音识别逻辑。

### 3. 更新 isSupported 属性
在 `PlatformUtils.supportsSpeechToText` 中添加Android支持：

```dart
static bool get supportsSpeechToText => isIOS || isAndroid;
```

### 4. 测试验证
确保在Android设备上语音识别功能正常工作。

## 关键文件

- `lib/utils/platform_utils.dart`: 平台检测工具
- `lib/services/base_speech_service.dart`: 抽象接口
- `lib/services/android_speech_service.dart`: Android实现（待完善）
- `lib/services/speech_service_factory.dart`: 服务工厂
- `lib/config/service_locator.dart`: 依赖注入配置

## 注意事项

1. **权限配置**: 确保在 `android/app/src/main/AndroidManifest.xml` 中添加录音权限
2. **错误处理**: 实现完整的错误处理和状态管理
3. **资源释放**: 确保在应用关闭时正确释放语音识别相关资源
4. **性能优化**: 考虑语音识别的性能影响和电池消耗

## 当前状态总结

✅ 已完成平台判断逻辑
✅ iOS端语音识别正常工作  
✅ 架构支持Android端扩展
🔄 Android端具体实现待集成
