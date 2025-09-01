import 'package:pipe_code_flutter/models/common/common_enum_vo.dart';

abstract class TemporaryAuthRepository {
  Future<bool> submitTemporarySubAuth(String name, String phone);
  Future<bool> submitTemporaryLaborAuth(
    String name,
    String phone,
    Interval interval,
  );
}
