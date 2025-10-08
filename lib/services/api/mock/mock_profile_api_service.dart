import 'package:pipe_code_flutter/services/api/interfaces/profile_api_service.dart';

class MockProfileApiService implements ProfileApiService {
  @override
  Future<void> submitFeedback(String feedback) async {
    await Future.delayed(const Duration(seconds: 1));
    // 模拟成功提交反馈
    return;
  }
}
