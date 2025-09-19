// base_speech_service.dart

import 'dart:async';

/// 语音识别服务的基础抽象类
/// 为不同平台的语音识别实现提供统一接口
abstract class BaseSpeechService {
  /// 状态流，用于通知外部状态变化
  Stream<String> get statusStream;

  /// 初始化语音识别服务
  Future<void> ensureInitialized();

  /// 开始语音识别
  void startListening({required Function(String) onResult});

  /// 停止语音识别
  void stopListening();

  /// 释放资源
  void dispose();

  /// 检查当前平台是否支持语音识别
  bool get isSupported;
}
