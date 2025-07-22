import '../../../models/common/result.dart';
import '../../../models/todo/page_todo_task.dart';

abstract class TodoApiService {
  Future<Result<PageTodoTask>> getTodoList({
    int? pageNum,
    int? pageSize,
  });
}