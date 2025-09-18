// speech_to_text_service.dart

import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  /// 广播streamController处理状态更新
  final _statusStreamController = StreamController<String>.broadcast();

  /// 暴露stream给外部bloc们监听
  Stream<String> get statusStream => _statusStreamController.stream;

  /// 封装一个确保初始化的方法
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    await _speechToText.initialize(
      onStatus: (status) => _statusStreamController.add(status),
      onError: (error) => _statusStreamController.addError(error),
    );
    _isInitialized = true;
  }

  void startListening({required Function(String) onResult}) {
    if (!_isInitialized) return;
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

  void stopListening() {
    if (!_isInitialized) return;
    _speechToText.stop();
  }

  void dispose() {
    _statusStreamController.close();
  }
}
