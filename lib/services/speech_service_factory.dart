// speech_service_factory.dart

import 'package:pipe_code_flutter/utils/platform_utils.dart';
import 'base_speech_service.dart';
import 'speech_to_text_service.dart';
import 'android_speech_service.dart';

/// 语音服务工厂类
/// 根据当前平台创建相应的语音识别服务实现
class SpeechServiceFactory {
  /// 创建适用于当前平台的语音识别服务
  static BaseSpeechService createSpeechService() {
    if (PlatformUtils.isIOS) {
      return SpeechToTextService();
    } else if (PlatformUtils.isAndroid) {
      return AndroidSpeechService();
    } else {
      // 其他平台使用Android的占位实现
      return AndroidSpeechService();
    }
  }

  /// 检查当前平台是否支持语音识别
  static bool get isSupported {
    return PlatformUtils.supportsSpeechToText;
  }
}
