import 'package:pipe_code_flutter/models/common/result.dart';

abstract class TemporaryAuthApiService {
  Future<Result<void>> submitTemporarySubAuth({
    required String name,
    required String phone,
  });

  Future<Result<void>> submitTemporaryLaborAuth({
    required String name,
    required String phone,
    required int interval,
  });
}
