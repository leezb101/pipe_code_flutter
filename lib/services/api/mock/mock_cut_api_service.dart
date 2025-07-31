import '../../../models/common/result.dart';
import '../../../models/cut/cut_request_vo.dart';
import '../interfaces/cut_api_service.dart';

class MockCutApiService implements CutApiService {
  @override
  Future<Result<String>> getTipsForCutting(CutRequestVo request) async {
    // Mock implementation
    return Result(code: 0, msg: 'success', data: 'Mock cutting tips');
  }

  @override
  Future<Result<void>> doCut(CutRequestVo request) async {
    // Mock implementation
    return Result(code: 0, msg: 'success');
  }
}
