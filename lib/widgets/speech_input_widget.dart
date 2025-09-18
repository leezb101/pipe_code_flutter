// speech_input_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/speech/speech_to_text_bloc.dart';

class SpeechInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final int? maxLines;
  final InputDecoration? decoration;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final ValueChanged<String>? onChanged;
  // ... (add all other TextField parameters that you need)

  const SpeechInputWidget({
    super.key,
    required this.controller,
    this.decoration,
    this.maxLines,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.onChanged,
    // ... (initialize other parameters)
  });

  @override
  SpeechInputWidgetState createState() => SpeechInputWidgetState();
}

class SpeechInputWidgetState extends State<SpeechInputWidget> {
  late final SpeechToTextBloc _speechToTextBloc;
  String _textBeforeListening = '';

  @override
  void initState() {
    super.initState();
    _speechToTextBloc = SpeechToTextBloc()..add(SpeechToTextInitialize());
  }

  @override
  void dispose() {
    _speechToTextBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _speechToTextBloc,
      child: BlocListener<SpeechToTextBloc, SpeechToTextState>(
        listener: (context, state) {
          if (state is SpeechToTextLoaded) {
            final newText = _textBeforeListening.isEmpty
                ? state.recognizedWords
                : '$_textBeforeListening${state.recognizedWords}';
            widget.controller.text = newText;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: widget.controller.text.length),
            );
            // 手动触发 onChanged 回调
            if (widget.onChanged != null) {
              widget.onChanged!(newText);
            }
          }
        },
        child: BlocBuilder<SpeechToTextBloc, SpeechToTextState>(
          builder: (context, state) {
            final isListening = state is SpeechToTextListening;
            return TextField(
              controller: widget.controller,
              style: widget.style,
              maxLines: widget.maxLines,
              strutStyle: widget.strutStyle,
              textAlign: widget.textAlign,
              textAlignVertical: widget.textAlignVertical,
              decoration: (widget.decoration ?? const InputDecoration())
                  .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(isListening ? Icons.stop : Icons.mic),
                      onPressed: () {
                        if (isListening) {
                          _speechToTextBloc.add(SpeechToTextStop());
                        } else {
                          _textBeforeListening = widget.controller.text;
                          _speechToTextBloc.add(SpeechToTextStart());
                        }
                      },
                    ),
                  ),
              onChanged: widget.onChanged,
            );
          },
        ),
      ),
    );
  }
}
