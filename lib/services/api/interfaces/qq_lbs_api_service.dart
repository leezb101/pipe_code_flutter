import 'package:pipe_code_flutter/models/common/result.dart';

abstract class QQLbsApiService {
  /// 获取sig
  Future<Result<String>> getSig();

  /// 获取key
  Future<Result<String>> getKey();
}
