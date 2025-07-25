/*
 * @Author: LeeZB
 * @Date: 2025-07-22 10:36:43
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 16:42:43
 * @copyright: Copyright © 2025 高新供水.
 */
import '../../../models/common/result.dart';
import '../../../models/todo/page_todo_task.dart';

abstract class TodoApiService {
  Future<Result<PageTodoTask>> getTodoList({int? pageNum, int? pageSize});

  Future<Result<PageTodoTask>> getWarehouseTodoList({
    int? pageNum,
    int? pageSize,
  });
}
