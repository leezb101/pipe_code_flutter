import 'dart:math';
import '../../../models/records/record_list_response.dart';
import '../../../models/records/record_type.dart';
import '../../../models/records/business_record.dart';
import '../../../models/records/project_record.dart';
import '../../../models/common/result.dart';
import '../interfaces/records_api_service.dart';

class MockRecordsApiService implements RecordsApiService {
  final Random _random = Random();

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(700)));
  }

  @override
  Future<Result<BusinessRecordPageData>> getBusinessRecords({
    required RecordType recordType,
    int? projectId,
    int? userId,
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    await _simulateNetworkDelay();

    final totalRecords = _random.nextInt(50) + 20;
    final startIndex = (pageNum - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, totalRecords);
    final recordsToGenerate = (endIndex - startIndex).clamp(0, pageSize);

    final records = List.generate(recordsToGenerate, (index) {
      final actualIndex = startIndex + index;
      return _generateBusinessRecord(actualIndex, recordType);
    });

    final pageData = BusinessRecordPageData(
      records: records,
      total: totalRecords,
      size: pageSize,
      current: pageNum,
    );

    return Result(code: 0, msg: '成功', data: pageData);
  }

  @override
  Future<Result<ProjectRecordPageData>> getProjectInitRecords({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  }) async {
    await _simulateNetworkDelay();

    final totalRecords = _random.nextInt(30) + 10;
    final startIndex = (pageNum - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, totalRecords);
    final recordsToGenerate = (endIndex - startIndex).clamp(0, pageSize);

    final records = List.generate(recordsToGenerate, (index) {
      final actualIndex = startIndex + index;
      return _generateProjectRecord(actualIndex, isInit: true);
    });

    final pageData = ProjectRecordPageData(
      records: records,
      total: totalRecords,
      size: pageSize,
      current: pageNum,
      pages: (totalRecords / pageSize).ceil(),
    );

    return Result(code: 0, msg: '成功', data: pageData);
  }

  @override
  Future<Result<ProjectRecordPageData>> getProjectAuditRecords({
    int pageNum = 1,
    int pageSize = 10,
    String? projectName,
    String? projectCode,
  }) async {
    await _simulateNetworkDelay();

    final totalRecords = _random.nextInt(25) + 5;
    final startIndex = (pageNum - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, totalRecords);
    final recordsToGenerate = (endIndex - startIndex).clamp(0, pageSize);

    final records = List.generate(recordsToGenerate, (index) {
      final actualIndex = startIndex + index;
      return _generateProjectRecord(actualIndex, isInit: false);
    });

    final pageData = ProjectRecordPageData(
      records: records,
      total: totalRecords,
      size: pageSize,
      current: pageNum,
      pages: (totalRecords / pageSize).ceil(),
    );

    return Result(code: 0, msg: '成功', data: pageData);
  }

  BusinessRecord _generateBusinessRecord(int index, RecordType recordType) {
    final projectNames = [
      '智慧水务改造项目',
      '城区供水管网建设',
      '老旧管道改造工程',
      '新区水厂建设项目',
      '污水处理厂升级',
      '智能水表安装工程',
    ];

    final userNames = ['张工程师', '李技术员', '王施工员', '赵监理', '刘验收员', '陈项目经理'];

    final now = DateTime.now();
    final randomDays = _random.nextInt(30);
    final randomHours = _random.nextInt(24);
    final randomMinutes = _random.nextInt(60);

    final doTime = now.subtract(
      Duration(days: randomDays, hours: randomHours, minutes: randomMinutes),
    );

    return BusinessRecord(
      id: 1000 + index,
      bizType: _random.nextInt(7) + 1,
      projectName: projectNames[_random.nextInt(projectNames.length)],
      projectCode: 'FDSFS${433289 + index}',
      materialNum: _random.nextInt(1000) + 1,
      userName: userNames[_random.nextInt(userNames.length)],
      doTime:
          '${doTime.year}年${doTime.month}月${doTime.day}日 ${doTime.hour}点${doTime.minute}分',
    );
  }

  ProjectRecord _generateProjectRecord(int index, {required bool isInit}) {
    final projectNames = [
      '智慧水务改造项目',
      '城区供水管网建设',
      '老旧管道改造工程',
      '新区水厂建设项目',
      '污水处理厂升级',
      '智能水表安装工程',
    ];

    final userNames = ['张项目经理', '李工程师', '王技术负责人', '赵监理工程师', '刘总工', '陈项目总监'];

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _random.nextInt(90) + 30));
    final endDate = startDate.add(Duration(days: _random.nextInt(180) + 90));

    return ProjectRecord(
      id: 2000 + index,
      projectName: projectNames[_random.nextInt(projectNames.length)],
      projectCode: 'PROJ${20250001 + index}',
      projectStart:
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      projectEnd:
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
      createdName: userNames[_random.nextInt(userNames.length)],
      createdId: 10001 + _random.nextInt(100),
      status: isInit ? _random.nextInt(5) : _random.nextInt(3),
    );
  }
}
