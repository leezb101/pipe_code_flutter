/*
 * @Author: LeeZB
 * @Date: 2025-07-13 16:00:38
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-21 19:47:48
 * @copyright: Copyright © 2025 高新供水.
 */
import 'business_record.dart';
import 'project_record.dart';
import '../todo/todo_task.dart';

abstract class RecordItem {
  int get id;
  String get projectName;
  String get projectCode;
  String get userName;
  DateTime? get doTime;
  String get businessTypeDescription;
}

class BusinessRecordItem implements RecordItem {
  final BusinessRecord _record;

  BusinessRecordItem(this._record);

  @override
  int get id => _record.id;

  @override
  String get projectName => _record.projectName;

  @override
  String get projectCode => _record.projectCode;

  @override
  String get userName => _record.userName;

  @override
  DateTime? get doTime => _record.doTime;

  @override
  String get businessTypeDescription => _record.businessTypeDescription;

  BusinessRecord get record => _record;
}

class ProjectRecordItem implements RecordItem {
  final ProjectRecord _record;

  ProjectRecordItem(this._record);

  @override
  int get id => _record.id;

  @override
  String get projectName => _record.projectName;

  @override
  String get projectCode => _record.projectCode;

  @override
  String get userName => _record.userName;

  @override
  DateTime? get doTime => _record.doTime;

  @override
  String get businessTypeDescription => _record.businessTypeDescription;

  ProjectRecord get record => _record;
}

class TodoRecordItem implements RecordItem {
  final TodoTask _todo;

  TodoRecordItem(this._todo);

  @override
  int get id => _todo.id;

  @override
  String get projectName => _todo.projectName;

  @override
  String get projectCode => _todo.projectCode;

  @override
  String get userName => _todo.launchName;

  @override
  DateTime? get doTime => _todo.launchTime;

  @override
  String get businessTypeDescription => _todo.todoName;

  TodoTask get todo => _todo;
}
