// speech_to_text_service.dart

import 'dart:async';

import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/utils/platform_utils.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'base_speech_service.dart';

class SpeechToTextService implements BaseSpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  /// 广播streamController处理状态更新
  final _statusStreamController = StreamController<String>.broadcast();

  /// 暴露stream给外部bloc们监听
  @override
  Stream<String> get statusStream => _statusStreamController.stream;

  @override
  bool get isSupported => PlatformUtils.supportsSpeechToText;

  /// 封装一个确保初始化的方法
  @override
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;

    // 仅在iOS平台初始化speech_to_text服务
    if (!PlatformUtils.supportsSpeechToText) {
      Logger.info(
        '当前平台(${PlatformUtils.platformName})不支持语音识别功能',
        tag: '【speech】',
      );
      return;
    }

    await _speechToText.initialize(
      onStatus: (status) => _statusStreamController.add(status),
      onError: (error) {
        Logger.error('SpeechToText Error: $error', tag: '【speech】');
        _statusStreamController.addError(error);
      },
    );
    _isInitialized = true;
  }

  @override
  void startListening({required Function(String) onResult}) {
    if (!_isInitialized || !PlatformUtils.supportsSpeechToText) {
      Logger.warning('语音识别服务未初始化或平台不支持', tag: '【speech】');
      return;
    }
    _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenFor: Duration(seconds: 60),
      pauseFor: Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.dictation,
      ),
      localeId: 'zh-CN', // 设置为中文
    );
  }

  @override
  void stopListening() {
    if (!_isInitialized || !PlatformUtils.supportsSpeechToText) return;
    _speechToText.stop();
  }

  @override
  void dispose() {
    _statusStreamController.close();
  }
}
