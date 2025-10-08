import 'package:rxdart/rxdart.dart';
import '../../services/api/interfaces/profile_api_service.dart';

class FeedbackBloc {
  final ProfileApiService profileApiService;
  FeedbackBloc({required this.profileApiService});

  // 输入文本
  final _text = BehaviorSubject<String>.seeded('');
  Stream<String> get text$ => _text.stream;
  void updateText(String? newText) {
    if (newText != null) {
      _text.add(newText);
    } else {
      _text.add('');
    }
  }

  // 提交按钮可用状态
  Stream<bool> get canSubmit$ =>
      _text.stream.map((t) => t.trim().isNotEmpty).distinct();

  // 提交中状态
  final _isSubmitting = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isSubmitting$ => _isSubmitting.stream;

  // 错误信息流，null表示无错误
  final _error = PublishSubject<String?>();
  Stream<String?> get error$ => _error.stream;

  Future<bool> submit() async {
    final text = _text.value.trim();
    if (text.isEmpty) return false;

    _isSubmitting.add(true);
    try {
      await profileApiService.submitFeedback(text);
      _error.add(null);
      return true;
    } catch (e) {
      _error.add(e.toString());
      return false;
    } finally {
      _isSubmitting.add(false);
    }
  }

  void clear() => _text.add('');

  void dispose() {
    _text.close();
    _isSubmitting.close();
    _error.close();
  }
}
