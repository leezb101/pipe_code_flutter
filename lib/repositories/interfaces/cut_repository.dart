import '../../models/cut/cut_request_vo.dart';

abstract class CutRepository {
  Future<String> getTipsForCutting(CutRequestVo request);

  Future<void> doCut(CutRequestVo request);
}
