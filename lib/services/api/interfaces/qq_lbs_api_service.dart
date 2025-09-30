import 'package:pipe_code_flutter/models/common/result.dart';

abstract class QQLbsApiService {
  /// 获取sig
  Future<Result<Map<String, dynamic>>> getSig({
    required Map<String, dynamic> params,
  });

  /// 获取key
  Future<Result<String>> getKey();
}
