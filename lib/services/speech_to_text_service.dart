// speech_to_text_service.dart

import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    _isInitialized = await _speechToText.initialize();
    // final localeInfo = await _speechToText.locales();

    // for (var element in localeInfo) {
    //   Logger.debug('可用的语言: ${element.localeId} - ${element.name}');
    // }
    return _isInitialized;
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

  bool get isListening => _speechToText.isListening;
}
