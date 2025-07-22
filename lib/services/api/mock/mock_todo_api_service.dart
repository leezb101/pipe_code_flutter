import '../../../models/common/result.dart';
import '../../../models/todo/page_todo_task.dart';
import '../../../models/todo/todo_task.dart';
import '../interfaces/todo_api_service.dart';

class MockTodoApiService implements TodoApiService {
  @override
  Future<Result<PageTodoTask>> getTodoList({
    int? pageNum,
    int? pageSize,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final currentPage = pageNum ?? 1;
    final size = pageSize ?? 10;
    
    final mockTasks = _generateMockTodos();
    final startIndex = (currentPage - 1) * size;
    final endIndex = (startIndex + size).clamp(0, mockTasks.length);
    
    final paginatedTasks = startIndex < mockTasks.length 
        ? mockTasks.sublist(startIndex, endIndex)
        : <TodoTask>[];

    final pageData = PageTodoTask(
      records: paginatedTasks,
      total: mockTasks.length,
      size: size,
      current: currentPage,
    );

    return Result.success(pageData);
  }

  List<TodoTask> _generateMockTodos() {
    final now = DateTime.now();
    return [
      TodoTask(
        id: 1,
        name: '管道验收任务',
        businessType: 1,
        businessName: '验收',
        businessId: 1001,
        projectId: 2001,
        projectName: '智慧水务项目一期',
        projectCode: 'ZS2024001',
        launchTime: now.subtract(const Duration(days: 2, hours: 3)),
        finishTime: null,
        finishStatus: 0,
        launchUser: 'user001',
        launchName: '张工程师',
      ),
      TodoTask(
        id: 2,
        name: '管道安装核销',
        businessType: 2,
        businessName: '安装',
        businessId: 1002,
        projectId: 2001,
        projectName: '智慧水务项目一期',
        projectCode: 'ZS2024001',
        launchTime: now.subtract(const Duration(days: 3, hours: 10, minutes: 30)),
        finishTime: now.subtract(const Duration(days: 2, hours: 7, minutes: 15)),
        finishStatus: 1,
        launchUser: 'user002',
        launchName: '李主管',
      ),
      TodoTask(
        id: 3,
        name: '管道巡检任务',
        businessType: 3,
        businessName: '巡检',
        businessId: 1003,
        projectId: 2002,
        projectName: '智慧水务项目二期',
        projectCode: 'ZS2024002',
        launchTime: now.subtract(const Duration(days: 1, hours: 16)),
        finishTime: null,
        finishStatus: 0,
        launchUser: 'user003',
        launchName: '王技术员',
      ),
      TodoTask(
        id: 4,
        name: '质量检查任务',
        businessType: 4,
        businessName: '质检',
        businessId: 1004,
        projectId: 2001,
        projectName: '智慧水务项目一期',
        projectCode: 'ZS2024001',
        launchTime: now.subtract(const Duration(days: 4, hours: 13, minutes: 45)),
        finishTime: now.subtract(const Duration(days: 3, hours: 12, minutes: 30)),
        finishStatus: 1,
        launchUser: 'user004',
        launchName: '赵质检员',
      ),
      TodoTask(
        id: 5,
        name: '设备维护任务',
        businessType: 5,
        businessName: '维护',
        businessId: 1005,
        projectId: 2003,
        projectName: '设备维护项目',
        projectCode: 'WH2024001',
        launchTime: now.subtract(const Duration(hours: 10, minutes: 40)),
        finishTime: null,
        finishStatus: 0,
        launchUser: 'user005',
        launchName: '陈维护员',
      ),
    ];
  }
}