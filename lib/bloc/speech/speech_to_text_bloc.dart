// speech_to_text_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/speech_to_text_service.dart';
import '../../config/service_locator.dart';

class SpeechToTextBloc extends Bloc<SpeechToTextEvent, SpeechToTextState> {
  final SpeechToTextService _speechToTextService = getIt<SpeechToTextService>();

  SpeechToTextBloc() : super(SpeechToTextInitial()) {
    on<SpeechToTextInitialize>((event, emit) async {
      final isInitialized = await _speechToTextService.initialize();
      if (!isInitialized) {
        emit(SpeechToTextError("Speech recognition not available"));
      }
    });

    on<SpeechToTextStart>((event, emit) {
      _speechToTextService.startListening(
        onResult: (result) {
          add(SpeechToTextResult(result));
        },
      );
      emit(SpeechToTextListening());
    });

    on<SpeechToTextStop>((event, emit) {
      _speechToTextService.stopListening();
      emit(SpeechToTextInitial());
    });

    on<SpeechToTextResult>((event, emit) {
      emit(SpeechToTextLoaded(event.recognizedWords));
    });
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

// speech_to_text_state.dart

abstract class SpeechToTextState {}

class SpeechToTextInitial extends SpeechToTextState {}

class SpeechToTextListening extends SpeechToTextState {}

class SpeechToTextLoaded extends SpeechToTextState {
  final String recognizedWords;
  SpeechToTextLoaded(this.recognizedWords);
}

class SpeechToTextError extends SpeechToTextState {
  final String error;
  SpeechToTextError(this.error);
}

// speech_to_text_bloc.dart
