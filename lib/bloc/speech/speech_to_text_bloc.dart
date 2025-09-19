// speech_to_text_bloc.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/utils/platform_utils.dart';
import '../../services/base_speech_service.dart';
import '../../config/service_locator.dart';

class SpeechToTextBloc extends Bloc<SpeechToTextEvent, SpeechToTextState> {
  final BaseSpeechService _speechService = getIt<BaseSpeechService>();
  StreamSubscription<String>? _statusSubscription;

  SpeechToTextBloc() : super(SpeechToTextInitial()) {
    // 仅在支持语音识别的平台上初始化和订阅服务
    if (PlatformUtils.supportsSpeechToText) {
      // 构造函数中订阅service的状态流
      _statusSubscription = _speechService.statusStream.listen((status) {
        add(_SpeechToTextStatusChanged(status));
      });
    }

    on<SpeechToTextInitialize>((event, emit) async {
      if (!PlatformUtils.supportsSpeechToText) {
        Logger.info('当前平台不支持语音识别功能', tag: '【speech】');
        emit(SpeechToTextError('当前平台不支持语音识别功能'));
        return;
      }
      await _speechService.ensureInitialized();
    });

    on<SpeechToTextStart>((event, emit) {
      if (!PlatformUtils.supportsSpeechToText) {
        Logger.warning('当前平台不支持语音识别功能', tag: '【speech】');
        return;
      }
      _speechService.startListening(
        onResult: (result) {
          add(SpeechToTextResult(result));
        },
      );
    });

    on<SpeechToTextStop>((event, emit) {
      if (!PlatformUtils.supportsSpeechToText) return;
      _speechService.stopListening();
    });

    on<SpeechToTextResult>((event, emit) {
      emit(SpeechToTextListening(event.recognizedWords));
    });

    // 统一处理所有状态变化
    on<_SpeechToTextStatusChanged>((event, emit) {
      Logger.debug(
        'SpeechToText Status Changed: ${event.status}',
        tag: '【speech】',
      );
      switch (event.status) {
        case 'listening':
          emit(SpeechToTextListening());
          break;
        case 'notListening':
        case 'done':
          // 只有在当前是聆听状态时才切换为 Initial，防止不必要的UI刷新
          if (state is SpeechToTextListening) {
            emit(SpeechToTextInitial());
          }
          break;
        default:
          break;
      }
    });
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}

// speech_to_text_event.dart

abstract class SpeechToTextEvent {}

class SpeechToTextInitialize extends SpeechToTextEvent {}

class SpeechToTextStart extends SpeechToTextEvent {}

class SpeechToTextStop extends SpeechToTextEvent {}

class SpeechToTextResult extends SpeechToTextEvent {
  final String recognizedWords;
  SpeechToTextResult(this.recognizedWords);
}

class _SpeechToTextStatusChanged extends SpeechToTextEvent {
  final String status;
  _SpeechToTextStatusChanged(this.status);
}

// speech_to_text_state.dart

abstract class SpeechToTextState {}

class SpeechToTextInitial extends SpeechToTextState {}

class SpeechToTextListening extends SpeechToTextState {
  final String recognizedWords;
  SpeechToTextListening([this.recognizedWords = '']);
}

class SpeechToTextError extends SpeechToTextState {
  final String error;
  SpeechToTextError(this.error);
}

// speech_to_text_bloc.dart
