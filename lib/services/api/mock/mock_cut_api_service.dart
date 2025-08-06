import '../../../models/common/result.dart';
import '../../../models/cut/cut_request_vo.dart';
import '../../../models/cut/pipe_cutting_record.dart';
import '../../../models/cut/cutting_history_node.dart';
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

  @override
  Future<Result<PipeCuttingRecord>> getCuttingHistory(String materialId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (materialId == "XT03C3312530022042") {
      // 返回基于您提供真实数据的mock对象
      final mockData = PipeCuttingRecord(
        materialRootId: 31,
        name: "给水-GB/T 13295-2019-SIA St-DN800-K9-5.9-水泥-Zn130-HCPE(黑色)",
        factoryName: "新兴铸管",
        materialCode: "XT03C3312530022042",
        setProdStdNo: "P10WL002630",
        standard: "GB/T 13295-2019",
        spec: "DN800",
        batchCode: null,
        len: "20.0",
        produceDate: "2025-08-01",
        cutHisTree: CuttingHistoryNode(
          materialId: 31,
          parentId: null,
          rootId: 31,
          len: "20.0",
          cutTime: "2025-08-01",
          img: "http://example.com/image1.jpg",
          cutUserName: "李逸群",
          cutUserId: 117,
          cutUserPhone: "17700699875",
          children: [
            // 简化的子节点结构
            CuttingHistoryNode(
              materialId: 78,
              parentId: "31",
              rootId: 31,
              len: "10.0",
              cutTime: "2025-08-01T16:13:15",
              img: "http://example.com/image2.jpg",
              cutUserName: null,
              cutUserId: -1,
              cutUserPhone: null,
              children: null,
              currentId: "78",
            ),
          ],
          currentId: "31",
        ),
      );
      return Result(code: 0, msg: 'success', data: mockData);
    }
    
    return Result(code: -1, msg: '未找到截管记录', data: null);
  }
}
