// android_speech_service.dart

import 'dart:async';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'base_speech_service.dart';

/// Android端语音识别服务实现
/// 当前为占位实现，后续可集成其他Android语音识别方案
class AndroidSpeechService implements BaseSpeechService {
  final _statusStreamController = StreamController<String>.broadcast();

  @override
  Stream<String> get statusStream => _statusStreamController.stream;

  @override
  bool get isSupported => false; // 当前Android端暂不支持，后续可修改

  @override
  Future<void> ensureInitialized() async {
    Logger.info('Android语音识别服务暂未实现', tag: '【speech】');
    // TODO: 在这里实现Android端的语音识别初始化
    // 例如：集成科大讯飞、百度语音等SDK
  }

  @override
  void startListening({required Function(String) onResult}) {
    Logger.warning('Android语音识别功能暂未实现', tag: '【speech】');
    _statusStreamController.add('notListening');
    // TODO: 实现Android端的语音识别开始逻辑
  }

  @override
  void stopListening() {
    Logger.info('停止Android语音识别（占位实现）', tag: '【speech】');
    _statusStreamController.add('notListening');
    // TODO: 实现Android端的语音识别停止逻辑
  }

  @override
  void dispose() {
    _statusStreamController.close();
    // TODO: 释放Android端语音识别相关资源
  }
}
