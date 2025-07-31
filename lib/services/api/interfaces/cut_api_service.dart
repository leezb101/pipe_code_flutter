import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/cut/cut_request_vo.dart';

abstract class CutApiService {
  Future<Result<String>> getTipsForCutting(CutRequestVo request);

  Future<Result<void>> doCut(CutRequestVo request);
}
