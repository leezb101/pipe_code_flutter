import 'package:dio/src/dio.dart';

import 'base_api_service.dart';
import '../interfaces/profile_api_service.dart';

class ProfileApiServiceImpl extends BaseApiService
    implements ProfileApiService {
  ProfileApiServiceImpl(super.dio);

  @override
  Future<void> submitFeedback(String feedback) {
    // TODO: implement submitFeedback
    throw UnimplementedError();
  }
}
